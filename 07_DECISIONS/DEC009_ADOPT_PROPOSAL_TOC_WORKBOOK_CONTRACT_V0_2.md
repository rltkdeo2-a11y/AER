# Decision Record

Decision ID: DEC-009

Title: Adopt Proposal TOC Workbook Contract v0.2

Status: Approved

Decision Date: 2026-08-03

References:

- `06_REASONING/RS003_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_1.md`
- `06_REASONING/RS004_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_2.md`
- `05_EVIDENCE/EV007_PROPOSAL_TOC_CONTRACT_CASE2_VALIDATION.md`
- `09_RESEARCH_LOG/SESSION_014_PROPOSAL_TOC_WORKBOOK_CASE2_VALIDATION.md`

## Context

Contract v0.1 was intentionally frozen for Case 1 and requires an exact page target plus an A3 multiplier of two. Case 2 supplies neither rule. Treating either as implicit would convert an unsupported assumption into an official RFP constraint.

## Decision

Adopt contract v0.2 for subsequent proposal TOC workbook cases.

Version 0.2:

1. preserves v0.1 as the frozen Case 1 contract;
2. adds `RFP_UNSPECIFIED` alongside `RFP_EXACT`;
3. separates official RFP targets from later planning targets;
4. permits a null A3 multiplier;
5. permits TOC generation before page allocation is resolved;
6. keeps page allocation and RPA release in Hold until their gates are satisfied; and
7. records source conflicts while preserving the authoritative official TOC hierarchy.

## Case 2 Application

- Proposal mode is `SOLO` because the RFP prohibits joint contracting.
- No official total-page target is created.
- No A3 multiplier is created.
- CSR-004 is placed below the official AX roadmap node as L3 detail.
- The official chapter III and VI labels remain fixed despite conflicting detailed-guide text.

## Consequences

Positive:

- Case 2 is representable without semantic loss.
- An LLM cannot silently turn a planning choice into an RFP fact.
- A3 edits remain detectable without inventing a count rule.
- The workbook can support early PM work even when page planning is not yet available.

Negative:

- A Case 2 workbook cannot report page allocation complete at generation time.
- A PM or explicit LLM draft decision is needed before page balancing.
- Case 3 may still require another versioned extension.

## Non-Decisions

- No PPT production or RPA execution is approved.
- No universal RFP page taxonomy is claimed.
- No automated resolution of source conflicts is approved.
- No result is generalized beyond the observed cases.
