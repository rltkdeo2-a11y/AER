import fs from "node:fs/promises";
import crypto from "node:crypto";
import path from "node:path";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const SUPPORTED_CONTRACT_VERSIONS = new Set(["0.1.0", "0.2.0", "0.3.0"]);
const isBlank = (value) => value === null || value === undefined || String(value).trim() === "";
const asText = (value) => isBlank(value) ? "" : String(value).trim();
const asNumber = (value) => isBlank(value) ? null : (Number.isFinite(Number(value)) ? Number(value) : null);
const asList = (value) => asText(value).split(/[,;\n]/).map((item) => item.trim()).filter(Boolean).sort();
const sameList = (left, right) => JSON.stringify([...(left || [])].sort()) === JSON.stringify([...(right || [])].sort());
const normalizedPath = (value) => path.resolve(value).replaceAll("\\", "/").toLowerCase();

function columnLetter(zeroBasedIndex) {
  let value = zeroBasedIndex + 1;
  let result = "";
  while (value > 0) {
    const remainder = (value - 1) % 26;
    result = String.fromCharCode(65 + remainder) + result;
    value = Math.floor((value - 1) / 26);
  }
  return result;
}

function parseBoolean(value) {
  if (value === true || value === 1) return { value: true, valid: true };
  if (value === false || value === 0 || isBlank(value)) return { value: false, valid: true };
  const token = asText(value).toUpperCase();
  if (["TRUE", "Y", "YES", "1", "CHECKED"].includes(token)) return { value: true, valid: true };
  if (["FALSE", "N", "NO", "0", "UNCHECKED"].includes(token)) return { value: false, valid: true };
  return { value: false, valid: false };
}

function validateCanonicalState(state) {
  if (!SUPPORTED_CONTRACT_VERSIONS.has(state.contract_version)) {
    throw new Error(`Unsupported proposal TOC contract version: ${state.contract_version || "<missing>"}`);
  }
  for (const name of ["toc_nodes", "baseline_snapshot"]) {
    if (!Array.isArray(state[name])) throw new Error(`Canonical state is missing array: ${name}`);
  }
  if (!state.rfp_constraints || typeof state.rfp_constraints !== "object") {
    throw new Error("Canonical state is missing rfp_constraints.");
  }
  if (!asText(state.case_id)) throw new Error("Canonical state is missing case_id.");
  for (const [label, rows] of [["toc_nodes", state.toc_nodes], ["baseline_snapshot", state.baseline_snapshot]]) {
    const ids = rows.map((row) => asText(row.node_id));
    if (ids.some((id) => !id)) throw new Error(`${label} contains a blank node_id.`);
    if (new Set(ids).size !== ids.length) throw new Error(`${label} contains a duplicate node_id.`);
  }
}

export function normalizeState(input) {
  validateCanonicalState(input);
  const state = structuredClone(input);
  if (input.contract_version === "0.3.0") {
    const nodeMap = new Map((state.toc_nodes || []).map((node) => [node.node_id, node]));
    state.baseline_snapshot = (state.baseline_snapshot || []).map((row) => ({
      ...row,
      volume_id: row.volume_id || nodeMap.get(row.node_id)?.volume_id,
      page_budget_id: row.page_budget_id || nodeMap.get(row.node_id)?.page_budget_id,
      official_fixed: row.official_fixed ?? Boolean(nodeMap.get(row.node_id)?.official_fixed),
    }));
    return state;
  }

  const budgetId = "PB-DEFAULT";
  const volumeId = "VOL-1";
  const constraints = state.rfp_constraints || {};
  const mode = state.contract_version === "0.1.0" ? "RFP_EXACT" : constraints.page_constraint_mode;
  const target = state.contract_version === "0.1.0" ? constraints.target_pages : constraints.rfp_target_pages;
  const planningTarget = state.contract_version === "0.2.0"
    ? (constraints.planning_target_pages ?? state.human_inputs?.planning_target_pages ?? null)
    : null;
  state.rfp_constraints = {
    ...constraints,
    page_budgets: [{
      page_budget_id: budgetId,
      volume_id: volumeId,
      mode,
      target_pages: target ?? null,
      planning_target_pages: planningTarget,
      evaluation_target_pages: mode === "RFP_UNSPECIFIED" ? planningTarget : (target ?? null),
      target_basis: mode === "RFP_UNSPECIFIED"
        ? (planningTarget !== null ? "HUMAN_PLANNING" : "UNRESOLVED")
        : "RFP",
      counted_scope_node_ids: constraints.official_toc_node_ids || [],
      excluded_node_ids: [],
      status: "REVIEW",
    }],
    a3_count_multiplier: state.contract_version === "0.1.0"
      ? (constraints.a3_multiplier ?? null)
      : (constraints.a3_count_multiplier ?? null),
  };
  state.toc_nodes = (state.toc_nodes || []).map((node) => ({
    ...node,
    volume_id: node.volume_id || volumeId,
    page_budget_id: node.page_budget_id || budgetId,
  }));
  const nodeMap = new Map(state.toc_nodes.map((node) => [node.node_id, node]));
  state.baseline_snapshot = (state.baseline_snapshot || []).map((row) => ({
    ...row,
    volume_id: row.volume_id || nodeMap.get(row.node_id)?.volume_id || volumeId,
    page_budget_id: row.page_budget_id || nodeMap.get(row.node_id)?.page_budget_id || budgetId,
    official_fixed: row.official_fixed ?? Boolean(nodeMap.get(row.node_id)?.official_fixed),
  }));
  state.source_relationships ||= [];
  state.source_authority_matrix ||= [];
  state.content_policies ||= [];
  return state;
}

