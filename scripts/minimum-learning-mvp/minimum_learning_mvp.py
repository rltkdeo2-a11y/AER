#!/usr/bin/env python3
"""Minimum Learning MVP: one persistent, source-bound control state.

The CLI deliberately excludes LLM, OCR, retrieval, reranking, UI, graph DB, and
workflow orchestration. It persists only source, statement, relation, revision,
and operation records needed by G5-1 through G5-9.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sqlite3
import sys
import zipfile
from contextlib import closing, contextmanager
from datetime import datetime, timezone
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import Any, Iterable


BUILD_VERSION = "0.1.0-dev"
SCHEMA_PATH = Path(__file__).with_name("schema.sql")
STATEMENT_TYPES = {"FACT", "DISCUSSION", "DECISION", "APPROVAL", "EFFECTIVE"}
DISPOSITIONS = {"CURRENT", "SUPERSEDED", "DISPUTED", "UNCERTAIN"}
REVIEW_STATES = {"AUTO", "REVIEWED", "REVIEW_REQUIRED"}
RELATION_TYPES = {
    "EVIDENCED_BY", "PRECEDES", "SUPERSEDES", "CONFLICTS_WITH",
    "APPROVES", "MAKES_EFFECTIVE", "DEPENDS_ON", "IMPACTS",
}
HUMAN_ACTIVITIES = {
    "자료탐색", "원문확인", "문서간 대조", "상태판정", "근거연결",
    "변경·대체 판정", "영향범위 판정", "결과정정", "fixture-specific 준비/초기화",
}
HEADER_RE = re.compile(r"^([A-Za-z][A-Za-z -]*):\s*(.+?)\s*$")
DATE_RE = re.compile(r"(20\d{2})[-_.](\d{2})[-_.](\d{2})")
TOKEN_RE = re.compile(r"[0-9A-Za-z가-힣]+(?:-[0-9A-Za-z가-힣]+)*")
STOPWORDS = {
    "project", "문서", "현재", "변경", "내용", "확인", "필요", "완료", "기준",
    "해당", "적용", "업무", "고객", "프로젝트", "진행", "상태", "대한", "따른",
}


def utc_now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def stable_id(*parts: str) -> str:
    value = "\x1f".join(parts).encode("utf-8")
    return hashlib.sha256(value).hexdigest()[:24]


def connect(db_path: Path) -> sqlite3.Connection:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    conn.executescript(SCHEMA_PATH.read_text(encoding="utf-8"))
    return conn


def parse_markdown(path: Path, root: Path) -> dict[str, Any]:
    raw = path.read_text(encoding="utf-8")
    lines = raw.splitlines()
    title = next((line[2:].strip() for line in lines if line.startswith("# ")), path.stem)
    headers: dict[str, str] = {}
    header_lines: set[int] = set()
    for index, line in enumerate(lines[:30], start=1):
        match = HEADER_RE.match(line.strip())
        if match:
            headers[match.group(1).strip().lower().replace(" ", "_")] = match.group(2).strip()
            header_lines.add(index)
    relative = path.relative_to(root).as_posix()
    scope = headers.get("scope", "unknown").lower()
    project = infer_project(path, root, scope)
    use_scope = infer_use_scope(scope, project)
    operational_instruction = path.name.upper() in {"TASK.MD", "TASKS.MD"}
    if operational_instruction:
        project = "ORG"
        scope = "evaluation_instruction"
        use_scope = "ORG"
    event_time = headers.get("date") or headers.get("signed") or date_from_name(path.name)
    effective_time = headers.get("effective")
    document_id = headers.get("document_id")
    source_id = document_id or f"PATH:{relative}"
    candidates: list[dict[str, Any]] = []

    if not operational_instruction and headers.get("signed") and re.search(r"계약|합의서|승인", title):
        candidates.append({
            "line_start": 1,
            "line_end": 1,
            "statement_type": "APPROVAL",
            "content": f"{title} signed on {headers['signed']}",
            "event_time": headers["signed"],
            "effective_time": effective_time,
            "disposition": "CURRENT",
            "uncertainty": None,
        })
    if not operational_instruction and effective_time:
        candidates.append({
            "line_start": 1,
            "line_end": 1,
            "statement_type": "EFFECTIVE",
            "content": f"{title} effective on {effective_time}",
            "event_time": event_time,
            "effective_time": effective_time,
            "disposition": "CURRENT",
            "uncertainty": None,
        })

    section = ""
    for index, raw_line in enumerate(lines, start=1):
        if operational_instruction:
            break
        line = raw_line.strip()
        if not line or index in header_lines or line.startswith("# "):
            continue
        if line.startswith("##"):
            section = line.lstrip("#").strip()
            continue
        line = re.sub(r"^[-*]\s+", "", line)
        if not line:
            continue
        statement_type, disposition, uncertainty = classify_statement(line, section, title)
        candidates.append({
            "line_start": index,
            "line_end": index,
            "statement_type": statement_type,
            "content": line,
            "event_time": event_time,
            "effective_time": effective_time,
            "disposition": disposition,
            "uncertainty": uncertainty,
        })

    return {
        "source_id": source_id,
        "document_id": document_id,
        "relative_path": relative,
        "project_id": project,
        "context": scope,
        "use_scope": use_scope,
        "document_time": event_time,
        "effective_time": effective_time,
        "metadata": {"title": title, **headers},
        "candidates": candidates,
        "raw": raw.encode("utf-8"),
    }


def parse_json_source(path: Path, root: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    relative = path.relative_to(root).as_posix()
    candidates: list[dict[str, Any]] = []
    if isinstance(data, dict) and isinstance(data.get("rules"), list):
        for index, rule in enumerate(data["rules"], start=1):
            content = rule.get("rule") if isinstance(rule, dict) else str(rule)
            candidates.append({
                "line_start": index,
                "line_end": index,
                "statement_type": "FACT",
                "content": content,
                "event_time": None,
                "effective_time": None,
                "disposition": "CURRENT",
                "uncertainty": None,
            })
    raw = path.read_bytes()
    return {
        "source_id": f"PATH:{relative}",
        "document_id": None,
        "relative_path": relative,
        "project_id": "ORG",
        "context": "policy_manifest",
        "use_scope": "ORG",
        "document_time": None,
        "effective_time": None,
        "metadata": data if isinstance(data, dict) else {"value": data},
        "candidates": candidates,
        "raw": raw,
    }


def infer_project(path: Path, root: Path, scope: str) -> str:
    if scope.startswith("project_") and scope != "project_only":
        return scope.removeprefix("project_").upper()
    relative_parts = path.relative_to(root).parts
    lowered = [part.lower() for part in relative_parts]
    if "projects" in lowered:
        index = lowered.index("projects")
        if index + 1 < len(relative_parts):
            return relative_parts[index + 1].upper()
    if scope == "c0":
        return "C0"
    return "ORG"


def infer_use_scope(scope: str, project: str) -> str:
    if scope in {"org_current", "org_historical", "policy_manifest"}:
        return "ORG"
    if scope == "project_only" or scope.startswith("personal_note"):
        return f"PROJECT_ONLY:{project}"
    if scope.startswith("project_"):
        return "ORG_REFERENCE"
    if scope == "c0":
        return "PROJECT_ONLY:C0"
    return "UNKNOWN"


def date_from_name(name: str) -> str | None:
    match = DATE_RE.search(name)
    return "-".join(match.groups()) if match else None


def classify_statement(line: str, section: str, title: str) -> tuple[str, str, str | None]:
    text = f"{section} {line}"
    unresolved = bool(re.search(r"확인 필요|찾지 못|미기재|공란|가정|검토안|예정|불일치|FAIL|미완료|알 수 없", text, re.I))
    negative_approval = bool(re.search(r"승인.*(공란|여부|확인|찾지 못|미완료)|공식 승인 절차", text))
    if re.search(r"효력.*발생|발효", text) and not unresolved:
        statement_type = "EFFECTIVE"
    elif re.search(r"서명 완료|서명본|승인내용|승인 처리|승인 완료", text) and not negative_approval:
        statement_type = "APPROVAL"
    elif re.search(r"회의 결론|결론:|결정|변경없음", text):
        statement_type = "DECISION"
    elif re.search(r"논의|검토|제안|방향|초안|예정|필요", text):
        statement_type = "DISCUSSION"
    else:
        statement_type = "FACT"
    disposition = "UNCERTAIN" if unresolved else "CURRENT"
    uncertainty = "source expresses unresolved, conditional, missing, or unverified state" if unresolved else None
    return statement_type, disposition, uncertainty


def record_operation(
    conn: sqlite3.Connection,
    args: argparse.Namespace,
    operation_type: str,
    started_at: str,
    affected_sources: int,
    affected_statements: int,
    details: dict[str, Any],
) -> None:
    conn.execute(
        """INSERT INTO operations(
            run_id, task_id, condition_name, phase, operation_type, started_at, ended_at,
            human_seconds, human_action, affected_sources, affected_statements, details_json
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        (
            getattr(args, "run_id", None), getattr(args, "task_id", None),
            getattr(args, "condition", None), getattr(args, "phase", None), operation_type,
            started_at, utc_now(), float(getattr(args, "human_seconds", 0) or 0),
            getattr(args, "human_action", None), affected_sources, affected_statements,
            json.dumps(details, ensure_ascii=False, sort_keys=True),
        ),
    )


