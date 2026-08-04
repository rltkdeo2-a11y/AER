# Research Session

Session ID: SESSION-016

Title: Proposal TOC Human Roundtrip Operational Validation

Date: 2026-08-03

Status: Closed

Related Objects:

- `06_REASONING/RS006_PROPOSAL_TOC_ROUNDTRIP_OPERATION_V0_3.md`
- `05_EVIDENCE/EV009_PROPOSAL_TOC_HUMAN_ROUNDTRIP_VALIDATION.md`
- `07_DECISIONS/DEC011_ADOPT_PROPOSAL_TOC_ROUNDTRIP_OPERATION_V0_3.md`
- `scripts/proposal-toc-roundtrip-v0.3/aer-toc-roundtrip-engine.mjs`
- `scripts/proposal-toc-roundtrip-v0.3/aer-toc-roundtrip-accept.mjs`
- `scripts/proposal-toc-roundtrip-v0.3/test-proposal-toc-roundtrip.ps1`

## Objective

Return the Case 3 human-test workbook through the v0.3 re-import path, determine whether ordinary PM edits are observable without a manual change log, and implement the smallest repeatable operation if the actual roundtrip succeeds.

## Baseline

- Contract v0.3 is approved and remains the current version.
- Normalized JSON is canonical state and XLSX is the PM editing surface.
- Stable `node_id` is the identity key.
- Owner-only changes have no LLM impact.
- Re-import is report-only and regeneration requires an explicit human command.
- Case 3 prohibits A3 and has independent 100-page, unlimited, and 300-page scopes.

## Work Performed

1. Accepted the returned human-edited Case 3 workbook as an actual operational test.
2. Interpreted Excel 2016 `TRUE/FALSE` as the Boolean representation of the A3 field.
3. Compared 180 current rows with the 179-row baseline.
4. Classified title, page, format, owner, and new-row changes.
5. Recalculated all three page-budget scopes independently.
6. Scanned the imported workbook for formula errors.
7. Confirmed that no downstream artifact was automatically regenerated.
8. Added a reusable report-only engine and an ephemeral synthetic XLSX regression test.
9. Reopened the broad runtime conclusion after an independent implementation review.
10. Corrected report/input path collision, v0.1 A3 counting, v0.2 planning-target evaluation, volume-scoped format policy, system-scope tracking, ambiguous page budgets, invalid input handling, and formula-error release gating.
11. Expanded regression across all three contract versions and positive failure paths.
12. Added a human-guidance layer that maps detected changes to exact Excel cells and separates required corrections, confirmations, and no-action notes.
13. Received explicit human confirmation of the project-background rename and of a one-source/two-leaf company-status split.
14. Implemented acceptance routine 0.1.0 to create a new normalized state and synchronized workbook copy without modifying the returned workbook or prior baseline.
15. Assigned the new split leaf a machine identity and inherited parent, volume, budget, requirement, and secondary mapping internally.
16. Recalculated workbook formulas and synchronized `CHANGE_REVIEW`, `SYS_MAPPING`, `SYS_SNAPSHOT`, and `SYS_RPA_SPEC`.
17. Re-imported the accepted workbook against the accepted state and visually checked all eleven workbook sheets.

## Results

- Five material changes were detected: two renames, one page change, one format change, and one new row.
- The A3 `TRUE` value remained a Boolean and produced `FORMAT_CHANGED / BLOCK`.
- The owner field was reported separately with no LLM impact even when the same row had a title change.
- Volume 1 main content became 101 of 100 pages and returned to `REVIEW`.
- Volume 2 remained 300 of 300 pages and `PASS`.
- Formula-integrity scanning returned no error matches.
- Release remained `HOLD`.
- Synthetic regression reinforced official-title and fixed-structure behavior without archiving the user's workbook.
- v0.1 A3 counting returned exactly 80 pages.
- v0.2 planning-target allocation reached Pass without inventing an RFP target.
- Scoped A3 policy, page-bearing new rows, budget-scope changes, duplicate IDs, invalid inputs, deletion, positive formula errors, non-formula error-like text, unsupported versions, and output-path collision were all handled as designed.
- Runtime implementation 0.3.2 reproduced the original Case 3 human result: five material changes, Volume 1 at 101 of 100, Volume 2 at 300 of 300, and release Hold.
- The actual return produced three required cell-addressed actions, two title confirmations, and one owner no-action note without exposing internal identifiers in the display text.
- Human confirmation established that the company-status leaf was intentionally divided into five-page general status and four-page history leaves, preserving the original nine-page allocation.
- Acceptance produced a 180-row workbook and 180-row normalized baseline with zero material, blocking, or structural changes.
- The accepted page budgets were 100 of 100 and 300 of 300, with the unlimited appendix remaining `N/A`.
- Formula integrity returned `PASS`; change review classified the accepted rows as `UNCHANGED / IGNORE`.
- The accepted workbook's system snapshot, secondary requirement mapping, and draft RPA queue include the new history leaf while RPA release remains `HOLD`.

## Conclusion

The first actual human roundtrip and the remediated cross-version regression validate runtime implementation 0.3.2 for the v0.3 re-import operation. The confirmed return and synchronized zero-change re-import validate acceptance routine 0.1.0 for the observed title confirmation and one-source/two-leaf split. Excel 2016 Boolean display is a compatible editing-surface variation, not a contract incompatibility. Neither the remediation, human-guidance, nor explicit acceptance layer reopens the semantic contract version.

## Open Questions

- Whether later observed workbooks require a different Boolean false encoding remains untested.
- Generalization of stable identity assignment beyond explicit contract-v0.3 confirmation and the observed split pattern remains unvalidated.
- Tamper resistance and distributed-user collection remain deferred distribution concerns.
