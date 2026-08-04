# Decision Record

Decision ID: DEC-012

Title: Adopt Proposal Initial Workflow Coordinator v0.1

Status: Approved

Decision Date: 2026-08-04

References:

- `07_DECISIONS/DEC001_ADOPT_PROPOSAL_STAGE_REASONING_MODEL.md`
- `07_DECISIONS/DEC006_ADOPT_COGNITIVE_LOAD_REDUCTION_INTERACTION_LAYER.md`
- `07_DECISIONS/DEC011_ADOPT_PROPOSAL_TOC_ROUNDTRIP_OPERATION_V0_3.md`
- `06_REASONING/RS007_PROPOSAL_INITIAL_WORKFLOW_COORDINATOR_V0_1.md`
- `05_EVIDENCE/EV010_PROPOSAL_INITIAL_WORKFLOW_INTEGRATION_VALIDATION.md`
- `09_RESEARCH_LOG/SESSION_017_PROPOSAL_INITIAL_WORKFLOW_INTEGRATION.md`

## Context

The proposal-stage reasoning model, TOC workbook contract, and human roundtrip operation were approved independently. Routine use still required a bounded entry point that preserves the order and human gates between source intake, summary confirmation, foundation input, TOC generation, returned-workbook analysis, acceptance, and strategy-candidate generation.

## Decision

Adopt proposal initial workflow coordinator v0.1.0 as the single bounded entry point for maintaining this stage and artifact state.

The coordinator:

1. registers source, reasoning-output, workbook, report, accepted-state, and strategy artifact paths;
2. requires explicit summary confirmation before foundation input and TOC registration;
3. routes returned workbooks to the adopted TOC analyzer;
4. routes confirmed changes to the adopted TOC acceptance routine;
5. requires a zero-change accepted verification before strategy-candidate generation;
6. registers external information without automatic regeneration;
7. requires and records an explicit human command before reopening an affected stage;
8. invalidates affected downstream approvals and artifact references when a prior stage is reopened;
9. requires explicit human strategy selection or deferral before completion;
10. writes each transition to a distinct state artifact; and
11. keeps RPA release on Hold.

This decision does not create a general workflow engine and does not change AER Core, the proposal TOC contract, AER v1.0, or AETF v0.1.2.

## Consequences

Positive:

- the approved TOC routine has one repeatable entry surface;
- stage-skipping and silent in-place state replacement are prevented;
- external information can enter at any stage without triggering automatic churn;
- existing TOC analyzer and acceptance behavior are reused rather than duplicated.

Negative:

- semantic artifacts must still be created by AER Core and confirmed by a human;
- every transition creates another external JSON state file;
- the first complete real-RFP traversal remains to be observed.

## Non-Decisions

- No automatic RFP interpretation, TOC generation, strategy selection, or content regeneration is adopted.
- No PPT production or RPA execution is approved.
- No multi-user state service, tamper control, or universal exception model is adopted.
- No repository storage of user proposal materials is authorized.
