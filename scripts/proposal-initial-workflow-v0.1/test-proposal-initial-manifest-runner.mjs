import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";
import { normalizeState } from "./aer-toc-roundtrip-engine.mjs";
import { runManifest } from "./proposal-initial-manifest-runner.mjs";

const [fixturePath, tempRoot, repositoryRoot] = process.argv.slice(2);
if (!fixturePath || !tempRoot || !repositoryRoot) {
  throw new Error("Usage: node test-proposal-initial-manifest-runner.mjs <fixture.json> <temp-root> <repository-root>");
}
const write = (name, content) => {
  const target = path.join(tempRoot, name);
  fs.writeFileSync(target, content, "utf8");
  return target;
};
const writeJson = (name, value) => write(name, `${JSON.stringify(value, null, 2)}\n`);
const hash = (target) => crypto.createHash("sha256").update(fs.readFileSync(target)).digest("hex").toUpperCase();
const state = normalizeState(JSON.parse(fs.readFileSync(fixturePath, "utf8")));
state.baseline_snapshot = state.toc_nodes.map((node) => ({
  node_id: node.node_id, volume_id: node.volume_id, page_budget_id: node.page_budget_id,
  parent_id: node.parent_id, level: node.level, title: node.title,
  requirement_ids: [...(node.requirement_ids || [])], a3_checked: Boolean(node.a3_checked),
  physical_sheets: node.physical_sheets, official_fixed: Boolean(node.official_fixed)
}));
const baseline = writeJson("baseline.json", state);
const source = write("한글-제안요청서.pdf", "synthetic source");
const analysis = writeJson("analysis.json", { status: "PASS_CONDITIONAL" });
const summary = write("summary.md", "# Synthetic summary\n");
const analysisProof = writeJson("analysis-proof.json", {
  proof_contract_version: "0.1.0",
  artifact_type: "RFP_ANALYSIS",
  case_id: state.case_id,
  source_inputs: [{ path: source, sha256: hash(source) }],
  authority: { digest: "test-authority", repository_head: "test-head", runtime: "AER_CORE" },
  runtime_selection: { core_required: true, reason: "synthetic material judgment" },
  core_evidence: {
    problem_definition_present: true,
    facts_assumptions_unknowns_separated: true,
    reasoning_links_present: true,
    bottleneck_six_fields_present: true,
    solution_hypothesis_present: true,
    direct_validation: "PASS_CONDITIONAL",
    opposing_review: "REVIEWED",
    whole_process_impact: "REVIEWED",
    global_consistency: "PASS_CONDITIONAL",
    closure_outcome: "PASS_CONDITIONAL"
  },
  outputs: [{ path: analysis, sha256: hash(analysis) }, { path: summary, sha256: hash(summary) }]
});

const headers = [
  "SEQ", "VOLUME", "PAGE_BUDGET", "LEVEL_1", "LEVEL_2", "LEVEL_3", "LEVEL_4",
  "REQUIREMENT_ID", "REQUIREMENT_NAME", "A3_CHECK", "PHYSICAL_SHEETS", "COUNTED_PAGES",
  "OWNER_NO_LLM", "PM_NOTE", "CHANGE_STATUS", "LLM_CHECK", "HUMAN_CHECK", "WARNING",
  "node_id", "parent_id", "level", "origin", "official_fixed", "leaf", "baseline_A3",
  "baseline_physical", "baseline_L1", "baseline_L2", "baseline_L3", "baseline_L4",
  "baseline_budget", "baseline_volume", "baseline_parent", "baseline_level", "baseline_title"
];
const workbook = Workbook.create();
const sheet = workbook.worksheets.add("PM_WORKSPACE");
const rows = state.toc_nodes.map((node, index) => {
  const levels = [1, 2, 3, 4].map((level) => level === node.level ? node.title : null);
  return [
    node.seq ?? index + 1, node.volume_id, node.page_budget_id, ...levels,
    (node.requirement_ids || []).join(","), null, Boolean(node.a3_checked), node.physical_sheets,
    node.counted_pages, node.owner_no_llm, node.pm_note, "UNCHANGED", "PASS", node.human_check,
    "HUMAN_CONFIRM_REQUIRED", node.node_id, node.parent_id, node.level, node.origin,
    node.official_fixed ? "Y" : "N", node.leaf ? "Y" : "N", node.leaf ? Boolean(node.a3_checked) : null,
    node.physical_sheets, ...levels, node.page_budget_id, node.volume_id, node.parent_id, node.level, node.title
  ];
});
sheet.getRange("A1:AI1").values = [["MANIFEST RUNNER TEST", ...Array(34).fill(null)]];
sheet.getRangeByIndexes(5, 0, 1, headers.length).values = [headers];
sheet.getRangeByIndexes(6, 0, rows.length, headers.length).values = rows;
sheet.tables.add(`A6:AI${rows.length + 6}`, true, "ManifestRunnerPMTable");
for (const name of ["PAGE_BUDGETS", "REQUIREMENT_REVIEW", "EVALUATION_REFERENCE", "GUIDE"]) {
  workbook.worksheets.add(name).getRange("A1").values = [[name]];
}
const workbookPath = path.join(tempRoot, "five-sheet-input.xlsx");
await (await SpreadsheetFile.exportXlsx(workbook)).save(workbookPath);
const decisions = writeJson("decisions.json", {
  decision_version: "0.1.0", case_id: state.case_id, acceptance_id: "SYNTHETIC-MANIFEST-ACCEPT",
  confirmed_changes: [], splits: []
});
const strategy = writeJson("strategies.json", { case_id: state.case_id, candidates: [{ strategy_id: "STR-01" }] });
const rationale = write("strategy.md", "# Synthetic strategy\n");
const outputRoot = path.join(tempRoot, "run-output");
const manifestPath = writeJson("manifest.json", {
  manifest_version: "0.1.0",
  case_id: state.case_id,
  repository_root: repositoryRoot,
  output_root: outputRoot,
  source_paths: [source],
  approved_artifacts: {
    analysis_report: analysis,
    summary_report: summary,
    analysis_evidence: analysisProof,
    toc_baseline_state: baseline,
    toc_draft_workbook: workbookPath,
    returned_workbook: workbookPath,
    toc_decisions: decisions
  },
  foundation_input: {
    proposal_mode: "SOLO",
    participant_count: 1,
    related_performance_status: "UNPROVIDED",
    rfp_consistency_status: "PASS",
    proceeded_without_optional_input: true
  },
  toc: { contract_version: "0.3.0" },
  strategy: { candidates_path: strategy, rationale_path: rationale, selected_candidate_ids: ["STR-01"] }
});