function makeHeaderMap(headers) {
  const map = new Map();
  headers.forEach((header, index) => {
    const key = asText(header);
    if (key && !map.has(key)) map.set(key, index);
  });
  return map;
}

function findHeaderRow(values) {
  for (let index = 0; index < Math.min(values.length, 30); index += 1) {
    const row = values[index].map(asText);
    if (row.includes("node_id") && row.includes("LEVEL_1") && row.includes("PHYSICAL_SHEETS")) return index;
  }
  throw new Error("PM_WORKSPACE header row was not found.");
}

function requireHeaders(map) {
  const required = [
    "node_id", "level", "LEVEL_1", "LEVEL_2", "LEVEL_3", "LEVEL_4",
    "REQUIREMENT_ID", "A3_CHECK", "PHYSICAL_SHEETS", "OWNER_NO_LLM",
    "PM_NOTE", "HUMAN_CHECK", "parent_id",
  ];
  const missing = required.filter((name) => !map.has(name));
  if (missing.length) throw new Error(`PM_WORKSPACE is missing required headers: ${missing.join(", ")}`);
}

function getCell(row, map, name) {
  const index = map.get(name);
  return index === undefined ? null : row[index];
}

function readCurrentRow(row, map, excelRow) {
  const levels = [1, 2, 3, 4].map((level) => asText(getCell(row, map, `LEVEL_${level}`)));
  const visibleLevelIndex = levels.findLastIndex((title) => title !== "");
  const level = visibleLevelIndex >= 0 ? visibleLevelIndex + 1 : asNumber(getCell(row, map, "level"));
  const title = visibleLevelIndex >= 0 ? levels[visibleLevelIndex] : "";
  const a3 = parseBoolean(getCell(row, map, "A3_CHECK"));
  const physicalRaw = getCell(row, map, "PHYSICAL_SHEETS");
  const physicalSheets = asNumber(physicalRaw);
  const address = (name) => map.has(name) ? `${columnLetter(map.get(name))}${excelRow}` : null;
  return {
    excel_row: excelRow,
    node_id: asText(getCell(row, map, "node_id")),
    volume_id: map.has("VOLUME") ? asText(getCell(row, map, "VOLUME")) : asText(getCell(row, map, "baseline_volume")),
    page_budget_id: map.has("PAGE_BUDGET") ? asText(getCell(row, map, "PAGE_BUDGET")) : asText(getCell(row, map, "baseline_budget")),
    parent_id: asText(getCell(row, map, "parent_id")),
    level,
    title,
    requirement_ids: asList(getCell(row, map, "REQUIREMENT_ID")),
    a3_raw: getCell(row, map, "A3_CHECK"),
    a3_checked: a3.value,
    a3_valid: a3.valid,
    physical_raw: physicalRaw,
    physical_sheets: physicalSheets,
    physical_valid: isBlank(physicalRaw) || (physicalSheets !== null && Number.isInteger(physicalSheets) && physicalSheets >= 0),
    owner_no_llm: asText(getCell(row, map, "OWNER_NO_LLM")),
    pm_note: asText(getCell(row, map, "PM_NOTE")),
    human_check: asText(getCell(row, map, "HUMAN_CHECK")),
    cells: {
      node_id: address("node_id"),
      title: visibleLevelIndex >= 0 ? address(`LEVEL_${visibleLevelIndex + 1}`) : null,
      requirement_ids: address("REQUIREMENT_ID"),
      a3_checked: address("A3_CHECK"),
      physical_sheets: address("PHYSICAL_SHEETS"),
      owner_no_llm: address("OWNER_NO_LLM"),
      parent_id: address("parent_id"),
      volume_id: address("VOLUME"),
      page_budget_id: address("PAGE_BUDGET"),
    },
    has_content: levels.some((value) => value !== "")
      || !isBlank(getCell(row, map, "REQUIREMENT_ID"))
      || !isBlank(getCell(row, map, "PHYSICAL_SHEETS"))
      || !isBlank(getCell(row, map, "PM_NOTE")),
  };
}

