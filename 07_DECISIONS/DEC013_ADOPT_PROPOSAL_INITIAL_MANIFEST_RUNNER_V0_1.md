# Decision Record

Decision ID: DEC-013

Title: Adopt Proposal Initial Manifest Runner v0.1

Status: Approved

Decision Date: 2026-08-04

References:

- `06_REASONING/RS007_PROPOSAL_INITIAL_WORKFLOW_COORDINATOR_V0_1.md`
- `06_REASONING/RS008_PROPOSAL_INITIAL_MANIFEST_RUNNER_V0_1.md`
- `07_DECISIONS/DEC012_ADOPT_PROPOSAL_INITIAL_WORKFLOW_COORDINATOR_V0_1.md`
- `05_EVIDENCE/EV013_PROPOSAL_INITIAL_MANIFEST_RUNNER_VALIDATION.md`

## Context

The bounded coordinator and TOC acceptance gate completed a real Case 4 traversal, but routine operation still required separate action payloads. A clean replay demonstrated that one UTF-8 manifest can remove this mechanical burden. The replay also confirmed that strategy evidence must be created after TOC acceptance because it must bind the newly accepted-state hash.

## Decision

Adopt proposal initial manifest runner v0.1.0 as a bounded convenience layer over the existing coordinator.

The runner may generate payloads and invoke the adopted public coordinator entry point through TOC acceptance. It must then stop and request AER Core strategy evidence bound to the current accepted TOC state. It may resume only when that binding is present, after which the coordinator performs its full semantic-evidence validation.

The runner must preserve separate state files, source-path text, acceptance receipts, human gates, selected strategy IDs, and RPA Hold. It must reject completed-output overwrite, unsupported manifests, missing artifacts, partial pre-acceptance state, and mismatched strategy evidence.

## Consequences

Positive:

- one compact manifest replaces handwritten action payloads;
- the real post-acceptance hash dependency becomes explicit;
- convenience automation cannot silently substitute for AER Core strategy evidence;
- clean output directories produce inspectable state and artifact chains; and
- Korean source paths are preserved through the validated path.

Negative:

- the workflow remains intentionally two-phase;
- AER Core and human judgment are still required between phases;
- arbitrary partial-run recovery is not provided; and
- the bounded runner is not evidence of general RFP compatibility.

## Non-Decisions

- No general workflow engine is adopted.
- No automatic RFP analysis, TOC semantics, strategy generation, or human approval is authorized.
- No external signing, multi-user service, or distributed tamper control is introduced.
- No AER, AETF, TOC-contract, or coordinator version is changed.
- Production Layer and PPT RPA remain on Hold.
