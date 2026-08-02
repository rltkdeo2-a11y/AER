# Decision Record

Decision ID: DEC-008

Title: Freeze the Proposal TOC Workbook Generation and Re-import Contract v0.1

Status: Approved

Version: 1.0

Decision Date: 2026-08-03

Effective Date: 2026-08-03

Decision Owner:

Human Co-Researcher

Research Domain:

Proposal TOC Workbook and PM Change Transfer

Related Research Session:

SESSION-013 Proposal TOC Workbook Contract v0.1

Related Reasoning:

RS-003 Proposal TOC Workbook Generation and Re-import Contract v0.1

Related Decisions:

- DEC-005 Tiered Runtime Selection and Production-Layer Transformation
- DEC-006 Cognitive-Load-Reduction Interaction Layer

Closure Mode:

Standard

Git Permission:

Autonomous Closure

---

## 1. Decision

Freeze `0.1.0` of the internal data structure and generation and re-import contracts used by the first proposal TOC workbook case.

The frozen authority consists of:

- `06_REASONING/RS003_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_1.md`;
- `06_REASONING/contracts/proposal-toc-v0.1/proposal-toc-contract-v0.1.json`;
- `06_REASONING/contracts/proposal-toc-v0.1/proposal-toc-state-v0.1.schema.json`;
- `06_REASONING/contracts/proposal-toc-v0.1/case1-representative-state.json`; and
- `scripts/proposal-toc-contract-v0.1/test-proposal-toc-contract.ps1`.

The workbook is the human editing surface. Stable-ID normalized state is the machine comparison authority.

---

## 2. Adopted Rules

1. Preserve RFP-fixed parent and level while allowing title edits.
2. Use routine levels 1 through 3; level 4 remains detectable but non-routine.
3. Treat the RFP page target as exact under the approved operating convention.
4. Count one A3 physical sheet as two RFP pages.
5. Require exactly one MAIN mapping per non-control atomic obligation.
6. Preserve owner edits but exclude them from LLM impact analysis.
7. Detect inserted and deleted rows through stable identity reconciliation.
8. Classify changes as LOCAL, REVIEW, or STRUCTURAL.
9. Report re-import impact without automatic regeneration.
10. Keep the RPA specification in HOLD until all gates pass and the human explicitly releases it.

---

## 3. Hold Reopening Boundary

The general Production Layer Hold in SESSION-011 is reopened only for this bounded TOC-workbook contract because:

- the user explicitly prioritized personal expert augmentation;
- an actual RFP and an independent human PM artifact were compared;
- a working prototype exposed testable structure; and
- the current instruction explicitly approves freezing the contract.

This Decision does not reopen or approve:

- PPT production;
- automatic layout selection;
- RAG or proposal-sample retrieval;
- automatic regeneration on every information update;
- generalization beyond the planned three RFP cases;
- expert replacement; or
- performance or proposal-success claims.

---

## 4. Validation Basis

The executable contract test passed the first representative state and regression checks for:

- A3 page calculation;
- exact page total;
- MAIN mapping uniqueness;
- owner-only edit exclusion;
- inserted-row detection;
- official hierarchy protection; and
- premature RPA-release rejection.

The complete external first-case workbook remains working evidence rather than a committed binary research object.

---

## 5. Version Rule

`0.1.0` remains frozen during the next two planned RFP cases.

A materially incompatible state or operation change requires a new contract version. Case-specific values do not require a version change when they remain valid under the existing schema and invariants.

Decision Status:

Approved