function classifyChange(baseline, current, a3Prohibited) {
  if (!current.a3_valid) {
    return { change_type: "INVALID_BOOLEAN", impact_class: "BLOCK", action: "RESTORE_VALID_BOOLEAN", reasons: ["A3_VALUE_INVALID"] };
  }
  if (!current.physical_valid) {
    return { change_type: "INVALID_PAGE_VALUE", impact_class: "BLOCK", action: "RESTORE_VALID_PAGE_VALUE", reasons: ["PHYSICAL_SHEETS_INVALID"] };
  }
  if (!baseline) {
    return { change_type: "NEW", impact_class: "STRUCTURAL", action: "HUMAN_REVIEW", reasons: ["UNKNOWN_OR_BLANK_NODE_ID"] };
  }
  const structuralReasons = [];
  if (asText(baseline.parent_id) !== asText(current.parent_id)) structuralReasons.push("PARENT_CHANGED");
  if (asNumber(baseline.level) !== asNumber(current.level)) structuralReasons.push("LEVEL_CHANGED");
  if (structuralReasons.length && baseline.official_fixed) {
    return { change_type: "OFFICIAL_STRUCTURE_BLOCK", impact_class: "BLOCK", action: "RESTORE_OR_EXPLICIT_DECISION", reasons: structuralReasons };
  }
  if (structuralReasons.includes("PARENT_CHANGED")) {
    return { change_type: "REPARENTED", impact_class: "STRUCTURAL", action: "HUMAN_REVIEW", reasons: structuralReasons };
  }
  if (structuralReasons.includes("LEVEL_CHANGED")) {
    return { change_type: "LEVEL_CHANGED", impact_class: "STRUCTURAL", action: "HUMAN_REVIEW", reasons: structuralReasons };
  }
  const scopeReasons = [];
  if (asText(baseline.volume_id) !== asText(current.volume_id)) scopeReasons.push("VOLUME_CHANGED");
  if (asText(baseline.page_budget_id) !== asText(current.page_budget_id)) scopeReasons.push("PAGE_BUDGET_CHANGED");
  if (scopeReasons.length) {
    return { change_type: "BUDGET_SCOPE_CHANGED", impact_class: "STRUCTURAL", action: "HUMAN_REVIEW", reasons: scopeReasons };
  }
  if (Boolean(baseline.a3_checked) !== Boolean(current.a3_checked)) {
    const blocked = a3Prohibited && current.a3_checked;
    return {
      change_type: "FORMAT_CHANGED",
      impact_class: blocked ? "BLOCK" : "REVIEW",
      action: blocked ? "REMOVE_PROHIBITED_A3" : "HUMAN_REVIEW",
      reasons: [current.a3_checked ? "A3_SELECTED" : "A3_CLEARED"],
    };
  }
  if (asNumber(baseline.physical_sheets) !== asNumber(current.physical_sheets)) {
    return { change_type: "PAGE_CHANGED", impact_class: "REVIEW", action: "RECHECK_PAGE_BUDGET", reasons: ["PHYSICAL_SHEETS_CHANGED"] };
  }
  if (!sameList(baseline.requirement_ids, current.requirement_ids)) {
    return { change_type: "REQUIREMENT_CHANGED", impact_class: "REVIEW", action: "RECHECK_MAPPING", reasons: ["REQUIREMENT_IDS_CHANGED"] };
  }
  if (asText(baseline.title) !== asText(current.title)) {
    return { change_type: "RENAMED", impact_class: "REVIEW", action: "HUMAN_REVIEW", reasons: ["TITLE_CHANGED"] };
  }
  const localReasons = [];
  if (current.owner_no_llm) localReasons.push("OWNER_PRESENT_NO_LLM_IMPACT");
  if (current.pm_note) localReasons.push("PM_NOTE_PRESENT");
  if (current.human_check && current.human_check !== "UNCONFIRMED") localReasons.push("HUMAN_CHECK_UPDATED");
  return { change_type: "UNCHANGED", impact_class: "LOCAL", action: "IGNORE_FOR_LLM", reasons: localReasons };
}

