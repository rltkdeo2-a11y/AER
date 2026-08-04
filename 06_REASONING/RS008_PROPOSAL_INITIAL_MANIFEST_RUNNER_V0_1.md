# Reasoning Record

Reasoning ID: RS-008

Title: Proposal Initial Manifest Runner v0.1

Status: Approved

Version: 0.1.0

Created: 2026-08-04

Updated: 2026-08-04

References:

- `06_REASONING/RS007_PROPOSAL_INITIAL_WORKFLOW_COORDINATOR_V0_1.md`
- `07_DECISIONS/DEC012_ADOPT_PROPOSAL_INITIAL_WORKFLOW_COORDINATOR_V0_1.md`
- `05_EVIDENCE/EV012_TOC_ACCEPTANCE_EXECUTION_INTEGRITY_VALIDATION.md`
- `scripts/proposal-initial-workflow-v0.1/proposal-initial-manifest-runner.mjs`
- `scripts/proposal-initial-workflow-v0.1/proposal-initial-run-manifest.schema.json`

## 1. Research Question

How can the bounded proposal initial-workflow coordinator be operated from one compact input without handwritten action payloads, while preventing the convenience layer from fabricating or bypassing AER Core strategy evidence?

## 2. Observed Bottleneck

The coordinator already enforced stage order and artifact registration, but a real Case 4 traversal still required separately prepared payload JSON files. A case-specific clean replay showed that a single manifest could remove this operator burden. Directly automating the entire traversal, however, would create a more serious defect: the accepted TOC state contains a new execution-specific hash, so strategy evidence cannot be safely copied or inferred before acceptance.

The manifest layer must therefore reduce mechanical work without collapsing the semantic evidence boundary.

## 3. Bounded Runner Contract

Manifest runner v0.1.0 is a convenience and resumption layer over the adopted coordinator. It:

1. validates required source and approved-artifact paths;
2. generates action payloads inside a distinct output directory;
3. calls only `invoke-proposal-initial-workflow.ps1` for workflow transitions;
4. runs through TOC analysis and acceptance;
5. writes a strategy-evidence request containing the newly accepted TOC state path and SHA-256;
6. stops with `AWAITING_AER_CORE_STRATEGY_EVIDENCE` when no continuation is supplied;
7. rejects strategy evidence not bound to the current accepted-state hash;
8. resumes through strategy registration and selection only after the coordinator independently validates the evidence;
9. verifies completion, transition count, source-path roundtrip, AER Core registrations, acceptance receipt, system-sheet proof, and RPA Hold; and
10. refuses to overwrite a completed run or silently resume a partial pre-acceptance run.

## 4. Human and AER Core Boundary

The manifest records previously approved human inputs and selections; it does not create those approvals. The runner does not analyze an RFP, decide consortium legality, generate TOC semantics, approve workbook changes, create strategy meaning, or issue semantic evidence.

The post-acceptance stop is mandatory because the current accepted TOC hash does not exist before execution. AER Core must validate or revalidate the strategy artifact against that state and provide a proof file. The coordinator remains the authoritative registration gate after the runner's preliminary hash comparison.

## 5. State and File Safety

Every coordinator transition remains a separate state file. Generated payloads, reports, accepted artifacts, receipts, evidence requests, and final verification remain external run artifacts. A pre-existing completed state causes fail-closed termination. A partial state before acceptance is not guessed or repaired; the operator must use a fresh output root.

## 6. Interpretation

The runner converts the approved initial workflow from many mechanical invocations into a two-phase routine: deterministic orchestration through TOC acceptance, then AER Core evidence-gated continuation. This is not a general workflow engine and does not change AER Core or the coordinator state model.

## 7. Limitations

- v0.1 supports the adopted eight-transition initial workflow only.
- It does not generate semantic artifacts or human decisions.
- It does not resume arbitrary partial failures before TOC acceptance.
- It does not provide multi-user concurrency, external signatures, or distributed tamper control.
- A valid local proof establishes execution provenance and file integrity, not semantic truth.
- General operation across unrelated live RFPs remains unvalidated.
- Production Layer and PPT RPA remain on Hold.

Reasoning Status:

Approved
