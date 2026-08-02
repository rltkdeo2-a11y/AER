# Reasoning Record

Reasoning ID: RS-003

Title: Proposal TOC Workbook Generation and Re-import Contract v0.1

Status: Approved

Version: 0.1.0

Created: 2026-08-03

Updated: 2026-08-03

References:

- `07_DECISIONS/DEC008_FREEZE_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_1.md`
- `09_RESEARCH_LOG/SESSION_013_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_1.md`
- `07_DECISIONS/DEC005_ADOPT_TIERED_RUNTIME_SELECTION_AND_PRODUCTION_LAYER_TRANSFORMATION.md`
- `09_RESEARCH_LOG/SESSION_011_PRODUCTION_LAYER_CANDIDATE_DESIGN_HOLD.md`
- `06_REASONING/contracts/proposal-toc-v0.1/proposal-toc-contract-v0.1.json`
- `06_REASONING/contracts/proposal-toc-v0.1/proposal-toc-state-v0.1.schema.json`
- `06_REASONING/contracts/proposal-toc-v0.1/case1-representative-state.json`
- `scripts/proposal-toc-contract-v0.1/test-proposal-toc-contract.ps1`

Summary:

This record freezes the minimum internal data structure and the generation and re-import contracts used by the first proposal table-of-contents workbook case. The workbook is the human editing surface. A normalized state with stable identifiers is the machine comparison authority. The contract is limited to proposal-manager augmentation and does not implement PPT production, layout selection, retrieval, or automatic regeneration.

---

## 1. Research Question

What minimum contract allows AER to repeat the first-case RFP-to-TOC-workbook process while preserving human PM authority, detecting meaningful workbook changes, and preventing an unapproved downstream RPA release?

---

## 2. State Position

The current Production Layer Hold is reopened only for this bounded contract.

The reopening basis is:

- one actual RFP case was processed;
- an independently produced human PM workbook was available for comparison;
- the human explicitly selected expert augmentation rather than expert replacement;
- the implemented workbook exposed concrete requirements for consortium input, A3 treatment, exact page allocation, stable hierarchy, and re-import change detection; and
- the current task explicitly approves freezing the resulting first-case contract.

The following prior limitations remain in force:

- no claim of expert productivity improvement;
- no claim of transferability to other PMs;
- no universal Production Layer sequence;
- no PPT generation or rendering;
- no large-sample RAG prerequisite; and
- no causal claim about proposal success.

---

## 3. Three-Layer State Model

### 3.1 Authoritative source state

This layer records RFPs, task specifications, human inputs, PM samples, and their authority and status.

It answers:

- which source exists;
- whether it is official, human, or reference material;
- whether it is active, superseded, or deferred; and
- what RFP constraint or human declaration it supports.

### 3.2 Canonical normalized state

This is the machine comparison authority. It contains stable identifiers and normalized objects for:

- source registry;
- human inputs;
- RFP constraints;
- TOC nodes;
- atomic requirements;
- requirement mappings;
- baseline snapshots;
- approval state; and
- RPA release state.

The normalized state is not replaced by spreadsheet cell positions.

### 3.3 Human workbook surface

The workbook is a projection of the normalized state for PM work.

The visible area contains editable titles, requirement placement, A3 selection, physical page allocation, owner, notes, and human confirmation. Machine fields may remain hidden or visually minimized. The workbook does not become canonical merely because a human edited it.

---

## 4. Stable Identity and Hierarchy

Every source, TOC node, atomic obligation, mapping, and RPA page specification requires a stable identifier.

The primary TOC identity key is `node_id`.

Hierarchy rules:

1. Routine TOC generation uses levels 1 through 3.
2. Level 4 remains schema-valid only to preserve detectability; its use is non-routine and requires review.
3. An RFP-fixed node preserves its parent and level.
4. An RFP-fixed title may be edited by the PM.
5. LLM-proposed detail is placed below the applicable RFP-fixed parent.
6. A newly inserted row without a recognized identifier receives a provisional stable identifier before comparison.
7. A baseline node missing from re-import is treated as deleted, not silently ignored.

---

## 5. Page and A3 Contract

The RFP page constraint is normalized as an exact target.

Expressions such as approximately X pages, within X pages, or maximum X pages are treated as exactly X pages under the approved operating convention unless the human explicitly overrides the rule for a specific case.

Front-matter exclusions such as cover and table of contents are recorded explicitly.

For a leaf node:

```text
counted_pages = physical_sheets * 2 when a3_checked is true
counted_pages = physical_sheets * 1 when a3_checked is false
```

Allocation is complete only when:

- leaf counted pages equal the target exactly;
- the LLM check passes;
- the human check passes; and
- no blocking constraint conflict remains.

