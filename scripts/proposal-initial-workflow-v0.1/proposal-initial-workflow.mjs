import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";

export const WORKFLOW_VERSION = "0.1.0";
export const SEMANTIC_EVIDENCE_VERSION = "0.1.0";
export const TOC_ACCEPTANCE_RECEIPT_VERSION = "0.1.0";
export const TOC_ACCEPTANCE_ENGINE_VERSION = "0.1.1";
export const STAGES = [
  "SOURCE_INTAKE",
  "SUMMARY_CONFIRMATION",
  "FOUNDATION_INPUT",
  "TOC_DRAFT",
  "TOC_HUMAN_EDIT",
  "TOC_REIMPORT",
  "STRATEGY_CANDIDATES",
  "COMPLETE",
];

const ACTION_STAGE = {
  REGISTER_ANALYSIS: ["SOURCE_INTAKE"],
  CONFIRM_SUMMARY: ["SUMMARY_CONFIRMATION"],
  RECORD_FOUNDATION_INPUT: ["FOUNDATION_INPUT"],
  REGISTER_TOC_DRAFT: ["TOC_DRAFT"],
  RECORD_TOC_ANALYSIS: ["TOC_HUMAN_EDIT"],
  RECORD_TOC_ACCEPTANCE: ["TOC_REIMPORT"],
  REGISTER_STRATEGY_CANDIDATES: ["STRATEGY_CANDIDATES"],
  CONFIRM_STRATEGY_SELECTION: ["STRATEGY_CANDIDATES"],
};

function text(value) {
  return value == null ? "" : String(value).trim();
}

function requireText(value, name) {
  const result = text(value);
  if (!result) throw new Error(`${name} is required.`);
  return result;
}

function requireArray(value, name) {
  if (!Array.isArray(value) || value.length === 0) throw new Error(`${name} must be a non-empty array.`);
  return value;
}

function sha256(filePath) {
  return crypto.createHash("sha256").update(fs.readFileSync(filePath)).digest("hex").toUpperCase();
}

function samePath(left, right) {
  return path.resolve(left).toLowerCase() === path.resolve(right).toLowerCase();
}

function requireExistingFile(value, name) {
  const resolved = path.resolve(requireText(value, name));
  if (!fs.existsSync(resolved) || !fs.statSync(resolved).isFile()) throw new Error(`${name} must reference an existing file.`);
  return resolved;
}

function assertHash(filePath, expected, name) {
  const declared = requireText(expected, `${name}.sha256`).toUpperCase();
  if (!/^[A-F0-9]{64}$/.test(declared)) throw new Error(`${name}.sha256 must be a SHA-256 digest.`);
  if (sha256(filePath) !== declared) throw new Error(`${name} SHA-256 mismatch.`);
}

