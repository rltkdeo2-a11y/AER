# Research Session

Session ID: SESSION-015

Title: Proposal TOC Workbook Case 3 Validation

Date: 2026-08-03

Status: Closed

Related Objects:

- `06_REASONING/RS005_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_3.md`
- `05_EVIDENCE/EV008_PROPOSAL_TOC_CONTRACT_CASE3_VALIDATION.md`
- `07_DECISIONS/DEC010_ADOPT_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_3.md`
- `06_REASONING/contracts/proposal-toc-v0.3/proposal-toc-contract-v0.3.json`
- `scripts/proposal-toc-contract-v0.3/test-proposal-toc-contract.ps1`

## Objective

Apply contract v0.2 to the split RFP and task-specification case, generate the PM workbook, and version the contract only if the new case cannot be represented faithfully.

## Baseline

- Normalized JSON is canonical state and XLSX is the PM editing surface.
- Official parent and level are fixed while titles may change.
- One MAIN mapping is required per proposal-body obligation.
- External information may be accepted later, but regeneration requires an explicit human command.
- RPA release remains explicit and human-controlled.

## Work Performed

1. Extracted and visually checked the 60-page RFP and 109-page task specification.
2. Identified official TOC, page scopes, exclusions, evaluation controls, format restrictions, and Volume 2 anonymity rule.
3. Confirmed 110 task-specification requirement groups across eleven categories.
4. Identified RFP delegation to the task specification and missing bid notice.
5. Compared the case with v0.2 and limited v0.3 to page budgets, source authority, and content policies.
6. Generated a normalized state and ten-sheet PM workbook.
7. Corrected extraction and budget-calculation implementation defects during QA.
8. Re-imported the workbook and executed state, mapping, change-classification, page-budget, sheet, formula, and visual checks.

## Results

- 45 official fixed nodes preserved.
- 179 total TOC rows and 134 leaf rows generated.
- 110 requirement groups represented.
- 297 atomic obligations and 297 MAIN mappings generated.
- Volume 1 exact allocation passed at 100 pages.
- Volume 1 appendix scope remained unlimited.
- Volume 2 exact allocation passed at 300 pages.
- 0 initial change rows.
- 0 spreadsheet formula-error matches.
- consortium remained Source Missing and RPA release remained Hold.

## Conclusion

Case 3 cannot be represented faithfully by v0.2. Version 0.3 is the minimum validated extension and does not introduce a general exception system.

## Open Question

Whether a fourth materially different case requires any extension remains intentionally untested; further generalization should occur only from observed cases.
