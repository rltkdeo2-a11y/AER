# Minimum Learning MVP

Status: implementation candidate for non-blind technical validation only. This directory is not canonical research authority and does not make the fixture blind-ready.

## Minimum state

The Product-only difference is one SQLite control state:

```text
source → statement → relation
                 ↘ revision
all operations → operation log
```

- `source` preserves locator, hash, project/context, time, and use scope. Export keeps restricted-source identity visible while excluding its content from target-project support.
- `statement` preserves FACT/DISCUSSION/DECISION/APPROVAL/EFFECTIVE, uncertainty, and review state.
- `relation` preserves evidence, temporal order, supersession, conflict, approval, effectiveness, dependency, and Pulse impact.
- `revision` preserves partial human correction without rewriting or deleting the source.
- `operation` records fixture-specific preparation, review, and Change Pulse human cost.

There is no LLM, OCR engine, search engine, reranker, vector store, graph database, UI, agent, knowledge portal, workflow platform, or project-management subsystem here. A later blind run must give B0 and Product the same model, parser/OCR, retrieval, corpus, permissions, and limits. This CLI supplies only Product's persistent control state.

## Processing flow

```text
Public fixture directory or frozen ZIP ingest
→ source hash and metadata registration
→ source-bound candidate statements
→ minimal temporal/evidence/supersession relations
→ scope-filtered state export for a common downstream model
→ statement- or relation-level review with revision history
→ Change Pulse ingest and project/token-bounded impact marking
→ invariant validation and human-cost observation
```

The automatic candidate classification is deliberately small and reviewable. It is not organizational truth. `UNCERTAIN`, `DISPUTED`, and `REVIEW_REQUIRED` remain visible until bounded review resolves them.

## G5 mapping

| Requirement | Minimum implementation |
|---|---|
| G5-1 | `sources.relative_path`, SHA-256, document ID, line locator, `EVIDENCED_BY` |
| G5-2 | `project_id`, `context` on source and statement |
| G5-3 | five checked `statement_type` values |
| G5-4 | event/effective time plus source `PRECEDES` |
| G5-5 | `use_scope` and target-project filtering before export |
| G5-6 | `SUPERSEDES` with prior state retained |
| G5-7 | hash comparison, dependency traversal, local Pulse `IMPACTS`, `REVIEW_REQUIRED` |
| G5-8 | explicit uncertainty/disposition and `CONFLICTS_WITH` |
| G5-9 | field-level `review`/`relate` plus immutable revision records |

## Commands

Use the bundled Python runtime available to the Codex workspace.

```text
python minimum_learning_mvp.py init --db state.sqlite3
python minimum_learning_mvp.py ingest --db state.sqlite3 --root <public-main-or-public-run-zip>
python minimum_learning_mvp.py export --db state.sqlite3 --target-project ORBIT
python minimum_learning_mvp.py review --db state.sqlite3 --statement-id <id> --field statement_type --value DECISION --reason <reason> --reviewer <name>
python minimum_learning_mvp.py pulse --db state.sqlite3 --root <released-task-pulse-or-pulse-zip> --task-id TASK-01
python minimum_learning_mvp.py log-cost --db state.sqlite3 --activity 원문확인 --human-seconds 30
python minimum_learning_mvp.py validate --db state.sqlite3
python minimum_learning_mvp.py check-run-config --config RUN_CONFIGURATION.json --public-package <zip> --pulse-package <zip>
```

`check-run-config` returns `HOLD` until every common B0/Product runtime value is resolved and the configuration itself is frozen. That HOLD is required; it is not a technical-test failure.
