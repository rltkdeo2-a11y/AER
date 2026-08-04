import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { spawnSync } from "node:child_process";
import { pathToFileURL } from "node:url";

export const MANIFEST_RUNNER_VERSION = "0.1.0";

function readJson(target) {
  return JSON.parse(fs.readFileSync(path.resolve(target), "utf8").replace(/^\uFEFF/, ""));
}

function sha256(target) {
  return crypto.createHash("sha256").update(fs.readFileSync(target)).digest("hex").toUpperCase();
}

function requiredFile(value, name) {
  const target = path.resolve(value || "");
  if (!value || !fs.existsSync(target) || !fs.statSync(target).isFile()) {
    throw new Error(`${name} must reference an existing file.`);
  }
  return target;
}

export function runManifest(manifestPath, continuationPath = null) {
  const manifest = readJson(manifestPath);
  if (manifest.manifest_version !== MANIFEST_RUNNER_VERSION) throw new Error("Unsupported manifest_version.");
  for (const field of ["case_id", "repository_root", "output_root"]) {
    if (!manifest[field]) throw new Error(`${field} is required.`);
  }
  if (!Array.isArray(manifest.source_paths) || manifest.source_paths.length === 0) {
    throw new Error("source_paths must be non-empty.");
  }
  const output = path.resolve(manifest.output_root);
  fs.mkdirSync(output, { recursive: true });
  const entry = path.join(manifest.repository_root, "scripts", "proposal-initial-workflow-v0.1", "invoke-proposal-initial-workflow.ps1");
  requiredFile(entry, "coordinator entry point");
  const writeJson = (name, value) => {
    const target = path.join(output, name);
    fs.writeFileSync(target, `${JSON.stringify(value, null, 2)}\n`, "utf8");
    return target;
  };
  const statePath = (revision) => path.join(output, `workflow-state-${String(revision).padStart(3, "0")}.json`);
  const invoke = (action, state, payload, revision) => {
    const target = statePath(revision);
    const args = ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", entry, "-Action", action];
    if (state) args.push("-StatePath", state);
    args.push("-PayloadPath", payload, "-OutputStatePath", target);
    const result = spawnSync("powershell.exe", args, { cwd: manifest.repository_root, encoding: "utf8" });
    if (result.status !== 0) throw new Error(`${action} failed\n${result.stdout}\n${result.stderr}`);
    return target;
  };

  manifest.source_paths.forEach((source, index) => requiredFile(source, `source_paths[${index}]`));
  for (const [name, value] of Object.entries(manifest.approved_artifacts || {})) {
    requiredFile(value, `approved_artifacts.${name}`);
  }
  requiredFile(manifest.strategy?.candidates_path, "strategy.candidates_path");
  if (!Array.isArray(manifest.strategy?.selected_candidate_ids) || manifest.strategy.selected_candidate_ids.length === 0) {
    throw new Error("strategy.selected_candidate_ids must be non-empty.");
  }

  const acceptedState = path.join(output, "toc-accepted-state.json");
  const receiptPath = path.join(output, "toc-acceptance-receipt.json");
  if (fs.existsSync(statePath(8))) throw new Error("Manifest run is already complete; refusing to overwrite completed state.");
  if (!fs.existsSync(statePath(6))) {
    if (fs.existsSync(statePath(0))) throw new Error("Partial run detected before TOC acceptance; use a fresh output_root.");
    const payload = (revision, name, value) => writeJson(`payload-${String(revision).padStart(3, "0")}-${name}.json`, value);
    let state = invoke("Start", null, payload(0, "start", { case_id: manifest.case_id, source_paths: manifest.source_paths }), 0);
    state = invoke("RegisterAnalysis", state, payload(1, "analysis", {
      analysis_report_path: manifest.approved_artifacts.analysis_report,
      summary_report_path: manifest.approved_artifacts.summary_report,
      semantic_evidence_path: manifest.approved_artifacts.analysis_evidence,
    }), 1);
    state = invoke("ConfirmSummary", state, payload(2, "summary", { approved: true }), 2);
    state = invoke("RecordFoundationInput", state, payload(3, "foundation", manifest.foundation_input), 3);
    state = invoke("RegisterTocDraft", state, payload(4, "toc", {
      baseline_state_path: manifest.approved_artifacts.toc_baseline_state,
      workbook_path: manifest.approved_artifacts.toc_draft_workbook,
      contract_version: manifest.toc.contract_version,
    }), 4);
    state = invoke("AnalyzeTocReturn", state, payload(5, "analyze", {
      returned_workbook_path: manifest.approved_artifacts.returned_workbook,
      report_path: path.join(output, "toc-change-report.json"),
    }), 5);
    invoke("AcceptTocReturn", state, payload(6, "accept", {
      decisions_path: manifest.approved_artifacts.toc_decisions,
      accepted_workbook_path: path.join(output, "toc-accepted.xlsx"),
      accepted_state_path: acceptedState,
      verification_report_path: path.join(output, "toc-accepted-verification.json"),
      acceptance_receipt_path: receiptPath,
    }), 6);
  }

  const evidenceRequest = {
    request_version: "0.1.0",
    case_id: manifest.case_id,
    status: "AWAITING_AER_CORE_STRATEGY_EVIDENCE",
    accepted_toc_state_path: acceptedState,
    accepted_toc_state_sha256: sha256(acceptedState),
    analysis_evidence_sha256: sha256(manifest.approved_artifacts.analysis_evidence),
    strategy_candidates_path: manifest.strategy.candidates_path,
    required_next_input: "A strategy semantic-evidence file bound to this accepted TOC hash, followed by a continuation JSON.",
  };
  writeJson("strategy-evidence-request.json", evidenceRequest);
  if (!continuationPath) return evidenceRequest;

  const continuation = readJson(continuationPath);
  const evidencePath = requiredFile(continuation.semantic_evidence_path, "semantic_evidence_path");
  const proof = readJson(evidencePath);
  if (proof.strategy_bindings?.accepted_toc_state_sha256 !== evidenceRequest.accepted_toc_state_sha256) {
    throw new Error("Strategy evidence is not bound to the current accepted TOC state.");
  }
  const strategyPayload = writeJson("payload-007-strategy.json", {
    strategy_candidates_path: manifest.strategy.candidates_path,
    semantic_evidence_path: evidencePath,
  });
  const strategyState = invoke("RegisterStrategyCandidates", statePath(6), strategyPayload, 7);
  const selectionPayload = writeJson("payload-008-selection.json", {
    selected_candidate_ids: manifest.strategy.selected_candidate_ids,
    deferred: false,
    rationale_path: manifest.strategy.rationale_path || null,
  });
  invoke("ConfirmStrategySelection", strategyState, selectionPayload, 8);
  const finalState = readJson(statePath(8));
  const receipt = readJson(receiptPath);
  const checks = {
    final_complete: finalState.stage === "COMPLETE" && finalState.status === "COMPLETE",
    transition_count: finalState.transition_log.length === 8,
    source_paths_roundtrip: JSON.stringify(finalState.canonical_inputs.source_paths) === JSON.stringify(manifest.source_paths),
    analysis_core: finalState.semantic_execution.analysis.runtime === "AER_CORE",
    strategy_core: finalState.semantic_execution.strategy.runtime === "AER_CORE",
    receipt_registered: finalState.artifacts.acceptance_receipt_sha256 === sha256(receiptPath),
    system_sheets_proved: receipt.system_sheets.status === "PASS",
    rpa_hold: finalState.rpa_release === "HOLD",
  };
  const verification = {
    verification_version: "0.1.0",
    case_id: manifest.case_id,
    outcome: Object.values(checks).every(Boolean) ? "PASS" : "FAIL",
    checks,
    final_state_path: statePath(8),
    accepted_toc_state_sha256: evidenceRequest.accepted_toc_state_sha256,
  };
  writeJson("manifest-run-verification.json", verification);
  if (verification.outcome !== "PASS") throw new Error(`Manifest run verification failed: ${JSON.stringify(checks)}`);
  return verification;
}

const directExecution = process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href;
if (directExecution) {
  const [manifestPath, continuationPath] = process.argv.slice(2);
  if (!manifestPath) throw new Error("Usage: node proposal-initial-manifest-runner.mjs <manifest.json> [strategy-continuation.json]");
  console.log(JSON.stringify(runManifest(manifestPath, continuationPath || null), null, 2));
}
