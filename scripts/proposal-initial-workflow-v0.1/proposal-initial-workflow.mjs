import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

export const WORKFLOW_VERSION = "0.1.0";
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
  const next = transition(state, "REGISTER_ANALYSIS", "SUMMARY_CONFIRMATION");
  next.artifacts.analysis_report_path = requireText(payload.analysis_report_path, "analysis_report_path");
  next.artifacts.summary_report_path = requireText(payload.summary_report_path, "summary_report_path");
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
  const next = transition(state, "RECORD_TOC_ACCEPTANCE", "STRATEGY_CANDIDATES", { human_command: true });
  next.artifacts.accepted_workbook_path = requireText(payload.accepted_workbook_path, "accepted_workbook_path");
  next.artifacts.accepted_state_path = requireText(payload.accepted_state_path, "accepted_state_path");
  next.artifacts.acceptance_verification_path = requireText(payload.verification_report_path, "verification_report_path");
  next.human_gates.toc_changes_accepted = true;
  next.toc_acceptance_summary = clone(verification.summary);
  next.next_action = "GENERATE_STRATEGY_CANDIDATES";
  return next;
}

function registerStrategyCandidates(state, payload) {
  assertStage(state, "REGISTER_STRATEGY_CANDIDATES");
  const next = transition(state, "REGISTER_STRATEGY_CANDIDATES", "STRATEGY_CANDIDATES");
  next.artifacts.strategy_candidates_path = requireText(payload.strategy_candidates_path, "strategy_candidates_path");
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
    removeArtifacts(["analysis_report_path", "summary_report_path", "toc_baseline_state_path", "toc_workbook_path", "toc_contract_version", "returned_workbook_path", "toc_change_report_path", "accepted_workbook_path", "accepted_state_path", "acceptance_verification_path", "strategy_candidates_path"]);
  } else if (target === "TOC_DRAFT") {
    next.human_gates.toc_changes_accepted = false;
    delete next.toc_change_summary;
    delete next.toc_release_recommendation;
    delete next.toc_acceptance_summary;
    delete next.strategy_selection;
    removeArtifacts(["toc_baseline_state_path", "toc_workbook_path", "toc_contract_version", "returned_workbook_path", "toc_change_report_path", "accepted_workbook_path", "accepted_state_path", "acceptance_verification_path", "strategy_candidates_path"]);
  } else {
    delete next.strategy_selection;
    removeArtifacts(["strategy_candidates_path"]);
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
