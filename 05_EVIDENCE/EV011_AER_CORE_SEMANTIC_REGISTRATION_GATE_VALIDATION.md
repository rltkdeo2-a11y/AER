# Evidence Record

Evidence ID: EV-011

Title: AER Core Semantic Registration Gate Validation

Status: Validated

Date: 2026-08-04

References:

- `06_REASONING/RS007_PROPOSAL_INITIAL_WORKFLOW_COORDINATOR_V0_1.md`
- `07_DECISIONS/DEC012_ADOPT_PROPOSAL_INITIAL_WORKFLOW_COORDINATOR_V0_1.md`
- `scripts/proposal-initial-workflow-v0.1/proposal-initial-workflow.mjs`
- `scripts/proposal-initial-workflow-v0.1/test-proposal-initial-workflow.mjs`
- `scripts/proposal-initial-workflow-v0.1/test-proposal-initial-workflow.ps1`

## Evidence Question

Can the proposal initial-workflow coordinator prevent RFP analysis and strategy artifacts from being registered without compact, verifiable evidence that AER Core was selected and completed?

## Remediation Boundary

The change corrects an execution-integrity defect at the coordinator registration boundary. It does not add a new AER Core reasoning rule, make semantic judgment deterministic, store chain-of-thought, or release the Production Layer.

## Validated Contract

RFP analysis and strategy registration now fail closed unless a semantic-evidence JSON file:

- uses contract version `0.1.0`;
- identifies the expected artifact type and matching workflow case;
- records AER Core as the selected runtime with authority digest and repository HEAD;
- affirms problem definition, fact-assumption-unknown separation, reasoning links, the bottleneck six fields, and a solution hypothesis;
- records passing direct validation and closure outcomes plus opposing review, whole-process impact, and global consistency;
- binds every canonical source and registered output by path and SHA-256; and
- for strategy, binds the approved RFP-analysis proof and current accepted TOC state by SHA-256 and records foundation-input status.

The resulting workflow state preserves the semantic-evidence path and hash plus runtime, authority, repository, and closure metadata. Reopening source, TOC, or strategy scope invalidates the corresponding downstream proof references.

## Executed Validation

The regression confirmed:

- valid analysis evidence advances only to summary confirmation;
- valid strategy evidence registers a candidate while retaining the human strategy gate;
- missing evidence is rejected for analysis and strategy;
- missing AER Core runtime is rejected;
- missing closure outcome is rejected;
- output tampering after proof creation is rejected by SHA-256 mismatch;
- a strategy bound to a different RFP-analysis proof is rejected;
- direct engine invocation enforces the same proof contract as the PowerShell entry point;
- the PowerShell entry point correctly maps non-Start action names and registers a valid Core-backed analysis; and
- RPA remains `HOLD`.

## Interpretation

The observed registration bypass is remediated for the bounded v0.1 coordinator. Human confirmation remains a separate judgment gate and no longer substitutes for proof of semantic execution.

## Limitations

- The proof establishes execution provenance and artifact integrity, not the truth or quality of the semantic conclusion.
- Authority digest and repository HEAD are recorded and required but are not independently resolved against a remote authority service.
- The proof file is locally tamper-evident only through the hash stored in later workflow state; no external signature or multi-user tamper-control service is introduced.
- Formal B-type independence remains governed by DEC-005 and is recorded as runtime-selection disposition rather than inferred by the coordinator.
- No user RFP, workbook, or proposal content is stored in this repository evidence record.
