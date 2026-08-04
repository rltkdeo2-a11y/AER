# Decision Record

Decision ID: DEC-011

Title: Adopt Proposal TOC Human Roundtrip Operation v0.3

Status: Approved

Decision Date: 2026-08-03

References:

- `06_REASONING/RS005_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_3.md`
- `06_REASONING/RS006_PROPOSAL_TOC_ROUNDTRIP_OPERATION_V0_3.md`
- `05_EVIDENCE/EV009_PROPOSAL_TOC_HUMAN_ROUNDTRIP_VALIDATION.md`
- `09_RESEARCH_LOG/SESSION_016_PROPOSAL_TOC_HUMAN_ROUNDTRIP_VALIDATION.md`

## Context

Contract v0.3 defined stable identity, editable fields, change classes, page-budget evaluation, and report-only re-import. Its Case 3 evidence did not include a returned human-edited workbook. The first actual return was edited in Excel 2016, where the A3 surface appeared as `TRUE/FALSE` rather than a graphical checkbox. A post-implementation review found runtime defects in path collision safety, cross-version page evaluation, ambiguous rows, scoped format policy, and failure-path coverage. Those defects were corrected and revalidated before closure.

## Decision

Adopt the v0.3 human roundtrip operation as the routine re-import path for proposal TOC workbooks.

The operation:

1. accepts a compatible normalized baseline and returned `PM_WORKSPACE` workbook;
2. rejects unsupported contract versions, malformed canonical identity, invalid Boolean or page values, and report/input path collisions;
3. treats a graphical checkbox and `TRUE/FALSE` as equivalent Boolean editing surfaces;
4. detects identity, structure, budget scope, format, page, requirement, title, and local-field changes;
5. applies the v0.1 authoritative A3 multiplier, the v0.2 explicit planning target, and v0.3 independent page budgets and scoped format policy;
6. prevents a page budget from passing when identity or page scope is indeterminate;
7. excludes owner-field changes from LLM impact while keeping them observable;
8. makes spreadsheet formula errors preserve Hold;
9. produces a report and release recommendation only; and
10. emits a human-facing guide using sheet names, Excel cell addresses, concrete values, plain-language reasons, and separate correction, confirmation, and no-action groups; and
11. permits a separate explicit acceptance operation to create a new normalized state and synchronized workbook copy after human confirmation;
12. keeps the returned workbook and prior baseline unchanged during acceptance; and
13. requires a separate explicit command before content regeneration or RPA release.

No contract version change is made. Version 0.3.0 remains the current proposal TOC contract; runtime implementation 0.3.2 is the corrected analyzer with the human-guidance layer, and acceptance routine 0.1.0 is the explicit state-advancement operation.

## Consequences

Positive:

- PMs do not need to maintain a separate manual change log.
- Excel 2016 Boolean presentation does not break A3 detection.
- Local owner entry can coexist with a material row edit without being mistaken for LLM input.
- Page-budget drift and release blockers are re-evaluated on return.
- The same operation can normalize and evaluate the observed v0.1, v0.2, and v0.3 page semantics for re-import analysis.
- Input workbook and baseline paths are protected from report overwrite.
- PM instructions no longer expose or require direct editing of internal identifiers.
- Confirmed human splits can be assigned stable identity and inherited machine scope without asking the PM to edit system columns.
- The accepted workbook, accepted normalized state, mappings, page formulas, change review, and draft RPA queue remain mutually consistent.

Negative:

- The routine depends on the contract headers and stable identifiers.
- Unknown new rows require human review before stable identity and mapping can be assigned.
- The current executable uses the Codex bundled spreadsheet dependency runtime.
- A report still requires human interpretation and confirmation.
- Acceptance currently supports contract v0.3.0 and the implemented confirmation and split decision types only.

## Non-Decisions

- No workbook tamper-control mechanism is adopted.
- No user workbook or human-entered content is archived in the repository.
- No automatic regeneration, PPT production, or RPA execution is approved.
- No acceptance is permitted without an explicit human decision input.
- No universal workbook importer or general exception engine is adopted.
- No claim is made about proposal quality, productivity, or win probability.
