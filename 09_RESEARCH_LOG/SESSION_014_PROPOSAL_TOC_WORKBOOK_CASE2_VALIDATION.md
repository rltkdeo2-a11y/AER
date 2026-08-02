# Research Session

Session ID: SESSION-014

Title: Proposal TOC Workbook Case 2 Validation

Date: 2026-08-03

Status: Closed

Related Objects:

- `06_REASONING/RS004_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_2.md`
- `05_EVIDENCE/EV007_PROPOSAL_TOC_CONTRACT_CASE2_VALIDATION.md`
- `07_DECISIONS/DEC009_ADOPT_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_2.md`
- `06_REASONING/contracts/proposal-toc-v0.2/proposal-toc-contract-v0.2.json`
- `scripts/proposal-toc-contract-v0.2/test-proposal-toc-contract.ps1`

## Objective

Apply the frozen Case 1 generation and re-import contract to the second RFP, produce the PM workbook, and version the contract only if the new case cannot be represented faithfully.

## Baseline

- v0.1 canonical state is normalized JSON.
- XLSX is the PM editing surface.
- Stable node identity and explicit RPA release are required.
- v0.1 assumes exact target pages and A3 multiplier two.

## Work Performed

1. Extracted and visually checked the 40-page RFP.
2. Identified the official TOC, requirement groups, writing instructions, evaluation criteria, consortium restriction, and page-format rule.
3. Compared Case 2 with v0.1 invariants.
4. Generated a Case 2 normalized state and PM workbook.
5. Detected and corrected two implementation defects during visual QA:
   - duplicate Roman numeral capture selected a section heading instead of the official chapter IV node;
   - baseline hierarchy fields initially caused unchanged level-2 rows to appear renamed.
6. Re-generated and visually verified the corrected workbook.
7. Executed normalized-state, re-import classification, workbook-sheet, and formula-error checks.
8. Recorded the versioned contract extension as v0.2.

## Results

- 22 official fixed nodes preserved.
- 65 total TOC rows generated.
- 43 L3 requirement rows generated.
- 43 atomic obligations and 43 MAIN mappings generated.
- 0 initial change rows after correction.
- 0 spreadsheet formula-error matches.
- RFP page target remains null.
- A3 multiplier remains null.
- allocation and RPA release remain Hold.

## Conclusion

Case 2 cannot be represented faithfully by v0.1 because the RFP omits both the total-page target and the A3 count multiplier. Version 0.2 is the minimum validated extension. All prior limitations remain in force.

## Open Question

Whether Case 3 requires additional source-bundle or cross-document authority rules remains unresolved until that case is executed.