def insert_relation(
    conn: sqlite3.Connection,
    from_kind: str,
    from_id: str,
    to_kind: str,
    to_id: str,
    relation_type: str,
    evidence_source_id: str | None,
    created_by: str,
) -> str:
    relation_id = stable_id(from_kind, from_id, relation_type, to_kind, to_id, evidence_source_id or "")
    conn.execute(
        """INSERT OR IGNORE INTO relations(
            relation_id, from_kind, from_id, to_kind, to_id, relation_type,
            evidence_source_id, status, created_by, created_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 'ACTIVE', ?, ?)""",
        (relation_id, from_kind, from_id, to_kind, to_id, relation_type, evidence_source_id, created_by, utc_now()),
    )
    return relation_id


def mark_dependents(conn: sqlite3.Connection, source_id: str) -> set[str]:
    affected = {
        row["statement_id"]
        for row in conn.execute("SELECT statement_id FROM statements WHERE source_id = ?", (source_id,))
    }
    queue = list(affected)
    while queue:
        current = queue.pop()
        for row in conn.execute(
            """SELECT from_id FROM relations
               WHERE to_kind='STATEMENT' AND to_id=? AND from_kind='STATEMENT'
                 AND relation_type IN ('DEPENDS_ON', 'APPROVES', 'MAKES_EFFECTIVE', 'IMPACTS')
                 AND status='ACTIVE'""",
            (current,),
        ):
            if row["from_id"] not in affected:
                affected.add(row["from_id"])
                queue.append(row["from_id"])
    if affected:
        conn.executemany(
            "UPDATE statements SET review_state='REVIEW_REQUIRED', updated_at=? WHERE statement_id=?",
            [(utc_now(), statement_id) for statement_id in affected],
        )
    return affected


