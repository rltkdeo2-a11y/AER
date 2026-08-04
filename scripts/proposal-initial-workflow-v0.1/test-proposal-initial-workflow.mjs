import assert from "node:assert/strict";
import { applyAction, WORKFLOW_VERSION } from "./proposal-initial-workflow.mjs";

const start = applyAction("START", null, { case_id: "CASE-TEST", source_paths: ["rfp.pdf", "task.pdf"] });
assert.equal(start.workflow_version, WORKFLOW_VERSION);
assert.equal(start.stage, "SOURCE_INTAKE");
assert.equal(start.rpa_release, "HOLD");

const analysis = applyAction("REGISTER_ANALYSIS", start, { analysis_report_path: "analysis.json", summary_report_path: "summary.md" });
assert.equal(analysis.stage, "SUMMARY_CONFIRMATION");
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

const accepted = applyAction("RECORD_TOC_ACCEPTANCE", reimport, {
  accepted_workbook_path: "accepted.xlsx",
  accepted_state_path: "accepted.json",
  verification_report_path: "verification.json",
  verification: {
    summary: { material_changes: 0, blocking_changes: 0, structural_changes: 0 },
    formula_integrity: { status: "PASS" },
    release_recommendation: "HUMAN_CONFIRMATION_REQUIRED",
  },
});
assert.equal(accepted.stage, "STRATEGY_CANDIDATES");
assert.equal(accepted.rpa_release, "HOLD");

const complete = applyAction("REGISTER_STRATEGY_CANDIDATES", accepted, { strategy_candidates_path: "strategy.md" });
assert.equal(complete.stage, "STRATEGY_CANDIDATES");
assert.equal(complete.status, "ACTIVE");
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
