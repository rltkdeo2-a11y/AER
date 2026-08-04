import fs from "node:fs/promises";
import path from "node:path";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";
import { analyzeRoundtrip, normalizeState } from "./aer-toc-roundtrip-engine.mjs";
import { acceptRoundtrip } from "./aer-toc-roundtrip-accept.mjs";

function assert(condition, message) {
  if (!condition) throw new Error(`ASSERTION FAILED: ${message}`);
}

const [v01FixturePath, v02FixturePath, v03FixturePath, tempDirectory] = process.argv.slice(2);
if (!v01FixturePath || !v02FixturePath || !v03FixturePath || !tempDirectory) {
  throw new Error("Usage: node test-proposal-toc-roundtrip.mjs <v0.1.json> <v0.2.json> <v0.3.json> <temp-directory>");
}

const readJson = async (filePath) => JSON.parse(await fs.readFile(filePath, "utf8"));
const writeJson = async (filePath, value) => fs.writeFile(filePath, JSON.stringify(value, null, 2), "utf8");
const clone = (value) => structuredClone(value);
const headers = [
  "node_id", "level", "LEVEL_1", "LEVEL_2", "LEVEL_3", "LEVEL_4",
  "REQUIREMENT_ID", "A3_CHECK", "PHYSICAL_SHEETS", "OWNER_NO_LLM",
  "PM_NOTE", "HUMAN_CHECK", "parent_id", "VOLUME", "PAGE_BUDGET",
];

function rowsFromState(rawState) {
  const state = normalizeState(rawState);
  return state.toc_nodes.map((node) => {
    const levels = ["", "", "", ""];
    levels[node.level - 1] = node.title;
    return [
      node.node_id, node.level, ...levels, (node.requirement_ids || []).join(","),
      node.a3_checked, node.physical_sheets, node.owner_no_llm || "", node.pm_note || "",
      node.human_check, node.parent_id || "", node.volume_id, node.page_budget_id,
    ];
  });
}

function column(name) {
  return headers.indexOf(name);
}

function rowIndex(rawState, nodeId) {
  const index = rawState.toc_nodes.findIndex((node) => node.node_id === nodeId);
  if (index < 0) throw new Error(`Synthetic node not found: ${nodeId}`);
  return index;
}

async function createWorkbook({ rawState, fileName, mutateRows, addFormulaError = false, addLiteralErrorText = false }) {
  const workbook = Workbook.create();
  const sheet = workbook.worksheets.add("PM_WORKSPACE");
  const rows = rowsFromState(rawState);
  if (mutateRows) mutateRows(rows);
  sheet.getRangeByIndexes(0, 0, 1, headers.length).values = [headers];
  sheet.getRangeByIndexes(1, 0, rows.length, headers.length).values = rows;
  if (addFormulaError) {
    const errorSheet = workbook.worksheets.add("ERROR_SCAN");
    errorSheet.getRange("A1").formulas = [["=1/0"]];
  }
  if (addLiteralErrorText) {
    const noteSheet = workbook.worksheets.add("ERROR_TEXT_NOTE");
    noteSheet.getRange("A1").values = [["#N/A is an explanatory label, not a formula error."]];
  }
  const workbookPath = path.join(tempDirectory, fileName);
  await (await SpreadsheetFile.exportXlsx(workbook)).save(workbookPath);
  return workbookPath;
}

function addSystemTable(workbook, name, headersRow, dataRows, tableName) {
  const sheet = workbook.worksheets.add(name);
  const columnCount = headersRow.length;
  sheet.getRangeByIndexes(0, 0, 1, columnCount).values = [[name, ...Array(columnCount - 1).fill(null)]];
  sheet.getRangeByIndexes(3, 0, 1, columnCount).values = [headersRow];
  if (dataRows.length) sheet.getRangeByIndexes(4, 0, dataRows.length, columnCount).values = dataRows;
  const lastRow = Math.max(5, dataRows.length + 4);
  const lastColumn = String.fromCharCode(64 + columnCount);
  sheet.tables.add(`A4:${lastColumn}${lastRow}`, true, tableName);
  return sheet;
}