function requireSemanticEvidence(state, payload, artifactType, outputPaths) {
  const evidencePath = requireExistingFile(payload.semantic_evidence_path, "semantic_evidence_path");
  const proof = readJson(evidencePath);
  if (proof.proof_contract_version !== SEMANTIC_EVIDENCE_VERSION) throw new Error("Unsupported semantic evidence contract version.");
  if (proof.artifact_type !== artifactType) throw new Error(`Semantic evidence artifact_type must be ${artifactType}.`);
  if (proof.case_id !== state.case_id) throw new Error("Semantic evidence case_id does not match workflow state.");
  if (proof.authority?.runtime !== "AER_CORE") throw new Error("Semantic evidence must record AER_CORE runtime.");
  requireText(proof.authority?.digest, "authority.digest");
  requireText(proof.authority?.repository_head, "authority.repository_head");
  if (proof.runtime_selection?.core_required !== true) throw new Error("Semantic evidence must affirm core_required=true.");

  const core = proof.core_evidence || {};
  for (const field of ["problem_definition_present", "facts_assumptions_unknowns_separated", "reasoning_links_present", "bottleneck_six_fields_present", "solution_hypothesis_present"]) {
    if (core[field] !== true) throw new Error(`Semantic evidence requires ${field}=true.`);
  }
  if (!['PASS', 'PASS_CONDITIONAL'].includes(core.direct_validation)) throw new Error("Semantic evidence direct_validation must pass.");
  requireText(core.opposing_review, "core_evidence.opposing_review");
  requireText(core.whole_process_impact, "core_evidence.whole_process_impact");
  requireText(core.global_consistency, "core_evidence.global_consistency");
  if (!['PASS', 'PASS_CONDITIONAL'].includes(core.closure_outcome)) throw new Error("Semantic evidence closure_outcome must pass.");

  const inputs = requireArray(proof.source_inputs, "source_inputs");
  if (inputs.length !== state.canonical_inputs.source_paths.length) throw new Error("Semantic evidence source count does not match canonical inputs.");
  for (const canonical of state.canonical_inputs.source_paths) {
    const match = inputs.find((item) => item?.path && samePath(item.path, canonical));
    if (!match) throw new Error(`Semantic evidence is not bound to canonical source: ${canonical}`);
    const sourcePath = requireExistingFile(match.path, "source_inputs.path");
    assertHash(sourcePath, match.sha256, "source_inputs item");
  }

  const outputs = requireArray(proof.outputs, "outputs");
  for (const expectedPath of outputPaths) {
    const match = outputs.find((item) => item?.path && samePath(item.path, expectedPath));
    if (!match) throw new Error(`Semantic evidence is not bound to output: ${expectedPath}`);
    const outputPath = requireExistingFile(match.path, "outputs.path");
    assertHash(outputPath, match.sha256, "outputs item");
  }
  return { evidencePath, evidenceSha256: sha256(evidencePath), proof };
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function now() {
  return new Date().toISOString();
}

function assertState(state) {
  if (!state || state.workflow_version !== WORKFLOW_VERSION) throw new Error("Unsupported or missing workflow state.");
  if (!STAGES.includes(state.stage)) throw new Error(`Unsupported workflow stage: ${state.stage}`);
  if (state.rpa_release !== "HOLD") throw new Error("Proposal initial workflow cannot release RPA.");
  if (!Array.isArray(state.transition_log) || !Array.isArray(state.external_information)) {
    throw new Error("Workflow audit collections are missing.");
  }
}

function assertStage(state, action) {
  const allowed = ACTION_STAGE[action] || [];
  if (!allowed.includes(state.stage)) throw new Error(`${action} is not permitted from ${state.stage}.`);
}

function transition(state, action, nextStage, detail = {}) {
  const next = clone(state);
  next.revision += 1;
  next.updated_at = now();
  next.stage = nextStage;
  next.transition_log.push({
    revision: next.revision,
    action,
    from_stage: state.stage,
    to_stage: nextStage,
    at: next.updated_at,
    detail,
  });
  return next;
}

function start(payload) {
  const created = now();
  const caseId = requireText(payload.case_id, "case_id");
  const sources = requireArray(payload.source_paths, "source_paths").map((item) => requireText(item, "source_paths item"));
  return {
    workflow_version: WORKFLOW_VERSION,
    workflow_id: text(payload.workflow_id) || `PIW-${caseId}`,
    case_id: caseId,
    stage: "SOURCE_INTAKE",
    status: "ACTIVE",
    revision: 0,
    created_at: created,
    updated_at: created,
    canonical_inputs: { source_paths: sources },
    artifacts: {},
    human_gates: { summary_confirmed: false, toc_changes_accepted: false },
    foundation_input: null,
    external_information: [],
    pending_impacts: [],
    regeneration_authorizations: [],
    transition_log: [],
    next_action: "RUN_RFP_ANALYSIS",
    rpa_release: "HOLD",
    limitations: [
      "The coordinator registers LLM and human outputs; it does not replace AER Core reasoning.",
      "External information never triggers automatic regeneration.",
      "PPT generation and RPA execution are outside this workflow version.",
    ],
  };
}

function registerAnalysis(state, payload) {
  assertStage(state, "REGISTER_ANALYSIS");
  const analysisPath = requireExistingFile(payload.analysis_report_path, "analysis_report_path");
  const summaryPath = requireExistingFile(payload.summary_report_path, "summary_report_path");
  const evidence = requireSemanticEvidence(state, payload, "RFP_ANALYSIS", [analysisPath, summaryPath]);
  const next = transition(state, "REGISTER_ANALYSIS", "SUMMARY_CONFIRMATION");
  next.artifacts.analysis_report_path = analysisPath;
  next.artifacts.summary_report_path = summaryPath;
  next.artifacts.analysis_semantic_evidence_path = evidence.evidencePath;
  next.artifacts.analysis_semantic_evidence_sha256 = evidence.evidenceSha256;
  next.semantic_execution = {
    analysis: {
      runtime: evidence.proof.authority.runtime,
      authority_digest: evidence.proof.authority.digest,
      repository_head: evidence.proof.authority.repository_head,
      closure_outcome: evidence.proof.core_evidence.closure_outcome,
    },
  };
  next.next_action = "REQUEST_HUMAN_SUMMARY_CONFIRMATION";
  return next;
}

function confirmSummary(state, payload) {
  assertStage(state, "CONFIRM_SUMMARY");
  if (payload.approved !== true) throw new Error("Summary confirmation requires approved=true. Corrections must be registered as a revised analysis.");
  const next = transition(state, "CONFIRM_SUMMARY", "FOUNDATION_INPUT", { human_command: true });
  next.human_gates.summary_confirmed = true;
  next.next_action = "REQUEST_FOUNDATION_INPUT";
  return next;
}

function recordFoundationInput(state, payload) {
  assertStage(state, "RECORD_FOUNDATION_INPUT");
  const mode = requireText(payload.proposal_mode, "proposal_mode").toUpperCase();
  if (!["SOLO", "CONSORTIUM", "UNRESOLVED"].includes(mode)) throw new Error("proposal_mode must be SOLO, CONSORTIUM, or UNRESOLVED.");
  const participantCount = payload.participant_count == null ? null : Number(payload.participant_count);
  if (mode === "CONSORTIUM" && (!Number.isInteger(participantCount) || participantCount < 2)) {
    throw new Error("CONSORTIUM requires participant_count of at least 2.");
  }
  const consistency = requireText(payload.rfp_consistency_status, "rfp_consistency_status").toUpperCase();
  if (!["PASS", "UNRESOLVED", "CONFLICT"].includes(consistency)) {
    throw new Error("rfp_consistency_status must be PASS, UNRESOLVED, or CONFLICT.");
  }
  if (consistency === "CONFLICT") throw new Error("An RFP conflict must be resolved before TOC generation.");
  const next = transition(state, "RECORD_FOUNDATION_INPUT", "TOC_DRAFT");
  next.foundation_input = {
    proposal_mode: mode,
    participant_count: participantCount,
    related_performance_status: text(payload.related_performance_status) || "UNPROVIDED",
    rfp_consistency_status: consistency,
    proceeded_without_optional_input: payload.proceeded_without_optional_input === true,
  };
  next.next_action = "GENERATE_TOC_DRAFT";
  return next;
}

function registerTocDraft(state, payload) {
  assertStage(state, "REGISTER_TOC_DRAFT");
  const next = transition(state, "REGISTER_TOC_DRAFT", "TOC_HUMAN_EDIT");
  next.artifacts.toc_baseline_state_path = requireText(payload.baseline_state_path, "baseline_state_path");
  next.artifacts.toc_workbook_path = requireText(payload.workbook_path, "workbook_path");
  const contractVersion = requireText(payload.contract_version, "contract_version");
  if (contractVersion !== "0.3.0") throw new Error("The initial workflow coordinator currently requires TOC contract 0.3.0.");
  next.artifacts.toc_contract_version = contractVersion;
  next.next_action = "WAIT_FOR_HUMAN_TOC_EDIT";
  return next;
}

function recordTocAnalysis(state, payload) {
  assertStage(state, "RECORD_TOC_ANALYSIS");
  const report = payload.report;
  if (!report || !report.summary) throw new Error("A parsed roundtrip report is required.");
  const next = transition(state, "RECORD_TOC_ANALYSIS", "TOC_REIMPORT");
  next.artifacts.returned_workbook_path = requireText(payload.returned_workbook_path, "returned_workbook_path");
  next.artifacts.toc_change_report_path = requireText(payload.report_path, "report_path");
  next.toc_change_summary = clone(report.summary);
  const recommendation = requireText(report.release_recommendation, "release_recommendation");
  if (!["HOLD", "HUMAN_CONFIRMATION_REQUIRED"].includes(recommendation)) throw new Error("Invalid TOC release recommendation.");
  next.toc_release_recommendation = recommendation;
  next.next_action = report.summary.material_changes > 0 ? "REQUEST_HUMAN_CHANGE_DECISION" : "REQUEST_HUMAN_TOC_CONFIRMATION";
  return next;
}

function recordTocAcceptance(state, payload) {
  assertStage(state, "RECORD_TOC_ACCEPTANCE");
  const verification = payload.verification;
  if (!verification?.summary || verification.summary.material_changes !== 0 || verification.summary.blocking_changes !== 0 || verification.summary.structural_changes !== 0) {
    throw new Error("Accepted TOC verification must contain zero material, blocking, and structural changes.");
  }
  if (verification.formula_integrity?.status !== "PASS") throw new Error("Accepted TOC formula integrity must pass.");
  if (verification.release_recommendation !== "HUMAN_CONFIRMATION_REQUIRED") {
    throw new Error("Accepted TOC verification must still require human confirmation and keep RPA unreleased.");
  }
  const acceptedWorkbookPath = requireExistingFile(payload.accepted_workbook_path, "accepted_workbook_path");
  const acceptedStatePath = requireExistingFile(payload.accepted_state_path, "accepted_state_path");
  const verificationReportPath = requireExistingFile(payload.verification_report_path, "verification_report_path");
  const decisionsPath = requireExistingFile(payload.decisions_path, "decisions_path");
  const receiptPath = requireExistingFile(payload.acceptance_receipt_path, "acceptance_receipt_path");
  const reportVerification = readJson(verificationReportPath);
  if (JSON.stringify(reportVerification) !== JSON.stringify(verification)) {
    throw new Error("Registered TOC verification does not match verification_report_path.");
  }
  const receipt = readJson(receiptPath);
  if (payload.receipt && JSON.stringify(payload.receipt) !== JSON.stringify(receipt)) {
    throw new Error("Registered TOC acceptance receipt does not match acceptance_receipt_path.");
  }
  if (receipt.receipt_version !== TOC_ACCEPTANCE_RECEIPT_VERSION) throw new Error("Unsupported TOC acceptance receipt version.");
  if (receipt.acceptance_engine_version !== TOC_ACCEPTANCE_ENGINE_VERSION) throw new Error("Unsupported TOC acceptance engine version.");
  if (receipt.case_id !== state.case_id) throw new Error("TOC acceptance receipt case_id does not match workflow state.");
  const requiredSheets = ["SYS_SNAPSHOT", "SYS_MAPPING", "SYS_RPA_SPEC", "CHANGE_REVIEW"];
  if (receipt.system_sheets?.status !== "PASS" || !requiredSheets.every((name) => receipt.system_sheets.required?.includes(name))) {
    throw new Error("TOC acceptance receipt must prove all required system sheets.");
  }
  if (receipt.rpa_release !== "HOLD") throw new Error("TOC acceptance receipt must keep RPA on HOLD.");
  const bindings = [
    [receipt.inputs?.workbook, state.artifacts.returned_workbook_path, "receipt.inputs.workbook"],
    [receipt.inputs?.baseline, state.artifacts.toc_baseline_state_path, "receipt.inputs.baseline"],
    [receipt.inputs?.decisions, decisionsPath, "receipt.inputs.decisions"],
    [receipt.outputs?.accepted_workbook, acceptedWorkbookPath, "receipt.outputs.accepted_workbook"],
    [receipt.outputs?.accepted_state, acceptedStatePath, "receipt.outputs.accepted_state"],
    [receipt.outputs?.verification_report, verificationReportPath, "receipt.outputs.verification_report"],
  ];
  for (const [binding, expectedPath, name] of bindings) {
    if (!binding?.path || !samePath(binding.path, expectedPath)) throw new Error(`${name} path mismatch.`);
    const boundPath = requireExistingFile(binding.path, `${name}.path`);
    assertHash(boundPath, binding.sha256, name);
  }
  if (JSON.stringify(receipt.verification?.summary) !== JSON.stringify(verification.summary)
      || receipt.verification?.formula_integrity !== "PASS"
      || receipt.verification?.release_recommendation !== "HUMAN_CONFIRMATION_REQUIRED") {
    throw new Error("TOC acceptance receipt verification does not match the registered verification report.");
  }
  const next = transition(state, "RECORD_TOC_ACCEPTANCE", "STRATEGY_CANDIDATES", { human_command: true });
  next.artifacts.accepted_workbook_path = acceptedWorkbookPath;
  next.artifacts.accepted_state_path = acceptedStatePath;
  next.artifacts.acceptance_verification_path = verificationReportPath;
  next.artifacts.acceptance_receipt_path = receiptPath;
  next.artifacts.acceptance_receipt_sha256 = sha256(receiptPath);
  next.artifacts.acceptance_engine_version = receipt.acceptance_engine_version;
  next.human_gates.toc_changes_accepted = true;
  next.toc_acceptance_summary = clone(verification.summary);
  next.next_action = "GENERATE_STRATEGY_CANDIDATES";
  return next;
}

function registerStrategyCandidates(state, payload) {
  assertStage(state, "REGISTER_STRATEGY_CANDIDATES");
  if (!state.artifacts.analysis_semantic_evidence_sha256) throw new Error("Strategy registration requires approved RFP analysis semantic evidence.");
  if (!state.artifacts.accepted_state_path) throw new Error("Strategy registration requires an accepted TOC state.");
  const strategyPath = requireExistingFile(payload.strategy_candidates_path, "strategy_candidates_path");
  const evidence = requireSemanticEvidence(state, payload, "STRATEGY", [strategyPath]);
  const bindings = evidence.proof.strategy_bindings || {};
  if (text(bindings.approved_rfp_analysis_proof_sha256).toUpperCase() !== state.artifacts.analysis_semantic_evidence_sha256) {
    throw new Error("Strategy evidence is not bound to the approved RFP analysis proof.");
  }
  const acceptedStatePath = requireExistingFile(state.artifacts.accepted_state_path, "accepted_state_path");
  if (text(bindings.accepted_toc_state_sha256).toUpperCase() !== sha256(acceptedStatePath)) {
    throw new Error("Strategy evidence is not bound to the accepted TOC state.");
  }
  requireText(bindings.foundation_input_status, "strategy_bindings.foundation_input_status");
  const next = transition(state, "REGISTER_STRATEGY_CANDIDATES", "STRATEGY_CANDIDATES");
  next.artifacts.strategy_candidates_path = strategyPath;
  next.artifacts.strategy_semantic_evidence_path = evidence.evidencePath;
  next.artifacts.strategy_semantic_evidence_sha256 = evidence.evidenceSha256;
  next.semantic_execution = next.semantic_execution || {};
  next.semantic_execution.strategy = {
    runtime: evidence.proof.authority.runtime,
    authority_digest: evidence.proof.authority.digest,
    repository_head: evidence.proof.authority.repository_head,
    closure_outcome: evidence.proof.core_evidence.closure_outcome,
  };
  next.next_action = "HUMAN_STRATEGY_REVIEW";
  return next;
}

function confirmStrategySelection(state, payload) {
  assertStage(state, "CONFIRM_STRATEGY_SELECTION");
  const selected = Array.isArray(payload.selected_candidate_ids) ? payload.selected_candidate_ids.map(text).filter(Boolean) : [];
  if (selected.length === 0 && payload.deferred !== true) {
    throw new Error("Strategy completion requires selected_candidate_ids or deferred=true.");
  }
  const next = transition(state, "CONFIRM_STRATEGY_SELECTION", "COMPLETE", { human_command: true });
  next.strategy_selection = {
    selected_candidate_ids: selected,
    deferred: payload.deferred === true,
    rationale_path: text(payload.rationale_path) || null,
  };
  next.status = "COMPLETE";
  next.next_action = "INITIAL_WORKFLOW_COMPLETE";
  return next;
}

function addExternalInformation(state, payload) {
  const next = transition(state, "ADD_EXTERNAL_INFORMATION", state.stage, { stage_preserved: true });
  next.external_information.push({
    information_id: text(payload.information_id) || `EXT-${String(next.external_information.length + 1).padStart(3, "0")}`,
    source_path: requireText(payload.source_path, "source_path"),
    description: requireText(payload.description, "description"),
    received_at: text(payload.received_at) || next.updated_at,
    impact_status: "PENDING_REVIEW",
  });
  next.pending_impacts.push({
    information_id: next.external_information.at(-1).information_id,
    current_stage: state.stage,
    regeneration_authorized: false,
  });
  next.next_action = "REVIEW_EXTERNAL_INFORMATION_IMPACT";
  return next;
}

function authorizeRegeneration(state, payload) {
  const target = requireText(payload.target_stage, "target_stage").toUpperCase();
  if (!["SOURCE_INTAKE", "TOC_DRAFT", "STRATEGY_CANDIDATES"].includes(target)) {
    throw new Error("target_stage must be SOURCE_INTAKE, TOC_DRAFT, or STRATEGY_CANDIDATES.");
  }
  if (payload.human_command !== true) throw new Error("Regeneration requires human_command=true.");
  const next = transition(state, "AUTHORIZE_REGENERATION", target, { human_command: true, reason: requireText(payload.reason, "reason") });
  next.regeneration_authorizations.push({ target_stage: target, reason: payload.reason, authorized_at: next.updated_at });
  next.pending_impacts = next.pending_impacts.map((item) => ({ ...item, regeneration_authorized: true }));
  const removeArtifacts = (names) => names.forEach((name) => { delete next.artifacts[name]; });
  if (target === "SOURCE_INTAKE") {
    next.human_gates.summary_confirmed = false;
    next.human_gates.toc_changes_accepted = false;
    next.foundation_input = null;
    delete next.toc_change_summary;
    delete next.toc_release_recommendation;
    delete next.toc_acceptance_summary;
    delete next.strategy_selection;
    delete next.semantic_execution;
    removeArtifacts(["analysis_report_path", "summary_report_path", "analysis_semantic_evidence_path", "analysis_semantic_evidence_sha256", "toc_baseline_state_path", "toc_workbook_path", "toc_contract_version", "returned_workbook_path", "toc_change_report_path", "accepted_workbook_path", "accepted_state_path", "acceptance_verification_path", "acceptance_receipt_path", "acceptance_receipt_sha256", "acceptance_engine_version", "strategy_candidates_path", "strategy_semantic_evidence_path", "strategy_semantic_evidence_sha256"]);
  } else if (target === "TOC_DRAFT") {
    next.human_gates.toc_changes_accepted = false;
    delete next.toc_change_summary;
    delete next.toc_release_recommendation;
    delete next.toc_acceptance_summary;
    delete next.strategy_selection;
    if (next.semantic_execution) delete next.semantic_execution.strategy;
    removeArtifacts(["toc_baseline_state_path", "toc_workbook_path", "toc_contract_version", "returned_workbook_path", "toc_change_report_path", "accepted_workbook_path", "accepted_state_path", "acceptance_verification_path", "acceptance_receipt_path", "acceptance_receipt_sha256", "acceptance_engine_version", "strategy_candidates_path", "strategy_semantic_evidence_path", "strategy_semantic_evidence_sha256"]);
  } else {
    delete next.strategy_selection;
    if (next.semantic_execution) delete next.semantic_execution.strategy;
    removeArtifacts(["strategy_candidates_path", "strategy_semantic_evidence_path", "strategy_semantic_evidence_sha256"]);
  }
  next.status = "ACTIVE";
  next.next_action = target === "SOURCE_INTAKE" ? "RUN_RFP_ANALYSIS" : target === "TOC_DRAFT" ? "GENERATE_TOC_DRAFT" : "GENERATE_STRATEGY_CANDIDATES";
  return next;
}

export function applyAction(action, state, payload = {}) {
  const normalized = requireText(action, "action").toUpperCase();
  if (normalized === "START") return start(payload);
  assertState(state);
  switch (normalized) {
    case "REGISTER_ANALYSIS": return registerAnalysis(state, payload);
    case "CONFIRM_SUMMARY": return confirmSummary(state, payload);
    case "RECORD_FOUNDATION_INPUT": return recordFoundationInput(state, payload);
    case "REGISTER_TOC_DRAFT": return registerTocDraft(state, payload);
    case "RECORD_TOC_ANALYSIS": return recordTocAnalysis(state, payload);
    case "RECORD_TOC_ACCEPTANCE": return recordTocAcceptance(state, payload);
    case "REGISTER_STRATEGY_CANDIDATES": return registerStrategyCandidates(state, payload);
    case "CONFIRM_STRATEGY_SELECTION": return confirmStrategySelection(state, payload);
    case "ADD_EXTERNAL_INFORMATION": return addExternalInformation(state, payload);
    case "AUTHORIZE_REGENERATION": return authorizeRegeneration(state, payload);
    default: throw new Error(`Unsupported workflow action: ${normalized}`);
  }
}

function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8").replace(/^\uFEFF/, ""));
}