function provisionalId(state, current) {
  const digest = crypto.createHash("sha256")
    .update([state.case_id, current.excel_row, current.level, current.title, current.requirement_ids.join("|")].join("|"))
    .digest("hex").slice(0, 12).toUpperCase();
  return `PROV-${digest}`;
}

function isA3ProhibitedForRow(state, current) {
  return (state.content_policies || []).some((policy) => {
    if (policy.type !== "FORMAT_PROHIBITED" || !asText(policy.rule).toUpperCase().includes("A3")) return false;
    const scope = asText(policy.scope_volume_id).toUpperCase();
    return !scope || scope === "ALL" || scope === asText(current.volume_id).toUpperCase();
  });
}

function countedPagesForRow(state, current) {
  if (current.physical_sheets === null) return null;
  const multiplier = current.a3_checked
    ? (asNumber(state.rfp_constraints?.a3_count_multiplier) ?? 1)
    : 1;
  return current.physical_sheets * multiplier;
}

function scanFormulaErrors(workbook) {
  const errorValues = new Set([
    "#NULL!", "#DIV/0!", "#VALUE!", "#REF!", "#NAME?", "#NUM!", "#N/A",
    "#SPILL!", "#CALC!", "#FIELD!", "#BLOCKED!", "#UNKNOWN!", "#CONNECT!", "#BUSY!", "#PYTHON!",
  ]);
  const matches = [];
  for (const sheet of workbook.worksheets.items) {
    const used = sheet.getUsedRange();
    if (!used) continue;
    const values = used.values || [];
    const formulas = used.formulas || [];
    for (let row = 0; row < formulas.length; row += 1) {
      for (let column = 0; column < (formulas[row] || []).length; column += 1) {
        const formula = asText(formulas[row]?.[column]);
        const value = asText(values[row]?.[column]).toUpperCase();
        if (formula && errorValues.has(value)) {
          matches.push({ sheet: sheet.name, row: row + 1, column: column + 1, cell: `${columnLetter(column)}${row + 1}`, value });
        }
      }
    }
  }
  return { status: matches.length ? "REVIEW" : "PASS", matches };
}