async function createAcceptanceWorkbook(rawState, fileName, includeSystemSheets = true) {
  const state = normalizeState(rawState);
  const workbook = Workbook.create();
  const sheet = workbook.worksheets.add("PM_WORKSPACE");
  const acceptanceHeaders = [
    "SEQ", "VOLUME", "PAGE_BUDGET", "LEVEL_1", "LEVEL_2", "LEVEL_3", "LEVEL_4",
    "REQUIREMENT_ID", "REQUIREMENT_NAME", "A3_CHECK", "PHYSICAL_SHEETS", "COUNTED_PAGES",
    "OWNER_NO_LLM", "PM_NOTE", "CHANGE_STATUS", "LLM_CHECK", "HUMAN_CHECK", "WARNING",
    "node_id", "parent_id", "level", "origin", "official_fixed", "leaf", "baseline_A3",
    "baseline_physical", "baseline_L1", "baseline_L2", "baseline_L3", "baseline_L4",
    "baseline_budget", "baseline_volume", "baseline_parent", "baseline_level", "baseline_title",
  ];
  const acceptanceColumn = (name) => acceptanceHeaders.indexOf(name);
  const rows = state.toc_nodes.map((node, index) => {
    const levels = [1, 2, 3, 4].map((level) => level === node.level ? node.title : null);
    return [
      node.seq ?? index + 1, node.volume_id, node.page_budget_id, ...levels,
      (node.requirement_ids || []).join(","), null, Boolean(node.a3_checked), node.physical_sheets,
      node.counted_pages, node.owner_no_llm, node.pm_note, "UNCHANGED", "PASS", node.human_check,
      "HUMAN_CONFIRM_REQUIRED", node.node_id, node.parent_id, node.level, node.origin,
      node.official_fixed ? "Y" : "N", node.leaf ? "Y" : "N", node.leaf ? Boolean(node.a3_checked) : null,
      node.physical_sheets, ...levels, node.page_budget_id, node.volume_id, node.parent_id, node.level, node.title,
    ];
  });
  const sourceIndex = state.toc_nodes.findIndex((node) => node.node_id === "TOC-V1-I-1-D01");
  const confirmedIndex = state.toc_nodes.findIndex((node) => node.node_id === "TOC-V2-II-3-SFR-001");
  rows[confirmedIndex][acceptanceColumn("LEVEL_3")] = "Technical title approved";
  rows[sourceIndex][acceptanceColumn("LEVEL_3")] = "Company general status";
  rows[sourceIndex][acceptanceColumn("PHYSICAL_SHEETS")] = 60;
  const newRow = Array(acceptanceHeaders.length).fill(null);
  newRow[acceptanceColumn("level")] = 3;
  newRow[acceptanceColumn("LEVEL_3")] = "Company history";
  newRow[acceptanceColumn("A3_CHECK")] = "FALSE";
  newRow[acceptanceColumn("PHYSICAL_SHEETS")] = 40;
  rows.push(newRow);
  sheet.getRange("A1:AI1").values = [["ACCEPTANCE TEST", ...Array(34).fill(null)]];
  sheet.getRangeByIndexes(5, 0, 1, acceptanceHeaders.length).values = [acceptanceHeaders];
  sheet.getRangeByIndexes(6, 0, rows.length, acceptanceHeaders.length).values = rows;
  sheet.tables.add(`A6:AI${rows.length + 6}`, true, "AcceptancePMTable");

  if (!includeSystemSheets) {
    for (const name of ["PAGE_BUDGETS", "REQUIREMENT_REVIEW", "EVALUATION_REFERENCE", "GUIDE"]) {
      const humanSheet = workbook.worksheets.add(name);
      humanSheet.getRange("A1").values = [[name]];
    }
  }
  const snapshotRows = state.toc_nodes.map((node) => {
    const levels = [1, 2, 3].map((level) => level === node.level ? node.title : null);
    return [node.node_id, node.volume_id, node.page_budget_id, ...levels, node.parent_id, node.level,
      node.leaf ? Boolean(node.a3_checked) : null, node.physical_sheets, node.official_fixed ? "Y" : "N", "BASELINE"];
  });
  if (includeSystemSheets) addSystemTable(workbook, "SYS_SNAPSHOT",
    ["node_id", "volume_id", "page_budget_id", "baseline_L1", "baseline_L2", "baseline_L3", "baseline_parent", "baseline_level", "baseline_A3", "baseline_physical", "official_fixed", "status"],
    snapshotRows, "AcceptanceSnapshotTable");
  const mappingRows = state.mappings.map((mapping) => [mapping.map_id, mapping.obligation_id, mapping.target_node_id,
    mapping.relation, null, null, mapping.evidence, mapping.validation_status, mapping.target_node_id]);
  if (includeSystemSheets) addSystemTable(workbook, "SYS_MAPPING",
    ["map_id", "obligation_id", "target_node_id", "relation", "requirement_id", "source_id", "evidence", "validation_status", "toc_path"],
    mappingRows, "AcceptanceMappingTable");
  const rpaRows = state.toc_nodes.filter((node) => node.leaf).map((node, index) => ["TEST-DRAFT", node.volume_id,
    node.page_budget_id, `PAGE-C3-${String(index + 1).padStart(3, "0")}`, node.node_id, index + 1, "A4",
    node.physical_sheets, null, null, null, "HOLD"]);
  if (includeSystemSheets) addSystemTable(workbook, "SYS_RPA_SPEC",
    ["release_id", "volume_id", "page_budget_id", "page_id", "node_id", "page_order", "page_format", "physical_sheets", "counted_start", "counted_end", "layout_key", "release_status"],
    rpaRows, "AcceptanceRpaTable");
  const changeRows = state.toc_nodes.map((node) => [node.node_id, node.volume_id, node.page_budget_id, null, null, null,
    "UNCHANGED", null, null, node.physical_sheets, "IGNORE"]);
  if (includeSystemSheets) addSystemTable(workbook, "CHANGE_REVIEW",
    ["node_id", "VOLUME", "BUDGET", "LEVEL_1", "LEVEL_2", "LEVEL_3", "CHANGE_TYPE", "BASELINE_A3", "CURRENT_A3", "CURRENT_PAGES", "ACTION"],
    changeRows, "AcceptanceChangeTable");
  const workbookPath = path.join(tempDirectory, fileName);
  await (await SpreadsheetFile.exportXlsx(workbook)).save(workbookPath);
  return workbookPath;
}

