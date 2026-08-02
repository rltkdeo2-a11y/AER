# Decision Record

Decision ID: DEC-010

Title: Adopt Proposal TOC Workbook Contract v0.3

Status: Approved

Decision Date: 2026-08-03

References:

- `06_REASONING/RS004_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_2.md`
- `06_REASONING/RS005_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_3.md`
- `05_EVIDENCE/EV008_PROPOSAL_TOC_CONTRACT_CASE3_VALIDATION.md`
- `09_RESEARCH_LOG/SESSION_015_PROPOSAL_TOC_WORKBOOK_CASE3_VALIDATION.md`

## Context

Case 3 uses separate RFP and task-specification documents, two exact page budgets, one unlimited appendix scope, and a consortium rule delegated to a missing bid notice. Contract v0.2 cannot preserve those distinctions without semantic loss.

## Decision

Adopt contract v0.3 for subsequent proposal TOC workbook cases.

Version 0.3:

1. preserves v0.1 and v0.2 as frozen case contracts;
2. adds multiple independently evaluated page budgets;
3. adds explicit source relationships and domain-specific authority;
4. preserves missing delegated sources as unresolved rather than inferred;
5. adds scoped content and page-format policies;
6. calculates budget totals from leaf rows only;
7. permits draft TOC generation while the consortium gate remains unresolved; and
8. keeps RPA release under explicit human command.

## Case 3 Application

- Volume 1 main content is allocated to exactly 100 pages.
- Volume 1 appendices and evidence remain unlimited.
- Volume 2 is allocated to exactly 300 pages.
- The task specification controls technical requirement detail.
- The missing bid notice prevents consortium confirmation.
- A3 selection is blocked because the RFP allows only A4 portrait or landscape.
- Volume 2 anonymity remains a release review.

## Consequences

Positive:

- Split-document RFPs can be represented without flattening authority.
- Page completion can be evaluated per volume and scope.
- Missing external authority blocks only the affected gate.
- Workbook re-import retains the minimum data needed for later RPA preparation.

Negative:

- Generation requires explicit source-domain analysis.
- More than one page-control object must be maintained.
- Consortium and anonymity checks remain incomplete until source and human review are supplied.

## Non-Decisions

- No PPT production or RPA execution is approved.
- No automated bid-notice retrieval is approved.
- No automated company-identity scan is validated.
- No general exception engine or universal RFP model is adopted.