function buildHumanGuidance({ materialChanges, pageBudgets, formulaErrors, ownerFieldChanges }) {
  const requiredActions = [];
  const confirmations = [];
  const noActionNotes = [];
  const budgetMap = new Map(pageBudgets.map((budget) => [budget.page_budget_id, budget]));
  const add = (collection, change, cell, instruction, requestedValue = null) => collection.push({
    action_id: `${collection === requiredActions ? "FIX" : "CHECK"}-${String(collection.length + 1).padStart(3, "0")}`,
    sheet: "PM_WORKSPACE",
    cell,
    excel_row: change.excel_row || null,
    title: change.title || change.baseline_values?.title || "",
    current_value: cell === change.cells?.a3_checked ? change.a3_raw
      : cell === change.cells?.physical_sheets ? change.physical_sheets
        : cell === change.cells?.title ? change.title : null,
    requested_value: requestedValue,
    instruction,
    internal_ref: change.node_id || change.provisional_node_id || null,
  });

  for (const change of materialChanges) {
    const titleCell = change.cells?.title || `행 ${change.excel_row || "미상"}`;
    if (change.change_type === "FORMAT_CHANGED" && change.impact_class === "BLOCK") {
      add(requiredActions, change, change.cells?.a3_checked,
        `PM_WORKSPACE 시트의 ${change.cells?.a3_checked} 셀(A3 사용 여부)을 FALSE로 바꿔주세요. 이 제안서는 A3 사용이 허용되지 않습니다.`, false);
    } else if (change.change_type === "PAGE_CHANGED") {
      const budget = budgetMap.get(change.page_budget_id);
      const baselinePages = change.baseline_values?.physical_sheets;
      const over = budget?.remaining_pages !== null && budget?.remaining_pages < 0 ? Math.abs(budget.remaining_pages) : null;
      const budgetText = over
        ? `현재 이 문서 구간은 ${budget.assigned_pages}/${budget.evaluation_target_pages}페이지로 ${over}페이지 초과되어 있습니다.`
        : "페이지 배분 합계를 다시 확인해야 합니다.";
      const requested = baselinePages !== null && baselinePages !== undefined ? baselinePages : null;
      const changeText = requested !== null
        ? `${change.cells?.physical_sheets} 셀(배정 페이지 수)을 현재 ${change.physical_sheets}에서 ${requested}로 바꿔주세요.`
        : `${change.cells?.physical_sheets} 셀(배정 페이지 수)을 다시 확인해주세요.`;
      add(requiredActions, change, change.cells?.physical_sheets,
        `PM_WORKSPACE 시트의 ${changeText} ${budgetText} 다른 항목에서 같은 수만큼 줄이는 경우에는 이 셀을 그대로 두어도 됩니다.`, requested);
    } else if (change.change_type === "NEW") {
      add(requiredActions, change, titleCell,
        `PM_WORKSPACE 시트의 ${titleCell} 셀에 새로 추가한 [${change.title || "제목 없는 항목"}] 항목을 유지할지 확인해주세요. 불필요하면 ${change.excel_row}행을 삭제해주세요. 유지하려면 상위 목차와 배정 페이지 수를 알려주세요. 시스템 식별자는 직접 입력하지 않아도 됩니다.`);
    } else if (["OFFICIAL_STRUCTURE_BLOCK", "REPARENTED", "LEVEL_CHANGED", "BUDGET_SCOPE_CHANGED"].includes(change.change_type)) {
      add(requiredActions, change, titleCell,
        `PM_WORKSPACE 시트의 ${titleCell} 셀에 있는 [${change.title || change.baseline_values?.title || "해당 목차"}] 항목의 위치 또는 목차 단계를 다시 확인해주세요. 원래 목차 구조를 유지해야 하므로, 의도한 변경이 아니라면 원래 위치로 되돌려주세요.`);
    } else if (change.change_type === "DELETED") {
      add(requiredActions, change, null,
        `삭제된 [${change.title || "목차 항목"}] 항목을 확인해주세요. 실수로 삭제했다면 원래 위치에 복원하고, 의도한 삭제라면 삭제 이유를 알려주세요.`);
    } else if (change.change_type === "DUPLICATE_ID") {
      add(requiredActions, change, null,
        "같은 목차 행이 중복된 것으로 감지되었습니다. PM_WORKSPACE 시트에서 중복된 행을 확인하고 불필요한 행을 삭제해주세요.");
    } else if (change.change_type === "INVALID_BOOLEAN") {
      add(requiredActions, change, change.cells?.a3_checked,
        `PM_WORKSPACE 시트의 ${change.cells?.a3_checked} 셀(A3 사용 여부)을 TRUE 또는 FALSE 중 하나로 바꿔주세요.`, false);
    } else if (change.change_type === "INVALID_PAGE_VALUE") {
      add(requiredActions, change, change.cells?.physical_sheets,
        `PM_WORKSPACE 시트의 ${change.cells?.physical_sheets} 셀(배정 페이지 수)에 0 이상의 정수를 입력해주세요.`);
    } else if (change.change_type === "RENAMED") {
      add(confirmations, change, titleCell,
        `PM_WORKSPACE 시트의 ${titleCell} 셀 제목이 [${change.baseline_values?.title || "이전 제목"}]에서 [${change.title}]으로 변경되었습니다. 의도한 변경이면 그대로 두어도 됩니다.`);
    } else if (change.change_type === "REQUIREMENT_CHANGED") {
      add(confirmations, change, change.cells?.requirement_ids,
        `PM_WORKSPACE 시트의 ${change.cells?.requirement_ids} 셀에 연결된 요구사항이 변경되었습니다. 이 목차에서 설명할 요구사항이 맞는지 확인해주세요.`);
    } else if (change.change_type === "FORMAT_CHANGED") {
      add(confirmations, change, change.cells?.a3_checked,
        `PM_WORKSPACE 시트의 ${change.cells?.a3_checked} 셀에서 A3 사용 여부가 변경되었습니다. 의도한 선택인지 확인해주세요.`);
    }
  }

  for (const error of formulaErrors) {
    requiredActions.push({
      action_id: `FIX-${String(requiredActions.length + 1).padStart(3, "0")}`,
      sheet: error.sheet,
      cell: error.cell,
      excel_row: error.row,
      title: "수식 오류",
      current_value: error.value,
      requested_value: null,
      instruction: `${error.sheet} 시트의 ${error.cell} 셀에 ${error.value} 수식 오류가 있습니다. 해당 셀의 수식을 확인하고 오류가 사라지도록 수정해주세요.`,
      internal_ref: null,
    });
  }

  if (ownerFieldChanges.length) {
    noActionNotes.push(`담당자 입력 ${ownerFieldChanges.length}건은 정상적으로 보존됐으며, 목차나 LLM 판단을 바꾸지 않으므로 수정할 필요가 없습니다.`);
  }

  const lines = [
    "수정이 필요한 항목을 아래와 같이 안내드립니다.",
    ...requiredActions.map((action, index) => `${index + 1}. ${action.instruction}`),
  ];
  if (confirmations.length) {
    lines.push("", "확인만 필요한 항목입니다.", ...confirmations.map((action, index) => `${index + 1}. ${action.instruction}`));
  }
  if (noActionNotes.length) lines.push("", ...noActionNotes);
  lines.push("", "수정과 확인이 끝나면 같은 파일을 저장해서 다시 전달해주세요.");
  return {
    summary: `필수 수정 ${requiredActions.length}건, 확인 ${confirmations.length}건`,
    required_actions: requiredActions,
    confirmations,
    no_action_notes: noActionNotes,
    completion_instruction: "수정과 확인이 끝나면 같은 파일을 저장해서 다시 전달해주세요.",
    display_text: lines.join("\n"),
  };
}

