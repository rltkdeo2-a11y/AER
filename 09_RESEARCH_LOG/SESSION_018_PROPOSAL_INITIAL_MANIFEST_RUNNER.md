# Research Session

Session ID: SESSION-018

Title: Proposal Initial Manifest Runner

Date: 2026-08-04

Status: Closed

References:

- `06_REASONING/RS008_PROPOSAL_INITIAL_MANIFEST_RUNNER_V0_1.md`
- `07_DECISIONS/DEC013_ADOPT_PROPOSAL_INITIAL_MANIFEST_RUNNER_V0_1.md`
- `05_EVIDENCE/EV013_PROPOSAL_INITIAL_MANIFEST_RUNNER_VALIDATION.md`

## Objective

Convert the successfully corrected proposal initial workflow into a routine candidate that removes handwritten transition payloads without weakening human or AER Core gates.

## Work Performed

1. Completed the corrected Case 4 coordinator path with AER Core analysis and strategy evidence, TOC acceptance receipt, five selected strategies, and RPA Hold.
2. Audited the complete artifact and transition chain.
3. Replayed Case 4 in a clean output directory from one UTF-8 manifest.
4. Identified automatic strategy-proof rebinding as an unacceptable execution-evidence bypass.
5. Redesigned the runner as a two-phase operation that stops after acceptance and requests evidence bound to the new TOC hash.
6. Validated the generic candidate on Case 4.
7. Implemented a repository regression using the actual coordinator, analyzer, and acceptance engine.

## Result

Proposal initial manifest runner v0.1.0 is adopted as a bounded convenience layer. The manifest automates mechanical payload generation through TOC acceptance. Strategy registration remains blocked until AER Core provides evidence bound to the newly accepted TOC state, and the coordinator independently validates that evidence.

## Preserved Boundaries

- Human approvals remain human inputs.
- AER Core remains responsible for material semantic judgment.
- No arbitrary partial recovery is inferred.
- No general RFP compatibility is claimed.
- No user RFP or proposal artifact is stored in the repository.
- Production Layer and PPT RPA remain on Hold.
