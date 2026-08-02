# Evidence Record

Evidence ID: EV-008

Title: Proposal TOC Contract Case 3 Validation

Status: Validated

Date: 2026-08-03

References:

- `06_REASONING/RS005_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_3.md`
- `06_REASONING/contracts/proposal-toc-v0.3/case3-representative-state.json`
- `scripts/proposal-toc-contract-v0.3/test-proposal-toc-contract.ps1`

## Evidence Source

- External RFP: Incheon Airport Data Platform Construction Project, 60 PDF pages.
- External task specification: Incheon Airport Data Platform Construction Project, 109 PDF pages.
- The referenced bid notice was not supplied.
- Generated full working artifacts remain external to the repository; the repository fixture is a representative slice.

## Direct Observations

1. Volume 1 chapters I-IV have a 100-page A4 maximum; chapter V appendices and evidence are unlimited.
2. Volume 2 chapters I-VI have a 300-page A4 maximum.
3. Applicable cover, TOC, divider, acceptance-table, and evidence pages are excluded as stated by the RFP.
4. One printed side counts as one page.
5. A4 portrait is the default and A4 landscape is allowed when unavoidable; no A3 rule was found.
6. Volume 2 must not identify the proposing company, affiliate, CI, photograph, or personnel; the evaluation rule applies a seven-point penalty.
7. The RFP delegates detailed technical requirements to the task specification.
8. The task specification contains 110 requirement groups: SFR 18, ECR 17, PER 3, SIR 5, DAR 10, QUR 9, TER 5, SER 11, COR 9, PMR 14, and PSR 9.
9. Consortium policy is delegated to the bid notice, which was not supplied.

## Generated Workbook Observation

- official fixed nodes: 45
- total TOC rows: 179
- L3 leaf rows: 134
- atomic review rows: 297
- MAIN mapping rows: 297
- initial exact allocation: Volume 1 = 100, Volume 2 = 300
- unlimited appendix target: null
- initial change rows: 0
- consortium gate: Source Missing
- RPA release: Hold
- spreadsheet formula-error scan: 0 matches

## Re-import and Contract Checks

Executable checks confirmed:

- one MAIN mapping per represented atomic obligation;
- all 110 requirement groups represented;
- independent exact and unlimited page-budget behavior;
- A3 edit classification as `FORMAT_CHANGED / BLOCK`;
- new row classification as `NEW / STRUCTURAL`;
- owner-only edit classification as `UNCHANGED / LOCAL`;
- domain-specific RFP, task-specification, and bid-notice authority;
- explicit preservation of the missing bid notice;
- Volume 2 anonymity policy; and
- imported workbook sheet and formula integrity.

## Interpretation

Case 3 supports a versioned extension for source delegation, domain authority, and multiple page budgets. It does not support a general exception engine.

## Limitations

- The L3 breakdown and initial page distribution are LLM drafts awaiting PM review.
- No human-edited Case 3 workbook was available for comparison.
- The bid notice must be supplied before consortium compliance can be confirmed.
- Automated detection of Volume 2 identity leakage was not executed.
- No claim is made about proposal quality, win probability, productivity, or PPT production readiness.