const request = runManifest(manifestPath);
assert.equal(request.status, "AWAITING_AER_CORE_STRATEGY_EVIDENCE");
assert.equal(request.case_id, state.case_id);
assert.equal(fs.existsSync(path.join(outputRoot, "workflow-state-006.json")), true);
assert.equal(fs.existsSync(path.join(outputRoot, "workflow-state-007.json")), false);
const receipt = JSON.parse(fs.readFileSync(path.join(outputRoot, "toc-acceptance-receipt.json"), "utf8"));
assert.deepEqual([...receipt.system_sheets.recovered].sort(), ["CHANGE_REVIEW", "SYS_MAPPING", "SYS_RPA_SPEC", "SYS_SNAPSHOT"]);

const proof = {
  proof_contract_version: "0.1.0",
  artifact_type: "STRATEGY",
  case_id: state.case_id,
  source_inputs: [{ path: source, sha256: hash(source) }],
  authority: { digest: "test-authority", repository_head: "test-head", runtime: "AER_CORE" },
  runtime_selection: { core_required: true, reason: "synthetic strategy judgment" },
  core_evidence: {
    problem_definition_present: true,
    facts_assumptions_unknowns_separated: true,
    reasoning_links_present: true,
    bottleneck_six_fields_present: true,
    solution_hypothesis_present: true,
    direct_validation: "PASS_CONDITIONAL",
    opposing_review: "REVIEWED",
    whole_process_impact: "REVIEWED",
    global_consistency: "PASS_CONDITIONAL",
    closure_outcome: "PASS_CONDITIONAL"
  },
  outputs: [{ path: strategy, sha256: hash(strategy) }],
  strategy_bindings: {
    approved_rfp_analysis_proof_sha256: hash(analysisProof),
    accepted_toc_state_sha256: "0".repeat(64),
    foundation_input_status: "UNPROVIDED"
  }
};
const badProof = writeJson("bad-strategy-proof.json", proof);
const badContinuation = writeJson("bad-continuation.json", { semantic_evidence_path: badProof });
assert.throws(() => runManifest(manifestPath, badContinuation), /not bound to the current accepted TOC state/);
assert.equal(fs.existsSync(path.join(outputRoot, "workflow-state-007.json")), false);

proof.strategy_bindings.accepted_toc_state_sha256 = request.accepted_toc_state_sha256;
const goodProof = writeJson("strategy-proof.json", proof);
const continuation = writeJson("continuation.json", { semantic_evidence_path: goodProof });
const verification = runManifest(manifestPath, continuation);
assert.equal(verification.outcome, "PASS");
assert.equal(verification.checks.source_paths_roundtrip, true);
assert.equal(verification.checks.rpa_hold, true);
assert.throws(() => runManifest(manifestPath, continuation), /already complete/);
console.log("PASS: Proposal initial manifest runner v0.1.0");