function writeJsonAtomic(filePath, value) {
  const output = path.resolve(filePath);
  fs.mkdirSync(path.dirname(output), { recursive: true });
  const temporary = `${output}.tmp-${process.pid}-${Date.now()}`;
  try {
    fs.writeFileSync(temporary, `${JSON.stringify(value, null, 2)}\n`, "utf8");
    fs.renameSync(temporary, output);
  } finally {
    if (fs.existsSync(temporary)) fs.rmSync(temporary, { force: true });
  }
}

export function runCli(argv) {
  const [action, statePath, payloadPath, outputPath] = argv;
  if (!action || !payloadPath || !outputPath) {
    throw new Error("Usage: node proposal-initial-workflow.mjs <action> <state-or-dash> <payload.json> <output-state.json>");
  }
  const resolvedOutput = path.resolve(outputPath);
  const resolvedState = statePath === "-" ? null : path.resolve(statePath);
  if (resolvedState && resolvedState.toLowerCase() === resolvedOutput.toLowerCase()) {
    throw new Error("Output state must be distinct from input state.");
  }
  const state = resolvedState ? readJson(resolvedState) : null;
  const payload = readJson(path.resolve(payloadPath));
  const next = applyAction(action, state, payload);
  writeJsonAtomic(resolvedOutput, next);
  process.stdout.write(`${JSON.stringify({ workflow_id: next.workflow_id, stage: next.stage, revision: next.revision, next_action: next.next_action })}\n`);
}

if (process.argv[1] && fileURLToPath(import.meta.url) === path.resolve(process.argv[1])) {
  try {
    runCli(process.argv.slice(2));
  } catch (error) {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  }
}