async function runAnalysis(rawState, workbookPath, stem) {
  const baselinePath = path.join(tempDirectory, `${stem}-baseline.json`);
  const reportPath = path.join(tempDirectory, `${stem}-report.json`);
  await writeJson(baselinePath, rawState);
  const report = await analyzeRoundtrip({ workbookPath, baselinePath, reportPath });
  return { report, baselinePath, reportPath };
}

const v03Source = await readJson(v03FixturePath);
const mainParent = v03Source.toc_nodes.find((node) => node.node_id === "TOC-V1-I");
const volume2Parent = v03Source.toc_nodes.find((node) => node.node_id === "TOC-V2-II");
const leaves = [
  ["TOC-T-001", "TOC-V1-I", "VOL-1", "PB-V1-MAIN", "Background", "R-001", 20],
  ["TOC-T-002", "TOC-V1-I", "VOL-1", "PB-V1-MAIN", "Purpose", "R-002", 20],
  ["TOC-T-003", "TOC-V1-I", "VOL-1", "PB-V1-MAIN", "Scope", "R-003", 20],
  ["TOC-T-004", "TOC-V1-I", "VOL-1", "PB-V1-MAIN", "Organization", "R-004", 20],
  ["TOC-T-005", "TOC-V1-I", "VOL-1", "PB-V1-MAIN", "Schedule", "R-005", 20],
  ["TOC-T-006", "TOC-V2-II", "VOL-2", "PB-V2-MAIN", "Technical detail", "R-006", 300],
].map(([node_id, parent_id, volume_id, page_budget_id, title, requirementId, physical_sheets]) => ({
  node_id, parent_id, volume_id, page_budget_id, level: 3, title,
  origin: "SYNTHETIC", official_fixed: false, leaf: true,
  requirement_ids: [requirementId], a3_checked: false, physical_sheets,
  owner_no_llm: null, pm_note: null, human_check: "UNCONFIRMED",
}));
const v03 = clone(v03Source);
v03.case_id = "SYNTHETIC-ROUNDTRIP-V0.3";
v03.toc_nodes = [mainParent, volume2Parent, ...leaves];
v03.baseline_snapshot = v03.toc_nodes.map((node) => ({
  node_id: node.node_id, volume_id: node.volume_id, page_budget_id: node.page_budget_id,
  parent_id: node.parent_id, level: node.level, title: node.title,
  requirement_ids: node.requirement_ids, a3_checked: node.a3_checked,
  physical_sheets: node.physical_sheets, official_fixed: node.official_fixed,
}));