def ingest_one(conn: sqlite3.Connection, path: Path, root: Path) -> tuple[str, str, list[str]]:
    parsed = parse_markdown(path, root) if path.suffix.lower() == ".md" else parse_json_source(path, root)
    source_hash = sha256_bytes(parsed.pop("raw"))
    candidates = parsed.pop("candidates")
    existing = conn.execute("SELECT * FROM sources WHERE source_id = ?", (parsed["source_id"],)).fetchone()
    now = utc_now()
    change = "ADDED"
    impacted: set[str] = set()
    if existing and existing["content_hash"] == source_hash:
        conn.execute("UPDATE sources SET updated_at=? WHERE source_id=?", (now, parsed["source_id"]))
        return parsed["source_id"], "UNCHANGED", []
    if existing:
        change = "CHANGED"
        impacted = mark_dependents(conn, parsed["source_id"])
        conn.execute(
            """INSERT INTO revisions(target_kind, target_id, field_name, before_value, after_value,
               reason, reviewer, revised_at) VALUES ('SOURCE', ?, 'content_hash', ?, ?,
               'source bytes changed during ingest', 'SYSTEM', ?)""",
            (parsed["source_id"], existing["content_hash"], source_hash, now),
        )
        conn.execute(
            "UPDATE statements SET disposition='SUPERSEDED', review_state='REVIEW_REQUIRED', updated_at=? WHERE source_id=?",
            (now, parsed["source_id"]),
        )
        conn.execute(
            """UPDATE sources SET relative_path=?, document_id=?, project_id=?, context=?, use_scope=?,
               document_time=?, effective_time=?, content_hash=?, content_version=content_version+1,
               state='CHANGED', metadata_json=?, updated_at=? WHERE source_id=?""",
            (
                parsed["relative_path"], parsed["document_id"], parsed["project_id"], parsed["context"],
                parsed["use_scope"], parsed["document_time"], parsed["effective_time"], source_hash,
                json.dumps(parsed["metadata"], ensure_ascii=False, sort_keys=True), now, parsed["source_id"],
            ),
        )
    else:
        conn.execute(
            """INSERT INTO sources(source_id, relative_path, document_id, project_id, context, use_scope,
               document_time, effective_time, content_hash, metadata_json, ingested_at, updated_at)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (
                parsed["source_id"], parsed["relative_path"], parsed["document_id"], parsed["project_id"],
                parsed["context"], parsed["use_scope"], parsed["document_time"], parsed["effective_time"],
                source_hash, json.dumps(parsed["metadata"], ensure_ascii=False, sort_keys=True), now, now,
            ),
        )

    approval_ids: list[str] = []
    effective_ids: list[str] = []
    new_statement_ids: list[str] = []
    version = (existing["content_version"] + 1) if existing else 1
    for candidate in candidates:
        statement_id = stable_id(
            parsed["source_id"], str(version), str(candidate["line_start"]), candidate["content"]
        )
        conn.execute(
            """INSERT OR IGNORE INTO statements(
               statement_id, source_id, project_id, context, use_scope, line_start, line_end,
               statement_type, content, event_time, effective_time, disposition, uncertainty,
               review_state, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'AUTO', ?, ?)""",
            (
                statement_id, parsed["source_id"], parsed["project_id"], parsed["context"], parsed["use_scope"],
                candidate["line_start"], candidate["line_end"], candidate["statement_type"], candidate["content"],
                candidate["event_time"], candidate["effective_time"], candidate["disposition"],
                candidate["uncertainty"], now, now,
            ),
        )
        insert_relation(conn, "STATEMENT", statement_id, "SOURCE", parsed["source_id"], "EVIDENCED_BY", parsed["source_id"], "AUTO")
        new_statement_ids.append(statement_id)
        if candidate["statement_type"] == "APPROVAL":
            approval_ids.append(statement_id)
        if candidate["statement_type"] == "EFFECTIVE":
            effective_ids.append(statement_id)
    for approval_id in approval_ids:
        for statement_id in new_statement_ids:
            if statement_id != approval_id:
                insert_relation(conn, "STATEMENT", approval_id, "STATEMENT", statement_id, "APPROVES", parsed["source_id"], "AUTO")
    for effective_id in effective_ids:
        for approval_id in approval_ids:
            insert_relation(conn, "STATEMENT", effective_id, "STATEMENT", approval_id, "MAKES_EFFECTIVE", parsed["source_id"], "AUTO")

    supersedes = parsed["metadata"].get("supersedes")
    if supersedes:
        insert_relation(conn, "SOURCE", parsed["source_id"], "SOURCE", supersedes, "SUPERSEDES", parsed["source_id"], "AUTO")
        conn.execute("UPDATE sources SET state='CHANGED', updated_at=? WHERE source_id=?", (now, supersedes))
        conn.execute(
            "UPDATE statements SET disposition='SUPERSEDED', review_state='REVIEW_REQUIRED', updated_at=? WHERE source_id=?",
            (now, supersedes),
        )
    return parsed["source_id"], change, sorted(impacted)


def refresh_precedes(conn: sqlite3.Connection) -> None:
    rows = conn.execute(
        """SELECT source_id, project_id, COALESCE(effective_time, document_time) AS when_at
           FROM sources WHERE state != 'MISSING' AND COALESCE(effective_time, document_time) IS NOT NULL
           ORDER BY project_id, when_at, source_id"""
    ).fetchall()
    previous: dict[str, str] = {}
    for row in rows:
        prior = previous.get(row["project_id"])
        if prior:
            insert_relation(conn, "SOURCE", prior, "SOURCE", row["source_id"], "PRECEDES", row["source_id"], "AUTO")
        previous[row["project_id"]] = row["source_id"]


def tokens(text: str) -> set[str]:
    return {token.lower() for token in TOKEN_RE.findall(text) if len(token) >= 2 and token.lower() not in STOPWORDS}


def discover_pulse_impacts(conn: sqlite3.Connection, new_sources: Iterable[str]) -> set[str]:
    affected: set[str] = set()
    for source_id in new_sources:
        new_rows = conn.execute(
            "SELECT statement_id, project_id, content FROM statements WHERE source_id=? AND disposition!='SUPERSEDED'",
            (source_id,),
        ).fetchall()
        for new_row in new_rows:
            new_tokens = tokens(new_row["content"])
            if not new_tokens:
                continue
            old_rows = conn.execute(
                """SELECT statement_id, content FROM statements
                   WHERE project_id=? AND source_id!=? AND disposition!='SUPERSEDED'""",
                (new_row["project_id"], source_id),
            ).fetchall()
            for old_row in old_rows:
                overlap = new_tokens & tokens(old_row["content"])
                strong_identifier = any("-" in token and any(ch.isdigit() for ch in token) for token in overlap)
                if len(overlap) >= 2 or strong_identifier:
                    affected.add(old_row["statement_id"])
                    insert_relation(
                        conn, "STATEMENT", new_row["statement_id"], "STATEMENT", old_row["statement_id"],
                        "IMPACTS", source_id, "AUTO",
                    )
    if affected:
        conn.executemany(
            "UPDATE statements SET review_state='REVIEW_REQUIRED', updated_at=? WHERE statement_id=?",
            [(utc_now(), statement_id) for statement_id in affected],
        )
    return affected


@contextmanager
def materialize_source_root(input_path: Path, pulse: bool, task_id: str | None):
    if input_path.is_dir():
        yield input_path, None
        return
    if not input_path.is_file() or input_path.suffix.lower() != ".zip":
        raise ValueError(f"input must be a directory or ZIP package: {input_path}")
    package_hash = sha256_file(input_path)
    with TemporaryDirectory() as temp_name:
        temp_root = Path(temp_name)
        with zipfile.ZipFile(input_path) as archive:
            for member in archive.infolist():
                member_path = Path(member.filename.replace("\\", "/"))
                if member_path.is_absolute() or ".." in member_path.parts:
                    raise ValueError(f"unsafe ZIP member path: {member.filename}")
            archive.extractall(temp_root)
        if pulse:
            if not task_id:
                raise ValueError("--task-id is required when a Change Pulse ZIP is ingested")
            selected = temp_root / "public" / "change_pulse" / task_id
        else:
            selected = temp_root / "public" / "main"
        if not selected.is_dir():
            raise ValueError(f"expected package subtree is missing: {selected.relative_to(temp_root)}")
        yield selected, package_hash


def ingest_command(args: argparse.Namespace, pulse: bool = False) -> dict[str, Any]:
    started = utc_now()
    input_path = Path(args.root).resolve()
    with materialize_source_root(input_path, pulse, getattr(args, "task_id", None)) as (root, package_hash):
        files = sorted(path for path in root.rglob("*") if path.is_file() and path.suffix.lower() in {".md", ".json"})
        changes: dict[str, list[str]] = {"ADDED": [], "CHANGED": [], "UNCHANGED": []}
        changed_impacts: set[str] = set()
        with closing(connect(Path(args.db))) as conn:
            for path in files:
                source_id, change, impacted = ingest_one(conn, path, root)
                changes[change].append(source_id)
                changed_impacts.update(impacted)
            refresh_precedes(conn)
            pulse_impacts = discover_pulse_impacts(conn, changes["ADDED"] + changes["CHANGED"]) if pulse else set()
            all_impacts = changed_impacts | pulse_impacts
            details = {
                "input": str(input_path), "package_sha256": package_hash, "changes": changes,
                "impacted_statement_ids": sorted(all_impacts),
            }
            record_operation(conn, args, "PULSE" if pulse else "INGEST", started, len(changes["ADDED"]) + len(changes["CHANGED"]), len(all_impacts), details)
            conn.commit()
    return details


def review_command(args: argparse.Namespace) -> dict[str, Any]:
    started = utc_now()
    allowed_fields = {
        "statement_type": STATEMENT_TYPES,
        "disposition": DISPOSITIONS,
        "review_state": REVIEW_STATES,
        "content": None,
        "uncertainty": None,
        "event_time": None,
        "effective_time": None,
    }
    if args.field not in allowed_fields:
        raise ValueError(f"field not reviewable: {args.field}")
    allowed_values = allowed_fields[args.field]
    if allowed_values and args.value not in allowed_values:
        raise ValueError(f"invalid {args.field}: {args.value}")
    with closing(connect(Path(args.db))) as conn:
        row = conn.execute("SELECT * FROM statements WHERE statement_id=?", (args.statement_id,)).fetchone()
        if not row:
            raise ValueError(f"statement not found: {args.statement_id}")
        before = row[args.field]
        now = utc_now()
        conn.execute(
            f"UPDATE statements SET {args.field}=?, review_state='REVIEWED', updated_at=? WHERE statement_id=?",
            (args.value, now, args.statement_id),
        )
        conn.execute(
            """INSERT INTO revisions(target_kind, target_id, field_name, before_value, after_value,
               reason, reviewer, revised_at) VALUES ('STATEMENT', ?, ?, ?, ?, ?, ?, ?)""",
            (args.statement_id, args.field, before, args.value, args.reason, args.reviewer, now),
        )
        details = {"statement_id": args.statement_id, "field": args.field, "before": before, "after": args.value}
        record_operation(conn, args, "REVIEW", started, 0, 1, details)
        conn.commit()
    return details


def relate_command(args: argparse.Namespace) -> dict[str, Any]:
    started = utc_now()
    if args.relation_type not in RELATION_TYPES:
        raise ValueError(f"invalid relation type: {args.relation_type}")
    with closing(connect(Path(args.db))) as conn:
        relation_id = insert_relation(
            conn, args.from_kind, args.from_id, args.to_kind, args.to_id,
            args.relation_type, args.evidence_source_id, "HUMAN",
        )
        now = utc_now()
        if args.relation_type == "CONFLICTS_WITH" and args.from_kind == args.to_kind == "STATEMENT":
            conn.executemany(
                "UPDATE statements SET disposition='DISPUTED', review_state='REVIEWED', updated_at=? WHERE statement_id=?",
                [(now, args.from_id), (now, args.to_id)],
            )
        if args.relation_type == "SUPERSEDES" and args.to_kind == "STATEMENT":
            conn.execute(
                "UPDATE statements SET disposition='SUPERSEDED', review_state='REVIEWED', updated_at=? WHERE statement_id=?",
                (now, args.to_id),
            )
        conn.execute(
            """INSERT INTO revisions(target_kind, target_id, field_name, before_value, after_value,
               reason, reviewer, revised_at) VALUES ('RELATION', ?, 'create', NULL, ?, ?, ?, ?)""",
            (relation_id, args.relation_type, args.reason, args.reviewer, now),
        )
        details = {"relation_id": relation_id, "relation_type": args.relation_type}
        record_operation(conn, args, "RELATE", started, 0, 2, details)
        conn.commit()
    return details


def allowed_for_target(use_scope: str, source_project: str, target_project: str | None) -> bool:
    if use_scope in {"ORG", "ORG_REFERENCE"}:
        return True
    if use_scope.startswith("PROJECT_ONLY:"):
        return target_project is not None and use_scope.split(":", 1)[1] == target_project.upper()
    return target_project is not None and source_project == target_project.upper()


def export_command(args: argparse.Namespace) -> dict[str, Any]:
    started = utc_now()
    with closing(connect(Path(args.db))) as conn:
        rows = conn.execute(
            """SELECT st.*, so.relative_path, so.content_hash, so.document_id
               FROM statements st JOIN sources so ON so.source_id=st.source_id
               WHERE (? IS NULL OR st.project_id=? OR st.project_id='ORG')
               ORDER BY COALESCE(st.effective_time, st.event_time, ''), st.project_id, st.statement_id""",
            (args.source_project, args.source_project),
        ).fetchall()
        visible = [dict(row) for row in rows if allowed_for_target(row["use_scope"], row["project_id"], args.target_project)]
        restricted_sources_by_id: dict[str, dict[str, Any]] = {}
        for row in rows:
            if allowed_for_target(row["use_scope"], row["project_id"], args.target_project):
                continue
            restricted_sources_by_id.setdefault(row["source_id"], {
                "source_id": row["source_id"],
                "document_id": row["document_id"],
                "relative_path": row["relative_path"],
                "project_id": row["project_id"],
                "use_scope": row["use_scope"],
                "applicable_to_target": False,
                "reason": "source may be read in the common corpus but its content cannot support the target project",
            })
        visible_ids = {row["statement_id"] for row in visible}
        source_ids = {row["source_id"] for row in visible}
        relations = [
            dict(row) for row in conn.execute("SELECT * FROM relations WHERE status='ACTIVE'").fetchall()
            if (
                (row["from_kind"] == "STATEMENT" and row["from_id"] in visible_ids)
                or (row["from_kind"] == "SOURCE" and row["from_id"] in source_ids)
            )
            and (
                (row["to_kind"] == "STATEMENT" and row["to_id"] in visible_ids)
                or (row["to_kind"] == "SOURCE" and row["to_id"] in source_ids)
            )
        ]
        payload = {
            "build_version": BUILD_VERSION,
            "target_project": args.target_project,
            "source_project": args.source_project,
            "statements": visible,
            "restricted_sources": list(restricted_sources_by_id.values()),
            "relations": relations,
        }
        record_operation(conn, args, "EXPORT", started, len(source_ids), len(visible), {
            "target_project": args.target_project, "source_project": args.source_project,
        })
        conn.commit()
    if args.output:
        Path(args.output).write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    return payload


def log_cost_command(args: argparse.Namespace) -> dict[str, Any]:
    if args.activity not in HUMAN_ACTIVITIES:
        raise ValueError(f"activity must be one of: {', '.join(sorted(HUMAN_ACTIVITIES))}")
    started = utc_now()
    details = {"activity": args.activity, "note": args.note}
    args.human_action = args.activity
    with closing(connect(Path(args.db))) as conn:
        record_operation(conn, args, "HUMAN_COST", started, 0, 0, details)
        conn.commit()
    return details


def validate_command(args: argparse.Namespace) -> dict[str, Any]:
    errors: list[str] = []
    warnings: list[str] = []
    with closing(connect(Path(args.db))) as conn:
        missing_evidence = conn.execute(
            """SELECT st.statement_id FROM statements st
               WHERE NOT EXISTS (
                 SELECT 1 FROM relations r WHERE r.from_kind='STATEMENT' AND r.from_id=st.statement_id
                   AND r.to_kind='SOURCE' AND r.to_id=st.source_id AND r.relation_type='EVIDENCED_BY'
                   AND r.status='ACTIVE'
               )"""
        ).fetchall()
        errors.extend(f"statement lacks active source evidence: {row['statement_id']}" for row in missing_evidence)
        dangling = conn.execute(
            """SELECT relation_id FROM relations r
               WHERE (from_kind='STATEMENT' AND NOT EXISTS (SELECT 1 FROM statements s WHERE s.statement_id=r.from_id))
                  OR (to_kind='STATEMENT' AND NOT EXISTS (SELECT 1 FROM statements s WHERE s.statement_id=r.to_id))
                  OR (from_kind='SOURCE' AND NOT EXISTS (SELECT 1 FROM sources s WHERE s.source_id=r.from_id))
                  OR (to_kind='SOURCE' AND NOT EXISTS (SELECT 1 FROM sources s WHERE s.source_id=r.to_id))"""
        ).fetchall()
        errors.extend(f"dangling relation endpoint: {row['relation_id']}" for row in dangling)
        unknown_scope = conn.execute("SELECT source_id FROM sources WHERE use_scope='UNKNOWN'").fetchall()
        warnings.extend(f"source use scope unresolved: {row['source_id']}" for row in unknown_scope)
        disputed_without_relation = conn.execute(
            """SELECT statement_id FROM statements st WHERE disposition='DISPUTED'
               AND NOT EXISTS (SELECT 1 FROM relations r WHERE r.relation_type='CONFLICTS_WITH'
                 AND (r.from_id=st.statement_id OR r.to_id=st.statement_id))"""
        ).fetchall()
        errors.extend(f"disputed statement lacks conflict relation: {row['statement_id']}" for row in disputed_without_relation)
        counts = {
            "sources": conn.execute("SELECT COUNT(*) FROM sources").fetchone()[0],
            "statements": conn.execute("SELECT COUNT(*) FROM statements").fetchone()[0],
            "relations": conn.execute("SELECT COUNT(*) FROM relations").fetchone()[0],
            "revisions": conn.execute("SELECT COUNT(*) FROM revisions").fetchone()[0],
            "operations": conn.execute("SELECT COUNT(*) FROM operations").fetchone()[0],
            "review_required": conn.execute("SELECT COUNT(*) FROM statements WHERE review_state='REVIEW_REQUIRED'").fetchone()[0],
        }
    return {"status": "PASS" if not errors else "FAIL", "errors": errors, "warnings": warnings, "counts": counts}


def status_command(args: argparse.Namespace) -> dict[str, Any]:
    with closing(connect(Path(args.db))) as conn:
        types = {row["statement_type"]: row["count"] for row in conn.execute(
            "SELECT statement_type, COUNT(*) AS count FROM statements GROUP BY statement_type"
        )}
        projects = {row["project_id"]: row["count"] for row in conn.execute(
            "SELECT project_id, COUNT(*) AS count FROM sources GROUP BY project_id"
        )}
        operations = {row["operation_type"]: row["count"] for row in conn.execute(
            "SELECT operation_type, COUNT(*) AS count FROM operations GROUP BY operation_type"
        )}
        human_seconds = conn.execute("SELECT COALESCE(SUM(human_seconds), 0) FROM operations").fetchone()[0]
    return {"build_version": BUILD_VERSION, "statement_types": types, "projects": projects, "operations": operations, "human_seconds": human_seconds}


def check_run_config(args: argparse.Namespace) -> dict[str, Any]:
    config_path = Path(args.config)
    config = json.loads(config_path.read_text(encoding="utf-8"))
    common = config.get("common", {})
    required_common = [
        "base_model", "base_model_version", "ocr_parser", "search_engine", "reranker",
        "context_limit", "call_limit", "cost_limit", "time_limit",
        "public_run_package_sha256", "change_pulse_package_sha256",
    ]
    unresolved = [f"common.{field}" for field in required_common if common.get(field) in (None, "", "UNRESOLVED")]
    errors: list[str] = []
    if config.get("B0", {}).get("persistent_control_state") is not False:
        errors.append("B0 persistent_control_state must be false")
    if config.get("Product", {}).get("persistent_control_state") is not True:
        errors.append("Product persistent_control_state must be true")
    product_tools = config.get("Product", {}).get("extra_tools_allowed_only_for_persistent_control_state", [])
    if any("control" not in tool.lower() and "minimum_learning" not in tool.lower() for tool in product_tools):
        errors.append("Product extra tool is not limited to persistent control state")
    hash_checks: dict[str, Any] = {}
    for label, path_value, field in (
        ("public", args.public_package, "public_run_package_sha256"),
        ("pulse", args.pulse_package, "change_pulse_package_sha256"),
    ):
        if path_value:
            actual = sha256_file(Path(path_value))
            expected = common.get(field)
            hash_checks[label] = {"actual": actual, "expected": expected, "match": actual == expected}
            if actual != expected:
                errors.append(f"{label} package hash mismatch")
    ready = not unresolved and not errors and config.get("freeze", {}).get("status") == "FROZEN"
    return {
        "status": "PASS" if ready else "HOLD",
        "blind_execution_ready": ready,
        "unresolved": unresolved,
        "errors": errors,
        "hash_checks": hash_checks,
        "independent_variable": "Product-only persistent minimum control state",
    }


def add_run_fields(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--run-id")
    parser.add_argument("--task-id")
    parser.add_argument("--condition", default="Product")
    parser.add_argument("--phase", default="initial")
    parser.add_argument("--human-seconds", type=float, default=0)
    parser.add_argument("--human-action")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--version", action="version", version=BUILD_VERSION)
    sub = parser.add_subparsers(dest="command", required=True)

    init = sub.add_parser("init", help="Create the SQLite control state")
    init.add_argument("--db", required=True)

    for name in ("ingest", "pulse"):
        command = sub.add_parser(name, help=f"{name} Public Markdown/JSON sources")
        command.add_argument("--db", required=True)
        command.add_argument("--root", required=True)
        add_run_fields(command)

    review = sub.add_parser("review", help="Partially correct one statement field with revision history")
    review.add_argument("--db", required=True)
    review.add_argument("--statement-id", required=True)
    review.add_argument("--field", required=True)
    review.add_argument("--value", required=True)
    review.add_argument("--reason", required=True)
    review.add_argument("--reviewer", required=True)
    add_run_fields(review)

    relate = sub.add_parser("relate", help="Add one reviewed relation")
    relate.add_argument("--db", required=True)
    relate.add_argument("--from-kind", choices=["SOURCE", "STATEMENT"], required=True)
    relate.add_argument("--from-id", required=True)
    relate.add_argument("--to-kind", choices=["SOURCE", "STATEMENT"], required=True)
    relate.add_argument("--to-id", required=True)
    relate.add_argument("--relation-type", choices=sorted(RELATION_TYPES), required=True)
    relate.add_argument("--evidence-source-id")
    relate.add_argument("--reason", required=True)
    relate.add_argument("--reviewer", required=True)
    add_run_fields(relate)

    export = sub.add_parser("export", help="Export accessible, source-bound control state for a common LLM")
    export.add_argument("--db", required=True)
    export.add_argument("--target-project")
    export.add_argument("--source-project")
    export.add_argument("--output")
    add_run_fields(export)

    log_cost = sub.add_parser("log-cost", help="Record fixture-specific human cost")
    log_cost.add_argument("--db", required=True)
    log_cost.add_argument("--activity", required=True)
    log_cost.add_argument("--note")
    add_run_fields(log_cost)

    validate = sub.add_parser("validate", help="Validate control-state invariants")
    validate.add_argument("--db", required=True)

    status = sub.add_parser("status", help="Summarize the control state")
    status.add_argument("--db", required=True)

    symmetry = sub.add_parser("check-run-config", help="Check blind readiness and B0/Product symmetry")
    symmetry.add_argument("--config", required=True)
    symmetry.add_argument("--public-package")
    symmetry.add_argument("--pulse-package")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        if args.command == "init":
            with closing(connect(Path(args.db))):
                pass
            result = {"status": "PASS", "db": str(Path(args.db).resolve()), "build_version": BUILD_VERSION}
        elif args.command == "ingest":
            result = ingest_command(args, pulse=False)
        elif args.command == "pulse":
            result = ingest_command(args, pulse=True)
        elif args.command == "review":
            result = review_command(args)
        elif args.command == "relate":
            result = relate_command(args)
        elif args.command == "export":
            result = export_command(args)
        elif args.command == "log-cost":
            result = log_cost_command(args)
        elif args.command == "validate":
            result = validate_command(args)
        elif args.command == "status":
            result = status_command(args)
        elif args.command == "check-run-config":
            result = check_run_config(args)
        else:
            raise AssertionError(args.command)
        print(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True))
        if args.command == "validate" and result["status"] != "PASS":
            return 2
        if args.command == "check-run-config" and result["status"] != "PASS":
            return 2
        return 0
    except (OSError, ValueError, sqlite3.Error, json.JSONDecodeError) as error:
        print(json.dumps({"status": "ERROR", "error": str(error)}, ensure_ascii=False), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
