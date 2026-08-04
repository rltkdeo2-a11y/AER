# Evidence Record

Evidence ID: EV-012

Title: TOC Acceptance Execution Integrity Validation

Status: Validated

Date: 2026-08-04

References:

- `scripts/proposal-toc-roundtrip-v0.3/aer-toc-roundtrip-accept.mjs`
- `scripts/proposal-toc-roundtrip-v0.3/invoke-proposal-toc-roundtrip-accept.ps1`
- `scripts/proposal-toc-roundtrip-v0.3/test-proposal-toc-roundtrip.mjs`
- `scripts/proposal-toc-roundtrip-v0.3/test-proposal-toc-roundtrip.ps1`
- `scripts/proposal-initial-workflow-v0.1/proposal-initial-workflow.mjs`
- `scripts/proposal-initial-workflow-v0.1/invoke-proposal-initial-workflow.ps1`
- `scripts/proposal-initial-workflow-v0.1/test-proposal-initial-workflow.mjs`
- `scripts/proposal-initial-workflow-v0.1/test-proposal-initial-workflow.ps1`

## Evidence Question

Can the TOC acceptance path recover the system sheets omitted at the human-facing workbook boundary and prevent the proposal coordinator from registering an accepted TOC without verifiable acceptance-engine execution evidence?

## Root Cause and Remediation Boundary

The observed Case 4 failure was an execution-integrity defect, not a new AER Core reasoning defect. The production workbook contained the five intended human-facing sheets but omitted `SYS_SNAPSHOT`, `SYS_MAPPING`, `SYS_RPA_SPEC`, and `CHANGE_REVIEW`. The acceptance engine assumed those sheets already existed, while a case-local acceptance helper could bypass the official engine. The coordinator then trusted declared output paths and a parsed verification object without proving which acceptance engine produced them.

The remediation is bounded to the TOC acceptance and registration path. It does not add a Core reasoning rule, change approved TOC semantics, release RPA, or generalize from the single case beyond the tested interface contract.

## Validated Contract

Acceptance engine v0.1.1 now:

- creates each missing required system sheet with its canonical header and table structure;
- repopulates system-sheet content from the accepted canonical state;
- verifies the newly exported workbook through the existing roundtrip analyzer;
- writes an acceptance receipt binding input workbook, baseline, human decisions, accepted workbook, accepted state, and verification report by absolute path and SHA-256;
- records required and recovered system sheets, verification summary, formula-integrity status, release recommendation, and RPA Hold; and
- does not modify the human-returned source workbook.

The proposal coordinator now rejects TOC acceptance registration unless the receipt uses the supported receipt and engine versions, matches the workflow case, proves all four system sheets, retains RPA Hold, matches the registered verification result, and verifies every bound file path and SHA-256. Reopening source or TOC scope removes the stored acceptance receipt, receipt hash, and engine version together with the downstream accepted artifacts.

## Executed Validation

The synthetic regression confirmed:

- existing system-sheet workbooks remain acceptable without unnecessary recovery;
- a workbook containing only the five human-facing sheets recovers all four required system sheets and tables;
- the recovered workbook re-imports with zero material, blocking, and structural changes;
- exact page budgets and formula integrity still pass;
- acceptance leaves RPA at `HOLD` and requires human confirmation;
- the original edited workbook remains byte-identical;
- the coordinator rejects a missing receipt;
- the coordinator rejects a receipt with a tampered output hash; and
- a valid receipt is registered with its hash and acceptance-engine version.

The real Case 4 strategy-title workbook was also accepted through engine v0.1.1. All four missing system sheets were recovered, five approved title events were applied, 78 rows re-imported with zero material, blocking, or structural changes, the exact 100-page budget passed, and RPA remained on Hold. The user workbook and generated artifacts remain external working artifacts and are not stored in this repository.

## Interpretation

The observed missing-system-sheet failure and the coordinator's acceptance-provenance bypass are remediated for the bounded TOC v0.3.2 / acceptance v0.1.1 / initial-workflow v0.1.0 path. Registration evidence now proves that the supported acceptance engine ran over the declared inputs and produced the declared outputs.

## Limitations

- SHA-256 bindings are local tamper evidence, not an external signature or multi-user security system.
- The receipt proves execution provenance and file integrity, not the semantic quality of a human-approved TOC change.
- Recovery is limited to the four system sheets defined by the current v0.3 contract.
- The regression covers the observed five-sheet boundary and existing full-system-sheet boundary; arbitrary workbook corruption remains outside scope.
- Production-layer release remains explicitly unvalidated and held.