const editedV03Path = await createWorkbook({
  rawState: v03,
  fileName: "synthetic-v03-edited.xlsx",
  mutateRows: (rows) => {
    rows[rowIndex(v03, "TOC-T-001")][column("LEVEL_3")] = "Background revised";
    rows[rowIndex(v03, "TOC-T-002")][column("PHYSICAL_SHEETS")] = 21;
    rows[rowIndex(v03, "TOC-T-003")][column("A3_CHECK")] = true;
    rows[rowIndex(v03, "TOC-T-004")][column("OWNER_NO_LLM")] = "Local owner";
    rows[rowIndex(v03, "TOC-V1-I")][column("LEVEL_1")] = "Official title revised";
    rows.push(["", 3, "", "", "New PM row", "", "", false, 3, "", "", "", "", "", ""]);
  },
});
const { report: v03Report } = await runAnalysis(v03, editedV03Path, "v03-edited");
assert(v03Report.summary.change_counts.RENAMED === 2, "editable and official titles are RENAMED");
assert(v03Report.summary.change_counts.PAGE_CHANGED === 1, "page change is detected");
assert(v03Report.summary.change_counts.FORMAT_CHANGED === 1, "A3 Boolean change is detected");
assert(v03Report.summary.change_counts.NEW === 1, "new row is detected");
assert(v03Report.material_changes.find((change) => change.change_type === "NEW").provisional_node_id.startsWith("PROV-"), "new row receives a provisional candidate ID");
assert(v03Report.boolean_compatibility.a3_true_rows[0].raw_type === "boolean", "Excel Boolean TRUE is preserved");
assert(v03Report.owner_field_changes[0].llm_impact_from_owner === "NONE", "owner has no LLM impact");
assert(v03Report.page_budgets.find((budget) => budget.page_budget_id === "PB-V1-MAIN").status === "INDETERMINATE", "unscoped new page row prevents budget PASS");
assert(v03Report.page_budgets.find((budget) => budget.page_budget_id === "PB-V2-MAIN").status === "INDETERMINATE", "unknown page scope prevents unrelated exact-budget PASS");
assert(v03Report.release_recommendation === "HOLD", "blocking or indeterminate changes preserve HOLD");
assert(v03Report.human_guidance.required_actions.every((action) => action.cell === null || /^[A-Z]+\d+$/.test(action.cell)), "human actions use Excel cell addresses");
assert(v03Report.human_guidance.required_actions.some((action) => action.requested_value === false), "A3 block receives an explicit false value");
assert(v03Report.human_guidance.required_actions.some((action) => action.requested_value === 20), "page change receives a concrete suggested value");
assert(v03Report.human_guidance.required_actions.some((action) => action.title === "New PM row" && action.internal_ref.startsWith("PROV-")), "new-row guidance carries only an internal provisional reference");
assert(v03Report.human_guidance.confirmations.length === 2, "allowed title changes are confirmations rather than forced corrections");
assert(v03Report.human_guidance.no_action_notes.length === 1, "owner-only change is explained as no action");
assert(!v03Report.human_guidance.display_text.includes("TOC-T-") && !v03Report.human_guidance.display_text.includes("PB-V"), "display text does not expose internal identifiers");

