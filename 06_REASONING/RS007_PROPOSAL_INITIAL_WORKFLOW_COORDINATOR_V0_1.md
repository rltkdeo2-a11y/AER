# Reasoning Record

Reasoning ID: RS-007

Title: Proposal Initial Workflow Coordinator v0.1

Status: Approved

Version: 0.1.0

Created: 2026-08-04

Updated: 2026-08-04

References:

- `07_DECISIONS/DEC001_ADOPT_PROPOSAL_STAGE_REASONING_MODEL.md`
- `07_DECISIONS/DEC002_ADOPT_RFP_BOTTLENECK_REASONING_KERNEL.md`
- `07_DECISIONS/DEC006_ADOPT_COGNITIVE_LOAD_REDUCTION_INTERACTION_LAYER.md`
- `06_REASONING/RS005_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_3.md`
- `06_REASONING/RS006_PROPOSAL_TOC_ROUNDTRIP_OPERATION_V0_3.md`
- `05_EVIDENCE/EV010_PROPOSAL_INITIAL_WORKFLOW_INTEGRATION_VALIDATION.md`

Summary:

A bounded coordinator connects the approved proposal TOC workbook routine to the initial AER proposal workflow without replacing AER Core reasoning or creating a general workflow engine. It preserves stage, artifact, human-gate, external-information, regeneration-authorization, and transition state in an external JSON artifact. Only the approved TOC re-import and acceptance operations are delegated to existing executable engines.

## 1. Research Question

How can the approved proposal TOC generation, human re-import, and acceptance operations be invoked as one continuous initial-workflow routine while preserving human judgment, selective reanalysis, and the Production Layer Hold?

## 2. Coordinator Boundary

The coordinator manages orchestration state. It does not perform RFP interpretation, approve a summary, infer consortium legality, generate a TOC, select strategy, or release RPA. Those semantic acts remain with AER Core and the human co-researcher.

The coordinator therefore registers outputs from reasoning stages and enforces their permitted order. This is narrower than a general workflow engine and does not change the AER Core sequence.

## 3. State Sequence

The bounded sequence is:

```text
SOURCE_INTAKE
→ SUMMARY_CONFIRMATION
→ FOUNDATION_INPUT
→ TOC_DRAFT
→ TOC_HUMAN_EDIT
→ TOC_REIMPORT
→ STRATEGY_CANDIDATES
→ COMPLETE
```

RFP analysis occurs between source intake and summary confirmation. TOC acceptance is an explicit operation inside the transition from re-import to strategy candidates. The absence of separate stage names for every internal reasoning act does not remove those acts from AER Core.

## 4. Human Gates

- Summary confirmation requires an explicit `approved=true` input.
- Consortium foundation data records the RFP consistency result; the coordinator does not decide consistency.
- Re-import produces a report and cannot advance directly to strategy candidates.
- Acceptance advances only after the existing acceptance engine creates an accepted workbook and state whose verification contains zero material, blocking, and structural changes and passes formula integrity.
- A known RFP conflict blocks foundation-input completion; an explicitly unresolved source dependency may remain visible while work proceeds under the approved TOC contract.
- Strategy-candidate registration requires a later explicit human selection or deferral before completion.
- RPA remains `HOLD` in every state.

## 5. External Information and Selective Reanalysis

External information may be registered at any stage. Registration preserves the current stage, creates a pending impact record, and sets the next action to impact review. It never regenerates an artifact.

Reanalysis requires a separate explicit human command. The bounded reopening targets are source analysis, TOC draft, or strategy candidates. The coordinator records the authorization and reason, invalidates affected downstream gates and artifact references, and does not itself create the revised semantic artifact.

## 6. Executable Contract

The PowerShell entry point exposes actions for starting a case, registering analysis, confirming the summary, recording foundation input, registering a TOC draft, analyzing a returned workbook, accepting confirmed TOC changes, registering and confirming strategy candidates, adding external information, and authorizing regeneration.

Every mutating action writes a new JSON state path distinct from the prior state, payload, and applicable workflow artifacts. Registered input artifacts must exist. This makes the transition chain inspectable and prevents silent in-place replacement. The TOC analysis and acceptance actions call the adopted v0.3.2 analyzer and v0.1.0 acceptance routine.

## 7. Limitations

- The coordinator does not make LLM reasoning deterministic.
- It does not generate a generic TOC from arbitrary RFPs.
- It does not validate the truth of human-provided company information.
- It does not support multi-user concurrency or tamper resistance.
- It does not implement PPT generation, RPA execution, or automatic content regeneration.
- Actual end-to-end use beyond the already validated TOC roundtrip remains unvalidated.

Reasoning Status:

Approved
