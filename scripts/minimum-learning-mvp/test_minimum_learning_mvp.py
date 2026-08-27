from __future__ import annotations

import importlib.util
import json
import sqlite3
import tempfile
import unittest
from argparse import Namespace
from contextlib import closing
from pathlib import Path


MODULE_PATH = Path(__file__).with_name("minimum_learning_mvp.py")
SPEC = importlib.util.spec_from_file_location("minimum_learning_mvp", MODULE_PATH)
assert SPEC and SPEC.loader
MVP = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MVP)


def run_args(db: Path, root: Path, phase: str = "initial") -> Namespace:
    return Namespace(
        db=str(db), root=str(root), run_id="TEST-RUN", task_id="TASK-TEST",
        condition="Product", phase=phase, human_seconds=3.0,
        human_action="fixture-specific 준비/초기화",
    )


class MinimumLearningMvpTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.main = self.root / "main"
        self.pulse = self.root / "pulse"
        self.db = self.root / "state.sqlite3"
        (self.main / "org").mkdir(parents=True)
        (self.main / "projects" / "ALPHA").mkdir(parents=True)
        (self.main / "projects" / "BETA").mkdir(parents=True)
        self.pulse.mkdir(parents=True)

        (self.main / "org" / "01_old.md").write_text(
            "# 이전 지침\nDocument ID: ORG-OLD\nScope: org_historical\nDate: 2026-01-01\n\n"
            "변경은 회의에서 논의한다.\n",
            encoding="utf-8",
        )
        (self.main / "org" / "02_current.md").write_text(
            "# 현재 지침\nDocument ID: ORG-NEW\nScope: org_current\nDate: 2026-02-01\n"
            "Supersedes: ORG-OLD\n\n변경은 승인문서로 결정한다.\n",
            encoding="utf-8",
        )
        (self.main / "projects" / "ALPHA" / "01_contract.md").write_text(
            "# Project ALPHA 변경합의서 — 서명본\nDocument ID: ALP-CO-001\n"
            "Scope: project_alpha\nSigned: 2026-03-01\nEffective: 2026-03-02\n\n"
            "변경내용: I-17 매핑규칙을 2자리에서 3자리로 변경한다.\n",
            encoding="utf-8",
        )
        (self.main / "projects" / "ALPHA" / "02_minutes.md").write_text(
            "# ALPHA 회의록\nDocument ID: ALP-MIN-001\nScope: project_alpha\nDate: 2026-03-03\n\n"
            "논의: I-17 재시험 범위를 검토한다.\n회의 결론: I-17만 재시험하기로 결정했다.\n"
            "공식 승인 근거는 확인 필요하다.\n",
            encoding="utf-8",
        )
        (self.main / "projects" / "BETA" / "01_private.md").write_text(
            "# BETA 제한 메모\nDocument ID: BET-ONLY-001\nScope: project_only\nDate: 2026-03-04\n\n"
            "BETA 전용 승인방식을 사용했다.\n",
            encoding="utf-8",
        )
        (self.pulse / "alpha_change.md").write_text(
            "# ALPHA 고객 변경승인서\nDocument ID: ALP-APP-002\nScope: project_alpha\n"
            "Signed: 2026-03-10\nEffective: 2026-03-11\n\n"
            "승인내용: I-17 매핑규칙과 I-17 재시험 케이스를 변경한다.\n",
            encoding="utf-8",
        )

    def tearDown(self) -> None:
        self.temp.cleanup()

    def test_ingest_g5_state_review_scope_and_pulse(self) -> None:
        result = MVP.ingest_command(run_args(self.db, self.main), pulse=False)
        self.assertEqual(5, len(result["changes"]["ADDED"]))

        with closing(sqlite3.connect(self.db)) as conn:
            conn.row_factory = sqlite3.Row
            types = {row[0] for row in conn.execute("SELECT DISTINCT statement_type FROM statements")}
            self.assertEqual(MVP.STATEMENT_TYPES, types)
            source = conn.execute("SELECT * FROM sources WHERE source_id='ALP-CO-001'").fetchone()
            self.assertEqual("ALPHA", source["project_id"])
            self.assertEqual("project_alpha", source["context"])
            self.assertEqual("ORG_REFERENCE", source["use_scope"])
            evidence_count = conn.execute(
                "SELECT COUNT(*) FROM relations WHERE relation_type='EVIDENCED_BY'"
            ).fetchone()[0]
            statement_count = conn.execute("SELECT COUNT(*) FROM statements").fetchone()[0]
            self.assertEqual(statement_count, evidence_count)
            old_dispositions = {
                row[0] for row in conn.execute("SELECT disposition FROM statements WHERE source_id='ORG-OLD'")
            }
            self.assertEqual({"SUPERSEDED"}, old_dispositions)

        export_args = Namespace(
            db=str(self.db), target_project="GAMMA", source_project=None, output=None,
            run_id="TEST-RUN", task_id="TASK-TEST", condition="Product", phase="initial",
            human_seconds=1.0, human_action="원문확인",
        )
        exported = MVP.export_command(export_args)
        exported_sources = {row["source_id"] for row in exported["statements"]}
        self.assertNotIn("BET-ONLY-001", exported_sources)
        self.assertIn("ORG-NEW", exported_sources)
        self.assertIn("BET-ONLY-001", {row["source_id"] for row in exported["restricted_sources"]})

        with closing(sqlite3.connect(self.db)) as conn:
            statement_id = conn.execute(
                "SELECT statement_id FROM statements WHERE source_id='ALP-MIN-001' ORDER BY line_start LIMIT 1"
            ).fetchone()[0]
        review_args = Namespace(
            db=str(self.db), statement_id=statement_id, field="statement_type", value="DISCUSSION",
            reason="bounded reviewer correction", reviewer="reviewer-1", run_id="TEST-RUN",
            task_id="TASK-TEST", condition="Product", phase="initial", human_seconds=4.0,
            human_action="상태판정",
        )
        MVP.review_command(review_args)
        with closing(sqlite3.connect(self.db)) as conn:
            self.assertEqual(1, conn.execute("SELECT COUNT(*) FROM revisions WHERE target_kind='STATEMENT'").fetchone()[0])
            self.assertEqual("REVIEWED", conn.execute(
                "SELECT review_state FROM statements WHERE statement_id=?", (statement_id,)
            ).fetchone()[0])

        pulse_result = MVP.ingest_command(run_args(self.db, self.pulse, phase="pulse"), pulse=True)
        self.assertIn("ALP-APP-002", pulse_result["changes"]["ADDED"])
        self.assertGreater(len(pulse_result["impacted_statement_ids"]), 0)
        with closing(sqlite3.connect(self.db)) as conn:
            affected_projects = {
                row[0] for row in conn.execute(
                    "SELECT DISTINCT project_id FROM statements WHERE review_state='REVIEW_REQUIRED'"
                )
            }
            self.assertIn("ALPHA", affected_projects)
            self.assertNotIn("BETA", affected_projects)
            self.assertGreater(conn.execute("SELECT SUM(human_seconds) FROM operations").fetchone()[0], 0)

        validation = MVP.validate_command(Namespace(db=str(self.db)))
        self.assertEqual("PASS", validation["status"], validation)

    def test_conflict_relation_is_explicit(self) -> None:
        MVP.ingest_command(run_args(self.db, self.main), pulse=False)
        with closing(sqlite3.connect(self.db)) as conn:
            rows = conn.execute(
                "SELECT statement_id, source_id FROM statements WHERE project_id='ALPHA' AND statement_type IN ('FACT','DISCUSSION') LIMIT 2"
            ).fetchall()
        args = Namespace(
            db=str(self.db), from_kind="STATEMENT", from_id=rows[0][0],
            to_kind="STATEMENT", to_id=rows[1][0], relation_type="CONFLICTS_WITH",
            evidence_source_id=rows[0][1], reason="test conflict", reviewer="reviewer-1",
            run_id="TEST-RUN", task_id="TASK-TEST", condition="Product", phase="initial",
            human_seconds=2.0, human_action="문서간 대조",
        )
        MVP.relate_command(args)
        with closing(sqlite3.connect(self.db)) as conn:
            dispositions = {
                row[0] for row in conn.execute(
                    "SELECT disposition FROM statements WHERE statement_id IN (?, ?)",
                    (rows[0][0], rows[1][0]),
                )
            }
            self.assertEqual({"DISPUTED"}, dispositions)
        self.assertEqual("PASS", MVP.validate_command(Namespace(db=str(self.db)))["status"])

    def test_resolved_frozen_run_configuration_is_ready(self) -> None:
        config = Path(__file__).with_name("RUN_CONFIGURATION.json")
        result = MVP.check_run_config(Namespace(
            config=str(config), public_package=None, pulse_package=None,
        ))
        self.assertEqual("PASS", result["status"])
        self.assertTrue(result["blind_execution_ready"])
        self.assertEqual([], result["unresolved"])
        self.assertEqual([], result["errors"])
        self.assertEqual(
            "FROZEN",
            json.loads(config.read_text(encoding="utf-8"))["freeze"]["status"],
        )


if __name__ == "__main__":
    unittest.main()