const acceptanceState = clone(v03Source);
const acceptanceSourceId = "TOC-V1-I-1-D01";
const acceptanceConfirmedId = "TOC-V2-II-3-SFR-001";
const acceptanceWorkbookPath = await createAcceptanceWorkbook(acceptanceState, "synthetic-acceptance-edited.xlsx");
const acceptanceOriginalHash = await fs.readFile(acceptanceWorkbookPath).then((bytes) => Buffer.from(bytes).toString("base64"));
const acceptanceBaselinePath = path.join(tempDirectory, "synthetic-acceptance-baseline.json");
const acceptanceDecisionsPath = path.join(tempDirectory, "synthetic-acceptance-decisions.json");
const acceptedWorkbookPath = path.join(tempDirectory, "synthetic-accepted.xlsx");
const acceptedStatePath = path.join(tempDirectory, "synthetic-accepted-state.json");
const acceptedReportPath = path.join(tempDirectory, "synthetic-accepted-report.json");
const acceptanceReceiptPath = path.join(tempDirectory, "synthetic-acceptance-receipt.json");
await writeJson(acceptanceBaselinePath, acceptanceState);
await writeJson(acceptanceDecisionsPath, {
  decision_version: "0.1.0",
  case_id: acceptanceState.case_id,
  acceptance_id: "SYNTHETIC-ACCEPT-001",
  confirmed_changes: [{ node_id: acceptanceConfirmedId, excel_row: rowIndex(acceptanceState, acceptanceConfirmedId) + 7, fields: ["title"] }],
  splits: [{
    source_node_id: acceptanceSourceId,
    source_excel_row: rowIndex(acceptanceState, acceptanceSourceId) + 7,
    new_excel_row: acceptanceState.toc_nodes.length + 7,
    new_node_id: "TOC-V1-I-1-D02",
    expected_total_physical_sheets: 100,
    new_mapping_relation: "SUB",
  }],
});
const acceptanceResult = await acceptRoundtrip({
  workbookPath: acceptanceWorkbookPath,
  baselinePath: acceptanceBaselinePath,
  decisionsPath: acceptanceDecisionsPath,
  acceptedWorkbookPath,
  acceptedStatePath,
  verificationReportPath: acceptedReportPath,
  acceptanceReceiptPath,
});
const acceptedState = await readJson(acceptedStatePath);
const acceptedReport = await readJson(acceptedReportPath);
const acceptanceReceipt = await readJson(acceptanceReceiptPath);
assert(acceptanceResult.accepted_events.length === 2, "acceptance records confirmed rename and approved split");
assert(acceptedState.toc_nodes.some((node) => node.node_id === "TOC-V1-I-1-D02" && node.physical_sheets === 40), "approved new row becomes canonical");
assert(acceptedState.mappings.some((mapping) => mapping.target_node_id === "TOC-V1-I-1-D02" && mapping.relation === "SUB"), "approved split receives a requirement mapping");
assert(acceptedReport.summary.material_changes === 0, "accepted workbook and accepted state roundtrip with no material changes");
assert(acceptedReport.page_budgets.find((budget) => budget.page_budget_id === "PB-V1-MAIN").status === "PASS", "accepted split preserves exact page budget");
assert(acceptedReport.release_recommendation === "HUMAN_CONFIRMATION_REQUIRED", "acceptance does not release RPA");
assert(acceptanceReceipt.acceptance_engine_version === "0.1.1", "acceptance receipt identifies the enforcing engine");
assert(acceptanceReceipt.system_sheets.status === "PASS" && acceptanceReceipt.system_sheets.recovered.length === 0, "existing system sheets are verified without recovery");
assert(await fs.readFile(acceptanceWorkbookPath).then((bytes) => Buffer.from(bytes).toString("base64")) === acceptanceOriginalHash, "acceptance preserves the original workbook");

