import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import crypto from "node:crypto";
import { applyAction, WORKFLOW_VERSION } from "./proposal-initial-workflow.mjs";

const scratch = fs.mkdtempSync(path.join(os.tmpdir(), "aer-piw-core-proof-"));
const file = (name, content = name) => {
  const target = path.join(scratch, name);
  fs.writeFileSync(target, content, "utf8");
  return target;
};
const hash = (target) => crypto.createHash("sha256").update(fs.readFileSync(target)).digest("hex").toUpperCase();
const writeJson = (name, value) => file(name, `${JSON.stringify(value, null, 2)}\n`);
const writeProof = (name, artifactType, sources, outputs, overrides = {}) => {
  const proof = {
    proof_contract_version: "0.1.0",
    artifact_type: artifactType,
    case_id: "CASE-TEST",
    source_inputs: sources.map((source) => ({ path: source, sha256: hash(source) })),
    authority: { digest: "authority-digest", repository_head: "repository-head", runtime: "AER_CORE" },
    runtime_selection: { core_required: true, reason: "material judgment" },
    core_evidence: {
      problem_definition_present: true,
      facts_assumptions_unknowns_separated: true,
      reasoning_links_present: true,
      bottleneck_six_fields_present: true,
      solution_hypothesis_present: true,
      direct_validation: "PASS_CONDITIONAL",
      opposing_review: "ACCEPT_AND_REVISE",
      whole_process_impact: "REVIEWED",
      global_consistency: "PASS_CONDITIONAL",
      closure_outcome: "PASS_CONDITIONAL",
    },
    outputs: outputs.map((output) => ({ path: output, sha256: hash(output) })),
    ...overrides,
  };
  return file(name, `${JSON.stringify(proof, null, 2)}\n`);
};

