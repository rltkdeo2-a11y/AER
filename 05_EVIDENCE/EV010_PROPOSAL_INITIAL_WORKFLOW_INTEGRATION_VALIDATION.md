# Evidence Record

Evidence ID: EV-010

Title: Proposal Initial Workflow Integration Validation

Status: Validated

Date: 2026-08-04

References:

- `06_REASONING/RS007_PROPOSAL_INITIAL_WORKFLOW_COORDINATOR_V0_1.md`
- `scripts/proposal-initial-workflow-v0.1/test-proposal-initial-workflow.ps1`
- `scripts/proposal-toc-roundtrip-v0.3/test-proposal-toc-roundtrip.ps1`

## Evidence Source

- Approved AER proposal-stage reasoning, interaction, TOC contract, and TOC roundtrip records.
- Executable non-sensitive state-transition regression.
- Existing TOC v0.3.2 analyzer and acceptance v0.1.0 regression.

No user RFP, workbook, or human-entered proposal content is stored in the repository.

## Validated Behaviors

The regression confirms that:

- a new workflow begins at source intake and keeps RPA on Hold;
- analysis registration advances only to human summary confirmation;
- a TOC draft cannot be registered before summary and foundation gates;
- summary rejection cannot be represented as approval;
- a consortium input requires at least two participants;
- an unresolved source dependency may remain explicit, while a known RFP conflict blocks TOC progression;
- a registered TOC draft advances to human editing;
- later external information preserves the current stage and creates an unauthorized pending impact;
- returned-workbook analysis advances to a human decision state rather than accepting changes;
- acceptance requires zero material, blocking, and structural changes plus formula-integrity Pass;
- successful acceptance advances to strategy-candidate generation while retaining RPA Hold;
- strategy registration waits for explicit human selection or deferral before completing the bounded workflow;
- regeneration requires an explicit human command and records its reason;
- regeneration invalidates affected downstream approval gates and artifact references; and
- the PowerShell single entry point creates a valid initial state, rejects payload/output collision, verifies registered artifact existence, and cleans temporary test artifacts.

The existing TOC regression separately continues to validate Excel 2016 Boolean compatibility, page-budget evaluation, human-facing cell guidance, accepted-state synchronization, and zero-change accepted re-import.

## Interpretation

The evidence validates the coordinator's transition and delegation contract. It supports adopting v0.1.0 as a bounded orchestration layer around approved reasoning and TOC operations. It does not validate proposal quality, productivity improvement, arbitrary RFP automation, or PPT production.

## Limitations

- RFP analysis, summary quality, TOC quality, and strategy quality remain semantic human-and-LLM judgments.
- The regression uses synthetic paths and state objects for non-TOC stages.
- A complete new real RFP has not yet traversed the coordinator end to end.
- Distributed use, tamper resistance, and concurrent state updates remain unvalidated.
