# Evidence Record

Evidence ID: EV-007

Title: Proposal TOC Contract Case 2 Validation

Status: Validated

Date: 2026-08-03

References:

- `06_REASONING/RS004_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_2.md`
- `06_REASONING/contracts/proposal-toc-v0.2/case2-representative-state.json`
- `scripts/proposal-toc-contract-v0.2/test-proposal-toc-contract.ps1`

## Evidence Source

- External RFP: Financial Supervisory Service AX Strategy Consulting, 40 PDF pages.
- Generated working artifacts remain external to the repository.
- The repository fixture is a representative slice, not a copy of the full RFP-derived data set.

## Direct Observations

1. The RFP explicitly prohibits joint contracting.
2. The official proposed TOC contains 6 level-1 and 16 level-2 nodes.
3. No total proposal-page limit was found.
4. A4 portrait is the default; A4 landscape or other paper is allowed when unavoidable.
5. No A3-to-page-count multiplier was found.
6. CSR-004 appears in the requirement details, detailed writing guide, and evaluation criteria but not in the official TOC.
7. The detailed writing guide conflicts with the official TOC in chapter label and numbering.

## Generated Workbook Observation

- official fixed nodes: 22
- total TOC rows: 65
- L3 leaf rows: 43
- atomic requirement rows: 43
- MAIN mapping rows: 43
- initial change rows: 0
- initial page allocation: blank
- allocation status: Hold
- RPA release: Hold
- spreadsheet formula-error scan: 0 matches

## Re-import and Contract Checks

The executable checks confirmed:

- one MAIN mapping per represented atomic obligation;
- CSR-004 placement below `TOC-III-3`;
- A3 edit classification as `FORMAT_CHANGED / REVIEW`;
- new row classification as `NEW / STRUCTURAL`;
- owner-only edit classification as `UNCHANGED / LOCAL`;
- preservation of all fixed parent and level values;
- rejection of allocation completion without a planning target; and
- preservation of the exact-page mode required for Case 1.

## Interpretation

The Case 2 evidence falsifies the assumption that every RFP supplies an exact or conventionally exact total page target. It supports a versioned extension, not a rewrite of Case 1 evidence.

## Limitations

- The generated L3 breakdown is an LLM draft awaiting PM review.
- No human-edited Case 2 workbook was available for comparison.
- No claim is made about proposal quality, win probability, or productivity.
- A3 counting remains unresolved for this RFP and is intentionally not inferred.