An A3 change is a review-triggering format change. It is not treated as a local note edit.

---

## 6. Requirement Mapping Contract

Requirements are separated into requirement groups and atomic obligations.

Each non-control atomic obligation requires exactly one `MAIN` mapping. It may have zero or more `SUB` mappings.

The RFP-fixed hierarchy supplies the first responsibility boundary:

- a child whose content belongs under the applicable RFP parent is the primary responsibility candidate; and
- a less direct related placement is supplementary.

This rule creates a draft mapping. Final verification responsibility remains human because a user may otherwise over-trust the AER judgment.

---

## 7. Generation Contract

### 7.1 Required inputs

- registered source documents;
- resolved RFP page rule;
- identified RFP-fixed TOC hierarchy;
- analyzed requirements;
- consortium declaration and participant count, or explicit omission of that input; and
- other available external information.

### 7.2 Blocking gates

Generation stops or enters Hold when:

- the page rule cannot be resolved;
- the official TOC cannot be distinguished from proposed detail;
- the human consortium declaration conflicts with an RFP prohibition; or
- the source authority needed for a fixed constraint is missing.

### 7.3 Required generation outputs

- normalized state;
- PM-editable workbook;
- requirement review view;
- baseline snapshot;
- change-detection fields; and
- structural RPA specification in `HOLD`.

The first generation does not release RPA execution.

---

## 8. Re-import Contract

Re-import reads the edited workbook into a new normalized current state and compares it with the baseline by stable identity.

Tracked fields:

- title;
- parent;
- level;
- A3 state;
- physical page count; and
- requirement placement.

Preserved but excluded from LLM impact:

- owner.

Note-only changes are local. Owner changes are intentionally ignored by LLM impact analysis because owner assignment has no approved relationship to page allocation or content reasoning.

Change precedence is:

```text
OFFICIAL_STRUCTURE_BLOCK
LEVEL_CHANGED
REPARENTED
NEW
DELETED
FORMAT_CHANGED
PAGE_CHANGED
REQUIREMENT_CHANGED
RENAMED
UNCHANGED
```

Impact classes are:

- `LOCAL`: owner-only or note-only change;
- `REVIEW`: title, A3, page, or requirement-placement change; and
- `STRUCTURAL`: new or deleted node, parent or level change, proposal-mode change, or strategy-wide hierarchy change.

Re-import reports the impact. It does not automatically regenerate the TOC or RPA specification.

---

## 9. Human Command Boundary

External information may enter at any point, but receiving information does not itself authorize regeneration.

The default response is:

```text
register source
-> identify affected constraints, nodes, requirements, and approvals
-> report local, review, or structural impact
-> preserve the current workbook and RPA specification
-> wait for an explicit human regeneration command when required
```

An explicit release command is also required before the RPA state may change from `HOLD` to `RELEASED`.

---

## 10. Machine-Readable Contract

The normative machine package is:

- `proposal-toc-contract-v0.1.json`: operations, invariants, impact classes, non-goals, and reopening conditions;
- `proposal-toc-state-v0.1.schema.json`: state shape and enumerations; and
- `case1-representative-state.json`: a bounded fixture that preserves the observed first-case metrics while avoiding storage of the complete external RFP-derived data set.

The fixture is a representative slice, not a second claim that four stored nodes reproduce the complete 59-row workbook.

---

## 11. Validation Result

The executable contract test confirms:

- contract, schema, and fixture JSON parse;
- exact target-page allocation;
- A3 multiplication;
- one MAIN mapping per non-control obligation;
- stable hierarchy and official-structure protection;
- A3 change classification as `FORMAT_CHANGED / REVIEW`;
- owner-only change exclusion;
- row insertion classification as `NEW / STRUCTURAL`; and
- rejection of premature RPA release.

The first-case workbook implementation separately observed:

- 59 TOC rows;
- 32 leaf rows;
- 484 mapping rows;
- 292 requirement rows;
- exact 80 counted pages;
- A3 toggle behavior of 2 to 1 to 2 counted pages; and
- no detected spreadsheet formula errors.

---

## 12. Freeze and Reopening Rule

Version `0.1.0` is frozen for Case 1.

It may be extended after Case 2 and Case 3, but those cases must not silently alter this contract. A revision requires an explicit version change and a recorded impact on generation, re-import, validation, and prior fixtures.

Reopen before the planned cases only if:

- row insertion cannot be normalized safely;
- a page or A3 mismatch escapes detection;
- MAIN responsibility cannot be represented;
- a structural edit is misclassified; or
- the contract creates material PM rework.

Reasoning Status:

Approved