async function writeReportSafely({ reportPath, workbookPath, baselinePath, report }) {
  const reportResolved = path.resolve(reportPath);
  if ([workbookPath, baselinePath].some((inputPath) => normalizedPath(inputPath) === normalizedPath(reportResolved))) {
    throw new Error("ReportPath must be different from WorkbookPath and BaselinePath.");
  }
  if (path.extname(reportResolved).toLowerCase() !== ".json") {
    throw new Error("ReportPath must use the .json extension.");
  }
  await fs.mkdir(path.dirname(reportResolved), { recursive: true });
  const temporaryPath = `${reportResolved}.${process.pid}.${Date.now()}.tmp`;
  try {
    await fs.writeFile(temporaryPath, JSON.stringify(report, null, 2), "utf8");
    await fs.rename(temporaryPath, reportResolved);
  } catch (error) {
    await fs.rm(temporaryPath, { force: true });
    throw error;
  }
}

export async function analyzeRoundtrip({ workbookPath, baselinePath, reportPath }) {
  if ([workbookPath, baselinePath].some((inputPath) => normalizedPath(inputPath) === normalizedPath(reportPath))) {
    throw new Error("ReportPath must be different from WorkbookPath and BaselinePath.");
  }
  const state = normalizeState(JSON.parse(await fs.readFile(baselinePath, "utf8")));
  const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(workbookPath));
  const sheet = workbook.worksheets.getItem("PM_WORKSPACE");
  if (!sheet) throw new Error("PM_WORKSPACE sheet is missing.");

  const values = sheet.getUsedRange().values;
  const headerRow = findHeaderRow(values);
  const headerMap = makeHeaderMap(values[headerRow]);
  requireHeaders(headerMap);
  const currentRows = [];
  for (let index = headerRow + 1; index < values.length; index += 1) {
    const current = readCurrentRow(values[index], headerMap, index + 1);
    if (current.node_id || current.has_content) currentRows.push(current);
  }

  const baselineRows = state.baseline_snapshot || [];
  const baselineMap = new Map(baselineRows.map((row) => [row.node_id, row]));
  const nodeMap = new Map((state.toc_nodes || []).map((node) => [node.node_id, node]));
  const changes = [];
  const currentIds = new Set();
  const duplicateIds = new Set();

  for (const current of currentRows) {
    if (current.node_id) {
      if (currentIds.has(current.node_id)) duplicateIds.add(current.node_id);
      currentIds.add(current.node_id);
    }
    const baseline = current.node_id ? baselineMap.get(current.node_id) : null;
    const baselineNode = current.node_id ? nodeMap.get(current.node_id) : null;
    if (!baseline) current.provisional_node_id = provisionalId(state, current);
    const result = classifyChange(baseline, current, isA3ProhibitedForRow(state, current));
    const localFieldChanges = [];
    if (asText(baselineNode?.owner_no_llm) !== current.owner_no_llm) localFieldChanges.push("OWNER_NO_LLM_CHANGED");
    if (asText(baselineNode?.pm_note) !== current.pm_note) localFieldChanges.push("PM_NOTE_CHANGED");
    if (asText(baselineNode?.human_check) !== current.human_check) localFieldChanges.push("HUMAN_CHECK_CHANGED");
    changes.push({
      ...current,
      official_fixed: Boolean(baseline?.official_fixed),
      baseline_values: baseline ? {
        title: baseline.title,
        physical_sheets: baseline.physical_sheets,
        a3_checked: baseline.a3_checked,
        requirement_ids: baseline.requirement_ids || [],
        parent_id: baseline.parent_id,
        level: baseline.level,
        volume_id: baseline.volume_id,
        page_budget_id: baseline.page_budget_id,
      } : null,
      local_field_changes: localFieldChanges,
      ...result,
    });
  }

  for (const baseline of baselineRows) {
    if (!currentIds.has(baseline.node_id)) {
      changes.push({
        node_id: baseline.node_id,
        volume_id: baseline.volume_id,
        page_budget_id: baseline.page_budget_id,
        parent_id: baseline.parent_id,
        level: baseline.level,
        title: baseline.title,
        official_fixed: Boolean(baseline.official_fixed),
        change_type: baseline.official_fixed ? "OFFICIAL_STRUCTURE_BLOCK" : "DELETED",
        impact_class: baseline.official_fixed ? "BLOCK" : "STRUCTURAL",
        action: baseline.official_fixed ? "RESTORE_OR_EXPLICIT_DECISION" : "HUMAN_REVIEW",
        reasons: ["BASELINE_NODE_MISSING"],
      });
    }
  }

  for (const duplicateId of duplicateIds) {
    changes.push({
      node_id: duplicateId,
      change_type: "DUPLICATE_ID",
      impact_class: "BLOCK",
      action: "RESTORE_UNIQUE_IDENTITY",
      reasons: ["NODE_ID_NOT_UNIQUE"],
    });
  }

  const materialChanges = changes.filter((change) => change.change_type !== "UNCHANGED");
  const changeCounts = {};
  for (const change of changes) changeCounts[change.change_type] = (changeCounts[change.change_type] || 0) + 1;

  const pageBudgets = [];
  const knownBudgetIds = new Set((state.rfp_constraints?.page_budgets || []).map((budget) => budget.page_budget_id));
  const unknownPageRows = currentRows.filter((row) => {
    if (row.physical_sheets === null) return false;
    const knownNode = nodeMap.get(row.node_id);
    return (!knownNode && (!row.page_budget_id || !knownBudgetIds.has(row.page_budget_id))) || !row.physical_valid;
  });
  for (const budget of state.rfp_constraints?.page_budgets || []) {
    const countedRows = currentRows.filter((row) => {
      if (row.page_budget_id !== budget.page_budget_id) return false;
      const knownNode = nodeMap.get(row.node_id);
      return Boolean(knownNode?.leaf) || (!knownNode && row.physical_sheets !== null);
    });
    const missingKnownLeafPages = currentRows.some((row) => row.page_budget_id === budget.page_budget_id
      && nodeMap.get(row.node_id)?.leaf && row.physical_sheets === null);
    const assignedPages = countedRows.reduce((total, row) => total + (countedPagesForRow(state, row) || 0), 0);
    const planningTarget = budget.planning_target_pages ?? null;
    const evaluationTarget = budget.mode === "RFP_UNSPECIFIED" ? planningTarget : budget.target_pages;
    const indeterminate = duplicateIds.size > 0 || unknownPageRows.length > 0 || missingKnownLeafPages;
    let status;
    if (budget.mode === "RFP_UNLIMITED") status = "N/A";
    else if (indeterminate) status = "INDETERMINATE";
    else if (evaluationTarget === null) status = "REVIEW";
    else status = assignedPages === evaluationTarget ? "PASS" : "REVIEW";
    pageBudgets.push({
      page_budget_id: budget.page_budget_id,
      mode: budget.mode,
      target_pages: budget.target_pages,
      planning_target_pages: planningTarget,
      evaluation_target_pages: evaluationTarget,
      target_basis: budget.target_basis || (budget.mode === "RFP_UNSPECIFIED" ? "UNRESOLVED" : "RFP"),
      assigned_pages: assignedPages,
      remaining_pages: indeterminate || evaluationTarget === null ? null : evaluationTarget - assignedPages,
      status,
      ambiguity_rows: indeterminate ? unknownPageRows.map((row) => ({
        excel_row: row.excel_row,
        node_id: row.node_id,
        provisional_node_id: row.provisional_node_id || null,
        reason: "PAGE_BUDGET_NOT_DETERMINABLE",
      })) : [],
    });
  }

  const formulaInspect = await workbook.inspect({
    kind: "match",
    searchTerm: "#NULL!|#DIV/0!|#VALUE!|#REF!|#NAME\\?|#NUM!|#N/A|#SPILL!|#CALC!|#FIELD!|#BLOCKED!|#UNKNOWN!|#CONNECT!|#BUSY!|#PYTHON!",
    options: { useRegex: true, maxResults: 300 },
    summary: "proposal TOC roundtrip formula scan",
  });
  const formulaAudit = scanFormulaErrors(workbook);
  const formulaStatus = formulaAudit.status;
  const blockingChanges = materialChanges.filter((change) => change.impact_class === "BLOCK");
  const structuralChanges = materialChanges.filter((change) => change.impact_class === "STRUCTURAL");
  const ownerFieldChanges = changes
    .filter((change) => change.local_field_changes?.includes("OWNER_NO_LLM_CHANGED"))
    .map((change) => ({
      excel_row: change.excel_row,
      node_id: change.node_id,
      owner_no_llm: change.owner_no_llm,
      primary_change_type: change.change_type,
      llm_impact_from_owner: "NONE",
    }));
  const humanGuidance = buildHumanGuidance({
    materialChanges,
    pageBudgets,
    formulaErrors: formulaAudit.matches,
    ownerFieldChanges,
  });
  const report = {
    engine_version: "0.3.2",
    analyzed_at: new Date().toISOString(),
    workbook_path: workbookPath,
    baseline_case_id: state.case_id,
    summary: {
      rows_read: currentRows.length,
      baseline_rows: baselineRows.length,
      material_changes: materialChanges.length,
      blocking_changes: blockingChanges.length,
      structural_changes: structuralChanges.length,
      change_counts: changeCounts,
    },
    page_budgets: pageBudgets,
    formula_integrity: {
      status: formulaStatus,
      formula_error_cells: formulaAudit.matches,
      inspect_audit: formulaInspect.ndjson || String(formulaInspect),
    },
    boolean_compatibility: {
      a3_true_rows: currentRows.filter((row) => row.a3_checked).map((row) => ({
        excel_row: row.excel_row,
        node_id: row.node_id,
        raw_value: row.a3_raw,
        raw_type: typeof row.a3_raw,
      })),
      accepted_true_encodings: [true, "TRUE", "Y", "YES", 1, "1", "CHECKED"],
      accepted_false_encodings: [false, "FALSE", "N", "NO", 0, "0", "UNCHECKED", "<blank>"],
      display_rule: "A graphical checkbox and a TRUE/FALSE cell are equivalent Boolean surfaces.",
    },
    release_recommendation: blockingChanges.length
      || structuralChanges.length
      || pageBudgets.some((budget) => ["REVIEW", "INDETERMINATE"].includes(budget.status))
      || formulaStatus !== "PASS"
      ? "HOLD"
      : "HUMAN_CONFIRMATION_REQUIRED",
    material_changes: materialChanges,
    owner_field_changes: ownerFieldChanges,
    human_guidance: humanGuidance,
    local_unchanged_rows: changes.filter((change) => change.change_type === "UNCHANGED" && change.reasons.length),
    invariants: {
      automatic_regeneration: false,
      explicit_human_command_required: true,
      owner_field_ignored_for_llm: true,
    },
  };

  await writeReportSafely({ reportPath, workbookPath, baselinePath, report });
  return report;
}

const directExecution = process.argv[1]
  && import.meta.url === `file:///${process.argv[1].replaceAll("\\", "/")}`;
if (directExecution) {
  const [workbookPath, baselinePath, reportPath] = process.argv.slice(2);
  if (!workbookPath || !baselinePath || !reportPath) {
    throw new Error("Usage: node aer-toc-roundtrip-engine.mjs <workbook.xlsx> <baseline.json> <report.json>");
  }
  console.log(JSON.stringify(await analyzeRoundtrip({ workbookPath, baselinePath, reportPath }), null, 2));
}
