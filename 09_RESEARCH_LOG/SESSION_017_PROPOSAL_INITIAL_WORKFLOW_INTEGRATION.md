# Research Session

Session ID: SESSION-017

Title: Proposal Initial Workflow Integration

Date: 2026-08-04

Status: Closed

Related Objects:

- `06_REASONING/RS007_PROPOSAL_INITIAL_WORKFLOW_COORDINATOR_V0_1.md`
- `05_EVIDENCE/EV010_PROPOSAL_INITIAL_WORKFLOW_INTEGRATION_VALIDATION.md`
- `07_DECISIONS/DEC012_ADOPT_PROPOSAL_INITIAL_WORKFLOW_COORDINATOR_V0_1.md`
- `scripts/proposal-initial-workflow-v0.1/proposal-initial-workflow.mjs`

## Objective

Connect the approved proposal TOC workbook routine to the complete initial AER proposal workflow through one bounded execution entry point.

## Baseline

- DEC-001 permits work to begin before all information is available and requires selective reanalysis.
- DEC-006 requires explicit classification and safe human gates without changing canonical reasoning.
- DEC-010 prohibits expansion into a general workflow or exception engine.
- DEC-011 adopts report-only TOC re-import and explicit acceptance while keeping RPA on Hold.

## Work Performed

1. Compared the requested end-to-end flow with approved AER authority.
2. Rejected a universal automation engine because it would exceed the adopted boundary.
3. Defined a bounded stage and transition state.
4. Implemented a single PowerShell entry point and a pure JavaScript transition engine.
5. Delegated returned-workbook analysis and acceptance to the existing approved TOC routines.
6. Added late external-information registration without automatic regeneration.
7. Added explicit human regeneration authorization and immutable state-path progression.
8. Added downstream-state invalidation when a prior stage is reopened.
9. Separated strategy-candidate registration from explicit human selection or deferral.
10. Added transition, negative-gate, external-information, acceptance, and PowerShell-entry regression tests.

## Result

The coordinator v0.1.0 connects source intake, summary confirmation, foundation input, TOC draft registration, human edit return, TOC analysis, human-confirmed acceptance, and strategy-candidate registration. RPA remains Hold in every tested state. The implementation does not automate semantic reasoning stages or store user proposal artifacts in the repository.

## Open Questions

- Whether the stage vocabulary needs refinement after the first complete real-RFP traversal.
- Whether repeated external-information updates require a more detailed impact disposition record.
- Whether future strategy-output work needs a separate machine-readable contract.

## Conclusion

The bounded coordinator is sufficient for routine initial-workflow orchestration without reopening AER Core or the proposal TOC contract. Further abstract expansion stops until actual use reveals a concrete incompatibility.