try {
const rfp = file("rfp.pdf", "synthetic rfp");
const task = file("task.pdf", "synthetic task");
const analysisFile = file("analysis.json", "analysis");
const summaryFile = file("summary.md", "summary");
const analysisProof = writeProof("analysis-proof.json", "RFP_ANALYSIS", [rfp, task], [analysisFile, summaryFile]);

const start = applyAction("START", null, { case_id: "CASE-TEST", source_paths: [rfp, task] });
assert.equal(start.workflow_version, WORKFLOW_VERSION);
assert.equal(start.stage, "SOURCE_INTAKE");
assert.equal(start.rpa_release, "HOLD");

assert.throws(() => applyAction("REGISTER_ANALYSIS", start, { analysis_report_path: analysisFile, summary_report_path: summaryFile }), /semantic_evidence_path/);
const analysis = applyAction("REGISTER_ANALYSIS", start, { analysis_report_path: analysisFile, summary_report_path: summaryFile, semantic_evidence_path: analysisProof });
assert.equal(analysis.stage, "SUMMARY_CONFIRMATION");
assert.equal(analysis.semantic_execution.analysis.runtime, "AER_CORE");
assert.equal(analysis.artifacts.analysis_semantic_evidence_sha256, hash(analysisProof));

const noRuntimeProof = writeProof("analysis-proof-no-runtime.json", "RFP_ANALYSIS", [rfp, task], [analysisFile, summaryFile], {
  authority: { digest: "authority-digest", repository_head: "repository-head" },
});
assert.throws(() => applyAction("REGISTER_ANALYSIS", start, { analysis_report_path: analysisFile, summary_report_path: summaryFile, semantic_evidence_path: noRuntimeProof }), /AER_CORE runtime/);

const noClosureProof = writeProof("analysis-proof-no-closure.json", "RFP_ANALYSIS", [rfp, task], [analysisFile, summaryFile]);
const noClosure = JSON.parse(fs.readFileSync(noClosureProof, "utf8"));
delete noClosure.core_evidence.closure_outcome;
fs.writeFileSync(noClosureProof, JSON.stringify(noClosure), "utf8");
assert.throws(() => applyAction("REGISTER_ANALYSIS", start, { analysis_report_path: analysisFile, summary_report_path: summaryFile, semantic_evidence_path: noClosureProof }), /closure_outcome/);

const tamperProof = writeProof("analysis-proof-tamper.json", "RFP_ANALYSIS", [rfp, task], [analysisFile, summaryFile]);
fs.appendFileSync(analysisFile, "tampered", "utf8");
assert.throws(() => applyAction("REGISTER_ANALYSIS", start, { analysis_report_path: analysisFile, summary_report_path: summaryFile, semantic_evidence_path: tamperProof }), /SHA-256 mismatch/);
fs.writeFileSync(analysisFile, "analysis", "utf8");
assert.throws(() => applyAction("REGISTER_TOC_DRAFT", analysis, {}), /not permitted/);
assert.throws(() => applyAction("CONFIRM_SUMMARY", analysis, { approved: false }), /approved=true/);

const confirmed = applyAction("CONFIRM_SUMMARY", analysis, { approved: true });
const foundation = applyAction("RECORD_FOUNDATION_INPUT", confirmed, {
  proposal_mode: "CONSORTIUM",
  participant_count: 3,
  related_performance_status: "PROVIDED",
  rfp_consistency_status: "PASS",
});
assert.equal(foundation.stage, "TOC_DRAFT");
assert.throws(() => applyAction("RECORD_FOUNDATION_INPUT", confirmed, {
  proposal_mode: "CONSORTIUM", participant_count: 1, rfp_consistency_status: "PASS",
}), /at least 2/);
assert.throws(() => applyAction("RECORD_FOUNDATION_INPUT", confirmed, {
  proposal_mode: "CONSORTIUM", participant_count: 2, rfp_consistency_status: "CONFLICT",
}), /must be resolved/);

const toc = applyAction("REGISTER_TOC_DRAFT", foundation, {
  baseline_state_path: "toc-state.json",
  workbook_path: "toc.xlsx",
  contract_version: "0.3.0",
});
assert.equal(toc.stage, "TOC_HUMAN_EDIT");

const withExternal = applyAction("ADD_EXTERNAL_INFORMATION", toc, {
  source_path: "notice.pdf",
  description: "Consortium notice received later",
});
assert.equal(withExternal.stage, "TOC_HUMAN_EDIT");
assert.equal(withExternal.pending_impacts[0].regeneration_authorized, false);
assert.equal(withExternal.next_action, "REVIEW_EXTERNAL_INFORMATION_IMPACT");

const analysisReport = {
  summary: { rows_read: 10, baseline_rows: 10, material_changes: 1, blocking_changes: 0, structural_changes: 0 },
  release_recommendation: "HUMAN_CONFIRMATION_REQUIRED",
};
const reimport = applyAction("RECORD_TOC_ANALYSIS", withExternal, {
  returned_workbook_path: "toc-edited.xlsx",
  report_path: "changes.json",
  report: analysisReport,
});
assert.equal(reimport.stage, "TOC_REIMPORT");

assert.throws(() => applyAction("RECORD_TOC_ACCEPTANCE", reimport, {
  verification: { summary: { material_changes: 1, blocking_changes: 0, structural_changes: 0 }, formula_integrity: { status: "PASS" } },
}), /zero material/);

const acceptedWorkbook = file("accepted.xlsx", "accepted workbook");
const acceptedStateFile = file("accepted.json", "accepted state");
const decisionsFile = file("decisions.json", "accepted decisions");
const verification = {
  summary: { material_changes: 0, blocking_changes: 0, structural_changes: 0 },
  formula_integrity: { status: "PASS" },
  release_recommendation: "HUMAN_CONFIRMATION_REQUIRED",
};
const verificationFile = writeJson("verification.json", verification);
const returnedWorkbook = file("toc-edited.xlsx", "returned workbook");
const baselineFile = file("toc-state.json", "baseline state");
reimport.artifacts.returned_workbook_path = returnedWorkbook;
reimport.artifacts.toc_baseline_state_path = baselineFile;
const receipt = {
  receipt_version: "0.1.0",
  acceptance_engine_version: "0.1.1",
  case_id: "CASE-TEST",
  inputs: {
    workbook: { path: returnedWorkbook, sha256: hash(returnedWorkbook) },
    baseline: { path: baselineFile, sha256: hash(baselineFile) },
    decisions: { path: decisionsFile, sha256: hash(decisionsFile) },
  },
  outputs: {
    accepted_workbook: { path: acceptedWorkbook, sha256: hash(acceptedWorkbook) },
    accepted_state: { path: acceptedStateFile, sha256: hash(acceptedStateFile) },
    verification_report: { path: verificationFile, sha256: hash(verificationFile) },
  },
  system_sheets: { status: "PASS", required: ["SYS_SNAPSHOT", "SYS_MAPPING", "SYS_RPA_SPEC", "CHANGE_REVIEW"], recovered: [] },
  verification: { summary: verification.summary, formula_integrity: "PASS", release_recommendation: "HUMAN_CONFIRMATION_REQUIRED" },
  rpa_release: "HOLD",
};
const receiptFile = writeJson("acceptance-receipt.json", receipt);
const acceptancePayload = {
  accepted_workbook_path: acceptedWorkbook,
  accepted_state_path: acceptedStateFile,
  verification_report_path: verificationFile,
  decisions_path: decisionsFile,
  acceptance_receipt_path: receiptFile,
  verification,
  receipt,
};
assert.throws(() => applyAction("RECORD_TOC_ACCEPTANCE", reimport, { ...acceptancePayload, acceptance_receipt_path: undefined }), /acceptance_receipt_path/);
const tamperedReceipt = structuredClone(receipt);
tamperedReceipt.outputs.accepted_state.sha256 = "0".repeat(64);
assert.throws(() => applyAction("RECORD_TOC_ACCEPTANCE", reimport, { ...acceptancePayload, receipt: tamperedReceipt }), /does not match acceptance_receipt_path/);
const tamperedReceiptFile = writeJson("tampered-acceptance-receipt.json", tamperedReceipt);
assert.throws(() => applyAction("RECORD_TOC_ACCEPTANCE", reimport, { ...acceptancePayload, acceptance_receipt_path: tamperedReceiptFile, receipt: tamperedReceipt }), /SHA-256 mismatch/);
const accepted = applyAction("RECORD_TOC_ACCEPTANCE", reimport, acceptancePayload);
assert.equal(accepted.stage, "STRATEGY_CANDIDATES");
assert.equal(accepted.rpa_release, "HOLD");
assert.equal(accepted.artifacts.acceptance_engine_version, "0.1.1");
assert.equal(accepted.artifacts.acceptance_receipt_sha256, hash(receiptFile));

const strategyFile = file("strategy.md", "strategy");
const strategyProof = writeProof("strategy-proof.json", "STRATEGY", [rfp, task], [strategyFile], {
  strategy_bindings: {
    approved_rfp_analysis_proof_sha256: accepted.artifacts.analysis_semantic_evidence_sha256,
    accepted_toc_state_sha256: hash(accepted.artifacts.accepted_state_path),
    foundation_input_status: "PROVIDED",
  },
});
assert.throws(() => applyAction("REGISTER_STRATEGY_CANDIDATES", accepted, { strategy_candidates_path: strategyFile }), /semantic_evidence_path/);
const wrongBindingProof = writeProof("strategy-proof-wrong-binding.json", "STRATEGY", [rfp, task], [strategyFile], {
  strategy_bindings: { approved_rfp_analysis_proof_sha256: "0".repeat(64), accepted_toc_state_sha256: hash(accepted.artifacts.accepted_state_path), foundation_input_status: "PROVIDED" },
});
assert.throws(() => applyAction("REGISTER_STRATEGY_CANDIDATES", accepted, { strategy_candidates_path: strategyFile, semantic_evidence_path: wrongBindingProof }), /approved RFP analysis proof/);
const complete = applyAction("REGISTER_STRATEGY_CANDIDATES", accepted, { strategy_candidates_path: strategyFile, semantic_evidence_path: strategyProof });
assert.equal(complete.stage, "STRATEGY_CANDIDATES");
assert.equal(complete.status, "ACTIVE");
assert.equal(complete.semantic_execution.strategy.runtime, "AER_CORE");
assert.throws(() => applyAction("CONFIRM_STRATEGY_SELECTION", complete, {}), /selected_candidate_ids/);
const selected = applyAction("CONFIRM_STRATEGY_SELECTION", complete, { selected_candidate_ids: ["STRATEGY-01"] });
assert.equal(selected.stage, "COMPLETE");
assert.equal(selected.status, "COMPLETE");

const revised = applyAction("ADD_EXTERNAL_INFORMATION", selected, { source_path: "qa.pdf", description: "Late official Q&A" });
const authorized = applyAction("AUTHORIZE_REGENERATION", revised, {
  target_stage: "TOC_DRAFT",
  reason: "Official Q&A changes the strategic TOC allocation.",
  human_command: true,
});
assert.equal(authorized.stage, "TOC_DRAFT");
assert.equal(authorized.pending_impacts[0].regeneration_authorized, true);
assert.equal(authorized.human_gates.toc_changes_accepted, false);
assert.equal(authorized.artifacts.accepted_state_path, undefined);
assert.throws(() => applyAction("AUTHORIZE_REGENERATION", revised, {
  target_stage: "TOC_DRAFT", reason: "No human command", human_command: false,
}), /human_command=true/);

console.log("PASS: Proposal initial workflow coordinator v0.1.0");
} finally {
  fs.rmSync(scratch, { recursive: true, force: true });
}
