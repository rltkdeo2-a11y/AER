# Evidence Record

Evidence ID: EV-009

Title: Proposal TOC Human Roundtrip Operational Validation

Status: Validated

Date: 2026-08-03

References:

- `06_REASONING/RS005_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_3.md`
- `06_REASONING/RS006_PROPOSAL_TOC_ROUNDTRIP_OPERATION_V0_3.md`
- `scripts/proposal-toc-roundtrip-v0.3/test-proposal-toc-roundtrip.ps1`
- `scripts/proposal-toc-roundtrip-v0.3/aer-toc-roundtrip-accept.mjs`

## Evidence Source

- External baseline: full Case 3 normalized state and generated PM workbook.
- External returned artifact: the first human-edited Case 3 workbook, edited with Excel 2016.
- Repository regression source: the non-sensitive representative Case 3 state and an ephemeral synthetic workbook created during the test.
- The full baseline, generated workbook, returned workbook, and derived report remain external working artifacts and are not repository contents.

The human later confirmed that the original `General status and history` leaf was intentionally split into `SimsysGlobal co. General status` and `SimsysGlobal co. history`, with five and four physical pages respectively. The human also confirmed the Korean project-background title and corrected the history title's spelling.

## Actual Human Roundtrip Observations

The returned workbook contained 180 rows against a 179-row baseline. Re-import identified five material changes:

- two title changes;
- one physical-page change;
- one A3 format change; and
- one new row with no stable identifier.

One changed title row also contained an owner value. The primary result remained `RENAMED / REVIEW`, while the owner sub-change was reported separately with no LLM impact.

Excel 2016 displayed the A3 editing surface as `TRUE/FALSE`. The user's `TRUE` value was preserved as a Boolean true value and classified as `FORMAT_CHANGED / BLOCK` because Case 3 prohibits A3.

## Page and Integrity Results

- Volume 1 main content changed from 100 to 101 pages and became `REVIEW`.
- Volume 1 appendices remained unlimited and `N/A`.
- Volume 2 remained exactly 300 pages and `PASS`.
- The formula-error scan found zero matches.
- The release recommendation remained `HOLD` because the edit contained a prohibited format, a structural new row, and an over-allocated exact budget.
- No TOC, page allocation, mapping, or RPA specification was automatically regenerated.

## Repository Regression Checks

The executable regression test creates a temporary, non-sensitive workbook and confirms:

- v0.1 authoritative A3 multiplication and exact-page completion;
- v0.2 explicit planning-target evaluation without inventing an RFP target;
- editable and official title changes remain permitted as `RENAMED`;
- physical-page changes recalculate only the affected budget;
- Boolean `TRUE` is accepted as the A3 state;
- invalid Boolean and page values are blocked;
- a volume-scoped A3 prohibition does not leak into another volume;
- owner-only changes remain separately visible with no LLM impact;
- a page-bearing new row is structural, receives a provisional candidate, and makes exact budgets indeterminate when its scope is unknown;
- changed page-budget scope is structural;
- duplicate identity prevents page-budget completion;
- deleted rows remain structural;
- an official parent change is blocked;
- a positive formula error is detected and keeps release on Hold while explanatory error-like text remains non-error;
- unsupported contract versions are rejected;
- report and input paths cannot collide; and
- human guidance uses Excel cell addresses, separates corrections from confirmations, omits internal identifiers from display text, and explains owner-only changes as no action; and
- material blocking or structural changes preserve `HOLD`.

The acceptance regression additionally confirms:

- a confirmed title becomes the new baseline without rewriting the original workbook;
- an approved split receives a canonical machine identifier without human entry;
- the new leaf inherits the source parent, volume, page budget, and requirement placement;
- the original nine pages remain exactly five plus four;
- a secondary requirement mapping is created for the new leaf;
- workbook formulas and `PAGE_BUDGETS`, `CHANGE_REVIEW`, `SYS_MAPPING`, `SYS_SNAPSHOT`, and `SYS_RPA_SPEC` remain synchronized;
- the accepted workbook returns zero material, blocking, or structural changes against the accepted state; and
- RPA release remains unapproved.

## Interpretation

The combined actual and expanded synthetic evidence supports runtime implementation 0.3.2 for repeatable v0.3 re-import and acceptance routine 0.1.0 for explicit human-confirmed state advancement. The accepted Case 3 pair contains 180 workbook rows and 180 baseline rows, produces zero material changes, and restores the exact page budgets to 100 and 300 pages. The acceptance layer does not require a v0.4 contract because it advances an approved instance state without adding a new RFP semantic structure.

## Limitations

- The actual human edit did not independently exercise every possible change type; contract-specific and failure paths are reinforced by synthetic XLSX regression.
- The evidence does not establish tamper resistance, multi-user reliability, universal Excel-version compatibility, or RPA readiness.
- The returned workbook contains human-entered content and therefore remains outside the repository.
- Acceptance routine 0.1.0 is limited to contract v0.3.0 and the observed confirmed-change and one-source/two-leaf split patterns.
