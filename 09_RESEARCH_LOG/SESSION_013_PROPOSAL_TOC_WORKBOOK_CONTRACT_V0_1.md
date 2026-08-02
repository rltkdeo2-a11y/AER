# Research Session Log

Session ID: SESSION-013

Title: Proposal TOC Workbook Contract v0.1 Freeze

Status: Approved and implemented

Version: 1.0

Date Started: 2026-08-03

Date Applied: 2026-08-03

Research Domain:

Proposal TOC Workbook and PM Change Transfer

Closure Mode:

Standard

Git Permission:

Autonomous Closure

References:

- `06_REASONING/RS003_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_1.md`
- `07_DECISIONS/DEC008_FREEZE_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_1.md`
- `07_DECISIONS/DEC005_ADOPT_TIERED_RUNTIME_SELECTION_AND_PRODUCTION_LAYER_TRANSFORMATION.md`
- `09_RESEARCH_LOG/SESSION_011_PRODUCTION_LAYER_CANDIDATE_DESIGN_HOLD.md`
- `06_REASONING/contracts/proposal-toc-v0.1/proposal-toc-contract-v0.1.json`
- `06_REASONING/contracts/proposal-toc-v0.1/proposal-toc-state-v0.1.schema.json`
- `06_REASONING/contracts/proposal-toc-v0.1/case1-representative-state.json`
- `scripts/proposal-toc-contract-v0.1/test-proposal-toc-contract.ps1`

Summary:

This session converts the first-case TOC workbook prototype into a frozen v0.1 internal-state, generation, and re-import contract. It is a bounded reopening of the Production Layer Hold for personal PM augmentation. It does not implement or approve PPT production.

---

## 1. Research Question

How can the successful first-case RFP-to-TOC-workbook process become a repeatable AER routine without turning the workbook into an opaque system state or automatically overriding PM judgment after edits?

---

## 2. Evidence Basis

External working evidence reviewed in the research conversation:

- Case 1 official RFP;
- independently produced human PM TOC workbook;
- AER-generated TOC workbook prototype;
- v2 workbook with PM-visible and machine fields separated; and
- executed formula, A3-toggle, change-classification, owner-ignore, page-budget, requirement-mapping, and RPA-Hold checks.

Observed first-case implementation metrics:

- 59 TOC rows;
- 32 leaf rows;
- 484 mapping rows;
- 292 requirement rows;
- 80 target and counted pages;
- one demonstrated A3 decision;
- A3 toggle result of 2 to 1 to 2 counted pages; and
- zero detected spreadsheet formula errors.

The complete external source files and generated workbook are not committed as repository knowledge objects. The committed fixture is explicitly a representative slice.

---

## 3. Fact, Observation, Inference, and Decision Separation

### Facts

- The first RFP fixed a TOC and an exact operational page target.
- The human PM artifact used a consortium allocation and marked an A3 page.
- The prototype could calculate A3 as two counted pages.
- Stable identifiers and a baseline allowed A3 and page changes to be detected.
- Owner-only edits did not need to affect page or content reasoning.

### Observations

- Human-visible workbook simplicity and machine traceability require different representations.
- Cell position alone is insufficient for reliable row insertion and hierarchy comparison.
- Rebuilding every downstream artifact after every information update would create unnecessary work.

### Inferences

- A normalized state should be canonical for machine comparison while the workbook remains the PM interface.
- Re-import should report impact before regeneration.
- Explicit release is necessary to keep an unfinished or newly changed workbook from entering a future RPA workflow.

### Decisions

- Freeze the v0.1 contract in RS-003 and its machine-readable package.
- Use stable `node_id` identity and a baseline snapshot.
- Adopt LOCAL, REVIEW, and STRUCTURAL impact classes.
- Preserve the general Production Layer limitations outside this bounded contract.

---

## 4. Approved Research Handoff

Handoff ID:

RH-20260803-001

Approval Status:

Approved

Closure Mode:

Standard

Git Permission:

Autonomous Closure

Research Question:

Freeze the first-case internal data structure and generation and re-import contracts as v0.1 for routine AER use.

Approved Conclusions:

- normalized JSON is the machine state;
- XLSX is the human PM surface;
- stable identifiers and baseline comparison govern re-import;
- exact pages, A3 multiplication, MAIN uniqueness, owner exclusion, change classes, and explicit RPA release are invariants; and
- the contract is frozen for Case 1 and tested before Cases 2 and 3.

Evidence Basis:

The first-case RFP, human PM workbook, implemented v2 workbook, and executed validation described in Section 2.

Scope and Limitations:

The scope is the proposal TOC workbook and its future RPA structural handoff. PPT generation, RAG, automatic layout, universal generalization, expert replacement, and success claims remain excluded.

Repository Actions:

- create RS-003;
- create DEC-008;
- create SESSION-013;
- create the bounded machine-readable contract, state schema, and representative fixture under `06_REASONING/contracts/proposal-toc-v0.1/`; and
- create the executable contract test under `scripts/proposal-toc-contract-v0.1/`.

Expected Base Commit:

`0cad2e75343f9612c1ef871a7bef8ee640b48310`

Target Branch:

`main`

Proposed Commit Title:

`research: freeze proposal toc workbook contract v0.1`

Push Authorization:

Authorized, non-force only.

Protected Files:

None authorized or required.

Allowed Paths:

- `06_REASONING/RS003_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_1.md`
- `06_REASONING/contracts/proposal-toc-v0.1/*`
- `07_DECISIONS/DEC008_FREEZE_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_1.md`
- `09_RESEARCH_LOG/SESSION_013_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_1.md`
- `scripts/proposal-toc-contract-v0.1/*`

Unresolved Questions:

- whether Case 2 requires additional input or constraint types;
- whether separated RFP and task-specification documents require source-precedence changes;
- whether native Excel row insertion preserves enough identifiers without an import repair step; and
- whether the current MAIN responsibility rule remains sufficient in the more complex case.

Validation Requirements:

- JSON parse;
- executable contract regression pass;
- non-zero files;
- UTF-8 Markdown;
- filename and internal-ID consistency;
- reference existence;
- no protected-file changes;
- changed-file scope comparison; and
- `git diff --check`.

---

## 5. Explicitly Unchanged

- AER Core;
- AER v1.0;
- AETF v0.1.2;
- protected governance files;
- root and directory index files;
- PPT Production Layer;
- RAG and external agents; and
- the pending execution-integrity research priority.

---

## 6. Next Validation

Run the same contract against Case 2 without modifying v0.1 unless a concrete incompatibility is found. Then run Case 3 with separated RFP and task-specification sources. Version the contract only for a material incompatible change.
