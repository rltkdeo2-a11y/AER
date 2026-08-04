import fs from "node:fs/promises";
import crypto from "node:crypto";
import path from "node:path";
import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";
import { analyzeRoundtrip, normalizeState } from "./aer-toc-roundtrip-engine.mjs";

const asText = (value) => value === null || value === undefined ? "" : String(value).trim();
const asNumber = (value) => asText(value) === "" ? null : Number(value);
const asList = (value) => asText(value).split(/[,;\n]/).map((item) => item.trim()).filter(Boolean).sort();
const normalizedPath = (value) => path.resolve(value).replaceAll("\\", "/").toLowerCase();

function asBoolean(value) {
  if (value === true || value === 1) return true;
  if (value === false || value === 0 || asText(value) === "") return false;
  const token = asText(value).toUpperCase();
  if (["TRUE", "Y", "YES", "1", "CHECKED"].includes(token)) return true;
  if (["FALSE", "N", "NO", "0", "UNCHECKED"].includes(token)) return false;
  throw new Error(`Unrecognized Boolean value: ${asText(value)}`);
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

function getCell(row, map, name) {
  const index = map.get(name);
  return index === undefined ? null : row[index];
}

function readRow(values, map, excelRow) {
  const row = values[excelRow - 1];
  if (!row) throw new Error(`Excel row ${excelRow} does not exist.`);
  const levels = [1, 2, 3, 4].map((level) => asText(getCell(row, map, `LEVEL_${level}`)));
  const visibleLevelIndex = levels.findLastIndex((title) => title !== "");
  const physicalSheets = asNumber(getCell(row, map, "PHYSICAL_SHEETS"));
  if (!Number.isInteger(physicalSheets) || physicalSheets < 0) {
    throw new Error(`Excel row ${excelRow} has an invalid physical page value.`);
  }
  return {
    excel_row: excelRow,
    node_id: asText(getCell(row, map, "node_id")),
    level: visibleLevelIndex >= 0 ? visibleLevelIndex + 1 : asNumber(getCell(row, map, "level")),
    title: visibleLevelIndex >= 0 ? levels[visibleLevelIndex] : "",
    requirement_ids: asList(getCell(row, map, "REQUIREMENT_ID")),
    a3_checked: asBoolean(getCell(row, map, "A3_CHECK")),
    physical_sheets: physicalSheets,
    owner_no_llm: asText(getCell(row, map, "OWNER_NO_LLM")),
    pm_note: asText(getCell(row, map, "PM_NOTE")),
    human_check: asText(getCell(row, map, "HUMAN_CHECK")),
  };
}

function setCell(sheet, values, map, excelRow, name, value) {
  if (!map.has(name)) throw new Error(`PM_WORKSPACE is missing required header: ${name}`);
  values[excelRow - 1][map.get(name)] = value;
  sheet.getCell(excelRow - 1, map.get(name)).values = [[value]];
}

function snapshotFromNode(node) {
  return {
    node_id: node.node_id,
    volume_id: node.volume_id,
    page_budget_id: node.page_budget_id,
    parent_id: node.parent_id,
    level: node.level,
    title: node.title,
    official_fixed: Boolean(node.official_fixed),
    a3_checked: Boolean(node.a3_checked),
    physical_sheets: node.physical_sheets,
    requirement_ids: [...(node.requirement_ids || node.req_ids || [])],
  };
}

function applyVisibleRow(node, row, inheritedRequirementIds = null) {
  const requirementIds = row.requirement_ids.length ? row.requirement_ids : [...(inheritedRequirementIds || [])];
  return {
    ...node,
    level: row.level,
    title: row.title,
    req_ids: requirementIds,
    requirement_ids: requirementIds,
    physical_sheets: row.physical_sheets,
    counted_pages: row.physical_sheets,
    a3_checked: row.a3_checked,
    owner_no_llm: row.owner_no_llm || null,
    pm_note: row.pm_note || null,
    human_check: row.human_check || "UNCONFIRMED",
  };
}

function writeAcceptedBaseline(sheet, values, map, excelRow, node) {
  const levels = [1, 2, 3, 4].map((level) => level === node.level ? node.title : null);
  setCell(sheet, values, map, excelRow, "SEQ", node.seq);
  setCell(sheet, values, map, excelRow, "HUMAN_CHECK", node.human_check || "CONFIRMED");
  setCell(sheet, values, map, excelRow, "origin", node.origin || null);
  setCell(sheet, values, map, excelRow, "official_fixed", node.official_fixed ? "Y" : "N");
  setCell(sheet, values, map, excelRow, "leaf", node.leaf ? "Y" : "N");
  setCell(sheet, values, map, excelRow, "baseline_A3", node.leaf ? Boolean(node.a3_checked) : null);
  setCell(sheet, values, map, excelRow, "baseline_physical", node.physical_sheets ?? null);
  ["baseline_L1", "baseline_L2", "baseline_L3", "baseline_L4"].forEach((name, index) => {
    setCell(sheet, values, map, excelRow, name, levels[index]);
  });
  setCell(sheet, values, map, excelRow, "baseline_budget", node.page_budget_id);
  setCell(sheet, values, map, excelRow, "baseline_volume", node.volume_id);
  setCell(sheet, values, map, excelRow, "baseline_parent", node.parent_id || null);
  setCell(sheet, values, map, excelRow, "baseline_level", node.level);
  setCell(sheet, values, map, excelRow, "baseline_title", node.title);
}

function tableBodyValues(sheet, headerRows = 4) {
  return sheet.getUsedRange().values.slice(headerRows);
}

function ensureTableBodyRows(sheet, desiredRows, columnCount, headerRows = 4) {
  const currentRows = Math.max(0, sheet.getUsedRange().values.length - headerRows);
  const missing = desiredRows - currentRows;
  if (missing <= 0) return;
  const blankRows = Array.from({ length: missing }, () => Array(columnCount).fill(null));
  const table = sheet.tables.items[0];
  if (!table) throw new Error(`Expected an Excel table on ${sheet.name}.`);
  table.rows.add(null, blankRows);
}

function getOrCreateSystemSheet(workbook, name, headers, tableName) {
  let sheet;
  let created = false;
  try {
    sheet = workbook.worksheets.getItem(name);
  } catch {
    sheet = workbook.worksheets.add(name);
    created = true;
    sheet.getRange("A1").values = [[name]];
    sheet.getRangeByIndexes(3, 0, 1, headers.length).values = [headers];
    const lastColumn = String.fromCharCode(64 + headers.length);
    sheet.tables.add(`A4:${lastColumn}4`, true, tableName);
  }
  if (!sheet.tables.items[0]) throw new Error(`System sheet ${name} is missing its required table.`);
  return { sheet, created };
}

function tocPath(state, nodeId) {
  const nodeMap = new Map(state.toc_nodes.map((node) => [node.node_id, node]));
  const titles = [];
  let cursor = nodeMap.get(nodeId);
  while (cursor) {
    titles.unshift(cursor.title);
    cursor = cursor.parent_id ? nodeMap.get(cursor.parent_id) : null;
  }
  return titles.join(" > ");
}

function syncSystemSheets(workbook, state) {
  const snapshot = getOrCreateSystemSheet(workbook, "SYS_SNAPSHOT",
    ["node_id", "volume_id", "page_budget_id", "baseline_L1", "baseline_L2", "baseline_L3", "baseline_parent", "baseline_level", "baseline_A3", "baseline_physical", "official_fixed", "status"],
    "AcceptanceSnapshotTable");
  const mapping = getOrCreateSystemSheet(workbook, "SYS_MAPPING",
    ["map_id", "obligation_id", "target_node_id", "relation", "requirement_id", "source_id", "evidence", "validation_status", "toc_path"],
    "AcceptanceMappingTable");
  const rpa = getOrCreateSystemSheet(workbook, "SYS_RPA_SPEC",
    ["release_id", "volume_id", "page_budget_id", "page_id", "node_id", "page_order", "page_format", "physical_sheets", "counted_start", "counted_end", "layout_key", "release_status"],
    "AcceptanceRpaTable");
  const change = getOrCreateSystemSheet(workbook, "CHANGE_REVIEW",
    ["node_id", "VOLUME", "BUDGET", "LEVEL_1", "LEVEL_2", "LEVEL_3", "CHANGE_TYPE", "BASELINE_A3", "CURRENT_A3", "CURRENT_PAGES", "ACTION"],
    "AcceptanceChangeTable");
  const snapshotSheet = snapshot.sheet;
  const mappingSheet = mapping.sheet;
  const rpaSheet = rpa.sheet;
  const changeSheet = change.sheet;

  const snapshotRows = state.toc_nodes.map((node) => {
    const levels = [1, 2, 3].map((level) => level === node.level ? node.title : null);
    return [
      node.node_id, node.volume_id, node.page_budget_id, ...levels,
      node.parent_id || null, node.level, node.leaf ? Boolean(node.a3_checked) : null,
      node.physical_sheets ?? null, node.official_fixed ? "Y" : "N", "BASELINE",
    ];
  });
  ensureTableBodyRows(snapshotSheet, snapshotRows.length, 12);
  snapshotSheet.getRangeByIndexes(4, 0, snapshotRows.length, 12).values = snapshotRows;

  const oldMappingRows = tableBodyValues(mappingSheet);
  const oldMappingById = new Map(oldMappingRows.map((row) => [asText(row[0]), row]));
  const requirementByObligation = new Map(state.requirements.map((item) => [item.obligation_id, item]));
  const mappingRows = state.mappings.map((mapping) => {
    const prior = oldMappingById.get(mapping.map_id) || [];
    const requirement = requirementByObligation.get(mapping.obligation_id);
    return [
      mapping.map_id,
      mapping.obligation_id,
      mapping.target_node_id,
      mapping.relation,
      requirement?.requirement_id || prior[4] || null,
      requirement?.source_id || prior[5] || null,
      mapping.evidence || prior[6] || null,
      mapping.validation_status || prior[7] || null,
      tocPath(state, mapping.target_node_id),
    ];
  });
  ensureTableBodyRows(mappingSheet, mappingRows.length, 9);
  mappingSheet.getRangeByIndexes(4, 0, mappingRows.length, 9).values = mappingRows;

  const oldRpaRows = tableBodyValues(rpaSheet);
  const oldRpaByNode = new Map(oldRpaRows.map((row) => [asText(row[4]), row]));
  const leafNodes = state.toc_nodes.filter((node) => node.leaf);
  const rpaRows = leafNodes.map((node, index) => {
    const prior = oldRpaByNode.get(node.node_id) || oldRpaByNode.get(state.roundtrip_acceptance?.accepted_events
      .find((event) => event.type === "APPROVED_SPLIT" && event.new_node_id === node.node_id)?.source_node_id) || [];
    return [
      prior[0] || "CASE3-DRAFT",
      node.volume_id,
      node.page_budget_id,
      `PAGE-C3-${String(index + 1).padStart(3, "0")}`,
      node.node_id,
      index + 1,
      node.a3_checked ? "A3" : "A4",
      node.physical_sheets ?? null,
      prior[8] ?? null,
      prior[9] ?? null,
      prior[10] ?? null,
      "HOLD",
    ];
  });
  ensureTableBodyRows(rpaSheet, rpaRows.length, 12);
  rpaSheet.getRangeByIndexes(4, 0, rpaRows.length, 12).values = rpaRows;

  const desiredChangeRows = state.toc_nodes.length;
  const currentChangeRows = tableBodyValues(changeSheet).length;
  if (desiredChangeRows > currentChangeRows) {
    ensureTableBodyRows(changeSheet, desiredChangeRows, 11);
    for (let index = currentChangeRows; index < desiredChangeRows; index += 1) {
      const source = changeSheet.getRangeByIndexes(index + 3, 0, 1, 11);
      const target = changeSheet.getRangeByIndexes(index + 4, 0, 1, 11);
      target.copyFrom(source, "all");
    }
  }
  if (change.created) {
    const changeRows = state.toc_nodes.map((node) => {
      const levels = [1, 2, 3].map((level) => level === node.level ? node.title : null);
      return [node.node_id, node.volume_id, node.page_budget_id, ...levels, "UNCHANGED",
        node.leaf ? Boolean(node.a3_checked) : null, node.leaf ? Boolean(node.a3_checked) : null,
        node.physical_sheets ?? null, "IGNORE"];
    });
    changeSheet.getRangeByIndexes(4, 0, changeRows.length, 11).values = changeRows;
  } else {
    for (let column = 0; column < 11; column += 1) {
      changeSheet.getRangeByIndexes(4, column, desiredChangeRows, 1).fillDown();
    }
  }

  let guideSheet = null;
  try {
    guideSheet = workbook.worksheets.getItem("ROUNDTRIP_GUIDE");
  } catch {
    guideSheet = null;
  }
  if (guideSheet) {
    guideSheet.getRange("A1").values = [["AER TOC WORKBOOK ROUNDTRIP ACCEPTED v0.3"]];
    guideSheet.getRange("A2").values = [["Approved PM edits were applied to a new baseline. The original test rows below remain as protocol provenance, not as pending instructions."]];
  }
  return {
    recovered: [snapshot, mapping, rpa, change].filter((item) => item.created).map((item) => item.sheet.name),
    required: ["SYS_SNAPSHOT", "SYS_MAPPING", "SYS_RPA_SPEC", "CHANGE_REVIEW"],
  };
}

function nextMappingId(state, sourceMapping, newNodeId) {
  const digest = crypto.createHash("sha256")
    .update(`${state.case_id}|${sourceMapping?.obligation_id || ""}|${newNodeId}`)
    .digest("hex").slice(0, 10).toUpperCase();
  return `MAP-SPLIT-${digest}`;
}

async function writeJsonSafely(filePath, value) {
  const resolved = path.resolve(filePath);
  await fs.mkdir(path.dirname(resolved), { recursive: true });
  const temporary = `${resolved}.${process.pid}.${Date.now()}.tmp`;
  try {
    await fs.writeFile(temporary, JSON.stringify(value, null, 2), "utf8");
    await fs.rename(temporary, resolved);
  } catch (error) {
    await fs.rm(temporary, { force: true });
    throw error;
  }
}

async function sha256File(filePath) {
  return crypto.createHash("sha256").update(await fs.readFile(filePath)).digest("hex").toUpperCase();
}

function validateDistinctPaths(paths) {
  const resolved = paths.map(normalizedPath);
  if (new Set(resolved).size !== resolved.length) {
    throw new Error("All input and output paths must be distinct.");
  }
}

export async function acceptRoundtrip({
  workbookPath,
  baselinePath,
  decisionsPath,
  acceptedWorkbookPath,
  acceptedStatePath,
  verificationReportPath,
  acceptanceReceiptPath,
}) {
  validateDistinctPaths([
    workbookPath,
    baselinePath,
    decisionsPath,
    acceptedWorkbookPath,
    acceptedStatePath,
    verificationReportPath,
    acceptanceReceiptPath,
  ]);
  if (path.extname(acceptedWorkbookPath).toLowerCase() !== ".xlsx") {
    throw new Error("AcceptedWorkbookPath must use the .xlsx extension.");
  }
  for (const jsonPath of [decisionsPath, acceptedStatePath, verificationReportPath, acceptanceReceiptPath]) {
    if (path.extname(jsonPath).toLowerCase() !== ".json") throw new Error("Decision, state, and report paths must use the .json extension.");
  }

  const state = normalizeState(JSON.parse(await fs.readFile(baselinePath, "utf8")));
  if (state.contract_version !== "0.3.0") throw new Error("Acceptance routine v0.1.0 currently supports contract v0.3.0 only.");
  const decisions = JSON.parse(await fs.readFile(decisionsPath, "utf8"));
  if (decisions.decision_version !== "0.1.0") throw new Error("Unsupported decision version.");
  if (decisions.case_id !== state.case_id) throw new Error("Decision case_id does not match the baseline state.");
  if (!Array.isArray(decisions.confirmed_changes) || !Array.isArray(decisions.splits)) {
    throw new Error("Decision input must contain confirmed_changes and splits arrays.");
  }

  const workbook = await SpreadsheetFile.importXlsx(await FileBlob.load(workbookPath));
  const sheet = workbook.worksheets.getItem("PM_WORKSPACE");
  if (!sheet) throw new Error("PM_WORKSPACE sheet is missing.");
  const usedRange = sheet.getUsedRange();
  const values = usedRange.values;
  const headerRow = findHeaderRow(values);
  const headerMap = makeHeaderMap(values[headerRow]);
  state.toc_nodes.forEach((node, index) => {
    if (!Number.isFinite(node.seq)) node.seq = index + 1;
  });
  const stateNodeMap = new Map(state.toc_nodes.map((node) => [node.node_id, node]));
  const snapshotMap = new Map(state.baseline_snapshot.map((row) => [row.node_id, row]));
  const acceptedEvents = [];

  for (const decision of decisions.confirmed_changes) {
    const row = readRow(values, headerMap, decision.excel_row);
    if (row.node_id !== decision.node_id) throw new Error(`Confirmed row ${decision.excel_row} does not match node_id ${decision.node_id}.`);
    const node = stateNodeMap.get(decision.node_id);
    if (!node) throw new Error(`Confirmed node does not exist in the baseline: ${decision.node_id}`);
    const allowedFields = new Set(["title", "physical_sheets", "a3_checked", "requirement_ids"]);
    if (!Array.isArray(decision.fields) || decision.fields.some((field) => !allowedFields.has(field))) {
      throw new Error(`Confirmed change contains an unsupported field for ${decision.node_id}.`);
    }
    const updated = { ...node, human_check: "CONFIRMED" };
    if (decision.fields.includes("title")) updated.title = row.title;
    if (decision.fields.includes("physical_sheets")) {
      updated.physical_sheets = row.physical_sheets;
      updated.counted_pages = row.physical_sheets;
    }
    if (decision.fields.includes("a3_checked")) updated.a3_checked = row.a3_checked;
    if (decision.fields.includes("requirement_ids")) {
      updated.requirement_ids = [...row.requirement_ids];
      updated.req_ids = [...row.requirement_ids];
    }
    stateNodeMap.set(updated.node_id, updated);
    snapshotMap.set(updated.node_id, snapshotFromNode(updated));
    setCell(sheet, values, headerMap, decision.excel_row, "HUMAN_CHECK", "CONFIRMED");
    acceptedEvents.push({ type: "CONFIRMED_CHANGE", node_id: updated.node_id, fields: [...decision.fields] });
  }

  for (const decision of decisions.splits) {
    const sourceNode = stateNodeMap.get(decision.source_node_id);
    if (!sourceNode || !sourceNode.leaf) throw new Error(`Split source must be an existing leaf: ${decision.source_node_id}`);
    if (stateNodeMap.has(decision.new_node_id)) throw new Error(`Split new_node_id already exists: ${decision.new_node_id}`);
    const sourceRow = readRow(values, headerMap, decision.source_excel_row);
    const newRow = readRow(values, headerMap, decision.new_excel_row);
    if (sourceRow.node_id !== decision.source_node_id) throw new Error("Split source row does not match its node_id.");
    if (newRow.node_id) throw new Error("Split target row already has a node_id and cannot be canonicalized as new.");
    if (sourceRow.level !== sourceNode.level || newRow.level !== sourceNode.level) throw new Error("Split rows must preserve the source level.");
    if (sourceRow.physical_sheets + newRow.physical_sheets !== decision.expected_total_physical_sheets) {
      throw new Error("Split page total does not match the approved total.");
    }

    const inheritedRequirements = sourceNode.requirement_ids || sourceNode.req_ids || [];
    const updatedSource = { ...applyVisibleRow(sourceNode, sourceRow, inheritedRequirements), human_check: "CONFIRMED" };
    stateNodeMap.set(updatedSource.node_id, updatedSource);
    snapshotMap.set(updatedSource.node_id, snapshotFromNode(updatedSource));

    for (const node of stateNodeMap.values()) {
      if (Number.isFinite(node.seq) && node.seq > sourceNode.seq) node.seq += 1;
    }
    const newNode = { ...applyVisibleRow({
      ...sourceNode,
      seq: sourceNode.seq + 1,
      node_id: decision.new_node_id,
      parent_id: sourceNode.parent_id,
      volume_id: sourceNode.volume_id,
      page_budget_id: sourceNode.page_budget_id,
      origin: "HUMAN_APPROVED_SPLIT",
      official_fixed: false,
    }, newRow, inheritedRequirements), human_check: "CONFIRMED" };
    stateNodeMap.set(newNode.node_id, newNode);
    snapshotMap.set(newNode.node_id, snapshotFromNode(newNode));

    const sourceRange = sheet.getRangeByIndexes(decision.source_excel_row - 1, 0, 1, values[headerRow].length);
    const newRange = sheet.getRangeByIndexes(decision.new_excel_row - 1, 0, 1, values[headerRow].length);
    newRange.copyFrom(sourceRange, "all");
    for (let level = 1; level <= 4; level += 1) {
      setCell(sheet, values, headerMap, decision.new_excel_row, `LEVEL_${level}`, level === newNode.level ? newNode.title : null);
    }
    setCell(sheet, values, headerMap, decision.new_excel_row, "node_id", newNode.node_id);
    setCell(sheet, values, headerMap, decision.new_excel_row, "parent_id", newNode.parent_id);
    setCell(sheet, values, headerMap, decision.new_excel_row, "VOLUME", newNode.volume_id);
    setCell(sheet, values, headerMap, decision.new_excel_row, "PAGE_BUDGET", newNode.page_budget_id);
    setCell(sheet, values, headerMap, decision.new_excel_row, "REQUIREMENT_ID", newNode.requirement_ids.join(", "));
    setCell(sheet, values, headerMap, decision.new_excel_row, "A3_CHECK", newNode.a3_checked);
    setCell(sheet, values, headerMap, decision.new_excel_row, "PHYSICAL_SHEETS", newNode.physical_sheets);
    setCell(sheet, values, headerMap, decision.new_excel_row, "OWNER_NO_LLM", newNode.owner_no_llm);
    setCell(sheet, values, headerMap, decision.new_excel_row, "PM_NOTE", newNode.pm_note);
    setCell(sheet, values, headerMap, decision.new_excel_row, "HUMAN_CHECK", "CONFIRMED");
    if (headerMap.has("level")) setCell(sheet, values, headerMap, decision.new_excel_row, "level", newNode.level);

    const sourceMapping = state.mappings.find((mapping) => mapping.target_node_id === sourceNode.node_id);
    if (sourceMapping) {
      state.mappings.push({
        ...sourceMapping,
        map_id: nextMappingId(state, sourceMapping, newNode.node_id),
        target_node_id: newNode.node_id,
        relation: decision.new_mapping_relation || "SUB",
        evidence: "human-approved split of existing proposal TOC node",
        validation_status: "HUMAN_CONFIRMED",
      });
    }
    acceptedEvents.push({
      type: "APPROVED_SPLIT",
      source_node_id: updatedSource.node_id,
      new_node_id: newNode.node_id,
      source_pages: updatedSource.physical_sheets,
      new_pages: newNode.physical_sheets,
      total_pages: updatedSource.physical_sheets + newNode.physical_sheets,
    });
  }

  state.toc_nodes = [...stateNodeMap.values()].sort((left, right) => (left.seq ?? 0) - (right.seq ?? 0));
  state.baseline_snapshot = state.toc_nodes.map((node) => snapshotMap.get(node.node_id) || snapshotFromNode(node));
  state.roundtrip_acceptance = {
    decision_version: decisions.decision_version,
    acceptance_id: decisions.acceptance_id,
    accepted_at: new Date().toISOString(),
    accepted_events: acceptedEvents,
    original_workbook_preserved: true,
    rpa_release_unchanged: true,
  };
  state.approval_state = {
    ...state.approval_state,
    human_check: "REVIEW",
    allocation_status: "REVIEW",
  };
  state.rpa_release = typeof state.rpa_release === "object" && state.rpa_release !== null
    ? { ...state.rpa_release, state: "HOLD" }
    : "HOLD";

  const currentRowByNodeId = new Map();
  for (let excelRow = headerRow + 2; excelRow <= values.length; excelRow += 1) {
    const nodeId = asText(getCell(values[excelRow - 1], headerMap, "node_id"));
    if (nodeId) currentRowByNodeId.set(nodeId, excelRow);
  }
  for (const node of state.toc_nodes) {
    const excelRow = currentRowByNodeId.get(node.node_id);
    if (excelRow) writeAcceptedBaseline(sheet, values, headerMap, excelRow, node);
  }
  const firstDataRow = headerRow + 2;
  for (const formulaHeader of ["CHANGE_STATUS", "LLM_CHECK", "WARNING"]) {
    if (!headerMap.has(formulaHeader)) throw new Error(`PM_WORKSPACE is missing formula header: ${formulaHeader}`);
    const column = headerMap.get(formulaHeader);
    sheet.getRangeByIndexes(firstDataRow - 1, column, values.length - firstDataRow + 1, 1).fillDown();
  }
  const systemSheetResult = syncSystemSheets(workbook, state);
  await fs.mkdir(path.dirname(path.resolve(acceptedWorkbookPath)), { recursive: true });
  const outputWorkbook = await SpreadsheetFile.exportXlsx(workbook);
  await outputWorkbook.save(path.resolve(acceptedWorkbookPath));
  await writeJsonSafely(acceptedStatePath, state);
  const verification = await analyzeRoundtrip({
    workbookPath: acceptedWorkbookPath,
    baselinePath: acceptedStatePath,
    reportPath: verificationReportPath,
  });
  if (verification.summary.material_changes !== 0) throw new Error("Accepted roundtrip verification still contains material changes.");
  if (verification.formula_integrity.status !== "PASS") throw new Error("Accepted workbook contains formula errors.");
  if (verification.page_budgets.some((budget) => ["REVIEW", "INDETERMINATE"].includes(budget.status))) {
    throw new Error("Accepted state does not satisfy all determinable page budgets.");
  }
  const receipt = {
    receipt_version: "0.1.0",
    acceptance_engine_version: "0.1.1",
    case_id: state.case_id,
    inputs: {
      workbook: { path: path.resolve(workbookPath), sha256: await sha256File(workbookPath) },
      baseline: { path: path.resolve(baselinePath), sha256: await sha256File(baselinePath) },
      decisions: { path: path.resolve(decisionsPath), sha256: await sha256File(decisionsPath) },
    },
    outputs: {
      accepted_workbook: { path: path.resolve(acceptedWorkbookPath), sha256: await sha256File(acceptedWorkbookPath) },
      accepted_state: { path: path.resolve(acceptedStatePath), sha256: await sha256File(acceptedStatePath) },
      verification_report: { path: path.resolve(verificationReportPath), sha256: await sha256File(verificationReportPath) },
    },
    system_sheets: { status: "PASS", ...systemSheetResult },
    verification: { summary: verification.summary, formula_integrity: verification.formula_integrity.status,
      release_recommendation: verification.release_recommendation },
    rpa_release: "HOLD",
  };
  await writeJsonSafely(acceptanceReceiptPath, receipt);
  return {
    acceptance_engine_version: "0.1.1",
    case_id: state.case_id,
    accepted_events: acceptedEvents,
    accepted_workbook_path: path.resolve(acceptedWorkbookPath),
    accepted_state_path: path.resolve(acceptedStatePath),
    verification_report_path: path.resolve(verificationReportPath),
    acceptance_receipt_path: path.resolve(acceptanceReceiptPath),
    verification_summary: verification.summary,
    page_budgets: verification.page_budgets,
    release_recommendation: verification.release_recommendation,
  };
}

const directExecution = process.argv[1]
  && import.meta.url === `file:///${process.argv[1].replaceAll("\\", "/")}`;
if (directExecution) {
  const [workbookPath, baselinePath, decisionsPath, acceptedWorkbookPath, acceptedStatePath, verificationReportPath, acceptanceReceiptPath] = process.argv.slice(2);
  if (!acceptanceReceiptPath) {
    throw new Error("Usage: node aer-toc-roundtrip-accept.mjs <workbook.xlsx> <baseline.json> <decisions.json> <accepted.xlsx> <accepted-state.json> <verification.json> <receipt.json>");
  }
  console.log(JSON.stringify(await acceptRoundtrip({
    workbookPath,
    baselinePath,
    decisionsPath,
    acceptedWorkbookPath,
    acceptedStatePath,
    verificationReportPath,
    acceptanceReceiptPath,
  }), null, 2));
}