const fiveSheetWorkbookPath = await createAcceptanceWorkbook(acceptanceState, "synthetic-five-sheet-edited.xlsx", false);
const fiveSheetAcceptedWorkbookPath = path.join(tempDirectory, "synthetic-five-sheet-accepted.xlsx");
const fiveSheetAcceptedStatePath = path.join(tempDirectory, "synthetic-five-sheet-accepted-state.json");
const fiveSheetAcceptedReportPath = path.join(tempDirectory, "synthetic-five-sheet-accepted-report.json");
const fiveSheetReceiptPath = path.join(tempDirectory, "synthetic-five-sheet-acceptance-receipt.json");
await acceptRoundtrip({
  workbookPath: fiveSheetWorkbookPath,
  baselinePath: acceptanceBaselinePath,
  decisionsPath: acceptanceDecisionsPath,
  acceptedWorkbookPath: fiveSheetAcceptedWorkbookPath,
  acceptedStatePath: fiveSheetAcceptedStatePath,
  verificationReportPath: fiveSheetAcceptedReportPath,
  acceptanceReceiptPath: fiveSheetReceiptPath,
});
const fiveSheetReceipt = await readJson(fiveSheetReceiptPath);
const recoveredSheets = [...fiveSheetReceipt.system_sheets.recovered].sort();
assert(JSON.stringify(recoveredSheets) === JSON.stringify(["CHANGE_REVIEW", "SYS_MAPPING", "SYS_RPA_SPEC", "SYS_SNAPSHOT"]), "five-sheet production boundary recovers every required system sheet");
const recoveredWorkbook = await SpreadsheetFile.importXlsx(await fs.readFile(fiveSheetAcceptedWorkbookPath));
for (const requiredSheet of fiveSheetReceipt.system_sheets.required) {
  assert(recoveredWorkbook.worksheets.getItem(requiredSheet).tables.items.length === 1, `${requiredSheet} is restored with its system table`);
}

const v01 = await readJson(v01FixturePath);
const v01Path = await createWorkbook({ rawState: v01, fileName: "synthetic-v01-a3.xlsx" });
const { report: v01Report } = await runAnalysis(v01, v01Path, "v01-a3");
assert(v01Report.page_budgets[0].assigned_pages === 80, "v0.1 A3 authoritative multiplier produces 80 counted pages");
assert(v01Report.page_budgets[0].status === "PASS", "v0.1 exact budget passes with A3 multiplier");

const v02 = await readJson(v02FixturePath);
v02.rfp_constraints.planning_target_pages = 20;
v02.human_inputs.planning_target_pages = 20;
for (const node of v02.toc_nodes.filter((node) => node.leaf)) node.physical_sheets = 10;
const v02Path = await createWorkbook({ rawState: v02, fileName: "synthetic-v02-planning.xlsx" });
const { report: v02Report } = await runAnalysis(v02, v02Path, "v02-planning");
assert(v02Report.page_budgets[0].mode === "RFP_UNSPECIFIED", "v0.2 preserves official unspecified mode");
assert(v02Report.page_budgets[0].target_basis === "HUMAN_PLANNING", "v0.2 records planning target basis");
assert(v02Report.page_budgets[0].evaluation_target_pages === 20, "v0.2 evaluates the explicit planning target");
assert(v02Report.page_budgets[0].status === "PASS", "v0.2 planning allocation can pass");

const scoped = clone(v03);
scoped.content_policies = [{
  policy_id: "CP-A3-V2", scope_volume_id: "VOL-2", type: "FORMAT_PROHIBITED",
  rule: "A3 is not allowed in Volume 2.", penalty: "REVIEW",
}];
const scopedPath = await createWorkbook({
  rawState: scoped,
  fileName: "synthetic-scoped-a3.xlsx",
  mutateRows: (rows) => {
    rows[rowIndex(scoped, "TOC-T-001")][column("A3_CHECK")] = true;
    rows[rowIndex(scoped, "TOC-T-006")][column("A3_CHECK")] = true;
  },
});
const { report: scopedReport } = await runAnalysis(scoped, scopedPath, "scoped-a3");
const scopedA3 = scopedReport.material_changes.filter((change) => change.change_type === "FORMAT_CHANGED");
assert(scopedA3.find((change) => change.node_id === "TOC-T-001").impact_class === "REVIEW", "A3 prohibition does not leak outside its volume");
assert(scopedA3.find((change) => change.node_id === "TOC-T-006").impact_class === "BLOCK", "A3 prohibition applies inside its volume");

