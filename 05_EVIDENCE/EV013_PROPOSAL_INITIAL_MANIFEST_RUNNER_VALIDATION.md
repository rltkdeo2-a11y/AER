# Evidence Record

Evidence ID: EV-013

Title: Proposal Initial Manifest Runner Validation

Status: Validated

Date: 2026-08-04

References:

- `06_REASONING/RS008_PROPOSAL_INITIAL_MANIFEST_RUNNER_V0_1.md`
- `scripts/proposal-initial-workflow-v0.1/proposal-initial-manifest-runner.mjs`
- `scripts/proposal-initial-workflow-v0.1/proposal-initial-run-manifest.schema.json`
- `scripts/proposal-initial-workflow-v0.1/test-proposal-initial-manifest-runner.mjs`
- `scripts/proposal-initial-workflow-v0.1/test-proposal-initial-manifest-runner.ps1`

## Evidence Question

Can one manifest drive the approved initial workflow without handwritten action payloads while preserving the post-acceptance AER Core strategy-evidence gate?

## Executed Validation

The repository regression uses a synthetic UTF-8 source path, a normalized v0.3 TOC state, a five-sheet human workbook, synthetic AER Core analysis and strategy artifacts, and the actual public coordinator, roundtrip analyzer, and acceptance engine.

It confirmed that:

- the manifest creates the expected source-through-acceptance state chain;
- the five-sheet workbook recovers `SYS_SNAPSHOT`, `SYS_MAPPING`, `SYS_RPA_SPEC`, and `CHANGE_REVIEW`;
- the runner stops after acceptance with `AWAITING_AER_CORE_STRATEGY_EVIDENCE`;
- no strategy-registration state exists before continuation;
- evidence bound to a different accepted-state hash is rejected before registration;
- valid AER Core evidence advances through the coordinator's independent proof validation;
- the final state reaches `COMPLETE` through eight transitions;
- the UTF-8 source path roundtrips unchanged;
- analysis and strategy remain registered as `AER_CORE`;
- the acceptance receipt and required system-sheet proof remain registered;
- RPA remains `HOLD`; and
- rerunning a completed output root is rejected rather than overwritten.

Before repository integration, a real Case 4 clean replay and a second generic-runner replay both completed with the same bounded invariants. Those user artifacts remain external and are not stored in the repository.

## Interpretation

The runner is validated as a bounded two-phase operating surface for the adopted initial workflow. It removes mechanical payload preparation without converting semantic evidence into an automatically generated field.

## Limitations

- The repository regression uses synthetic semantic content and one representative TOC contract fixture.
- The real replay evidence covers one live RFP case.
- The test validates orchestration and evidence integrity, not proposal quality.
- Arbitrary partial-run recovery, concurrency, external signatures, and general RFP compatibility remain unvalidated.
- Production Layer remains on Hold.