const scopePath = await createWorkbook({
  rawState: v03,
  fileName: "synthetic-budget-scope.xlsx",
  mutateRows: (rows) => { rows[rowIndex(v03, "TOC-T-001")][column("PAGE_BUDGET")] = "PB-V2-MAIN"; },
});
const { report: scopeReport } = await runAnalysis(v03, scopePath, "budget-scope");
assert(scopeReport.summary.change_counts.BUDGET_SCOPE_CHANGED === 1, "page-budget scope edit is structural");

const duplicatePath = await createWorkbook({
  rawState: v03,
  fileName: "synthetic-duplicate-id.xlsx",
  mutateRows: (rows) => { rows.push([...rows[rowIndex(v03, "TOC-T-001")]]); },
});
const { report: duplicateReport } = await runAnalysis(v03, duplicatePath, "duplicate-id");
assert(duplicateReport.summary.change_counts.DUPLICATE_ID === 1, "duplicate node ID is blocked");
assert(duplicateReport.page_budgets.find((budget) => budget.mode === "RFP_EXACT").status === "INDETERMINATE", "duplicate identity prevents budget PASS");

const invalidPath = await createWorkbook({
  rawState: v03,
  fileName: "synthetic-invalid-input.xlsx",
  mutateRows: (rows) => {
    rows[rowIndex(v03, "TOC-T-001")][column("A3_CHECK")] = "MAYBE";
    rows[rowIndex(v03, "TOC-T-002")][column("PHYSICAL_SHEETS")] = -1;
  },
});
const { report: invalidReport } = await runAnalysis(v03, invalidPath, "invalid-input");
assert(invalidReport.summary.change_counts.INVALID_BOOLEAN === 1, "invalid Boolean is blocked");
assert(invalidReport.summary.change_counts.INVALID_PAGE_VALUE === 1, "invalid physical-page value is blocked");

const clearedPath = await createWorkbook({
  rawState: v03,
  fileName: "synthetic-cleared-title.xlsx",
  mutateRows: (rows) => { rows[rowIndex(v03, "TOC-T-001")][column("LEVEL_3")] = ""; },
});
const { report: clearedReport } = await runAnalysis(v03, clearedPath, "cleared-title");
assert(clearedReport.summary.change_counts.RENAMED === 1, "cleared title is not replaced by baseline text");

const officialPath = await createWorkbook({
  rawState: v03,
  fileName: "synthetic-official-block.xlsx",
  mutateRows: (rows) => { rows[rowIndex(v03, "TOC-V1-I")][column("parent_id")] = "TOC-ILLEGAL-PARENT"; },
});
const { report: officialReport } = await runAnalysis(v03, officialPath, "official-block");
assert(officialReport.summary.change_counts.OFFICIAL_STRUCTURE_BLOCK === 1, "official parent change is blocked");

const deletedState = clone(v03);
const deletedPath = await createWorkbook({
  rawState: deletedState,
  fileName: "synthetic-deleted.xlsx",
  mutateRows: (rows) => { rows.splice(rowIndex(deletedState, "TOC-T-005"), 1); },
});
const { report: deletedReport } = await runAnalysis(deletedState, deletedPath, "deleted");
assert(deletedReport.summary.change_counts.DELETED === 1, "deleted baseline row is structural");

const formulaPath = await createWorkbook({ rawState: v03, fileName: "synthetic-formula-error.xlsx", addFormulaError: true });
const { report: formulaReport } = await runAnalysis(v03, formulaPath, "formula-error");
assert(formulaReport.formula_integrity.status === "REVIEW", "positive formula error is detected");
assert(formulaReport.release_recommendation === "HOLD", "formula error keeps release on HOLD");

const literalErrorTextPath = await createWorkbook({ rawState: v03, fileName: "synthetic-literal-error-text.xlsx", addLiteralErrorText: true });
const { report: literalErrorTextReport } = await runAnalysis(v03, literalErrorTextPath, "literal-error-text");
assert(literalErrorTextReport.formula_integrity.status === "PASS", "literal error-like text is not treated as a formula error");

let unsupportedRejected = false;
try {
  normalizeState({ ...clone(v03), contract_version: "9.9.9" });
} catch {
  unsupportedRejected = true;
}
assert(unsupportedRejected, "unsupported contract version is rejected");

console.log("PASS: Proposal TOC human roundtrip runtime v0.3.2 with acceptance v0.1.1");
