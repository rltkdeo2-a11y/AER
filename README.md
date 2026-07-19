# AX Engineering Research Repository (AER)

Version: AER v1.0

Status: Active

Research State: AETF v0.1.2

---

## Purpose

This repository is the Single Source of Truth (SSOT) for the AX Engineering Research project.

The repository stores only validated research assets.
Conversation is temporary, and only human-approved Research Commits become official repository knowledge.

AER is research into formalizing human reasoning as reusable and executable textual reasoning models.
Its primary focus is problem definition, reasoning operators, validation, decision control and reusable thought processes.

---

## Repository Structure

```text
00_GOVERNANCE/
01_DEFINITIONS/
02_PRINCIPLES/
03_HYPOTHESES/
04_ASSUMPTIONS/
05_EVIDENCE/
06_REASONING/
07_DECISIONS/
08_OPEN_PROBLEMS/
09_RESEARCH_LOG/
10_ARCHIVE/
```

---

## Repository Principles

- Research before documentation.
- Documentation before storage.
- Storage only through an approved Research Commit.
- Separate Fact, Observation, Inference, Decision, Assumption and Open Problem.
- Repository is the Single Source of Truth.
- Human approval is required before repository update.
- Research assets are revised through traceable Research Commits.
- Framework principles are separated from detailed methodology.
- Individual exceptions are not automatically promoted to general rules.
- Deep design should result in a minimal Runtime and minimum-sufficient records.

---

## Version Separation

### AER Repository Version

`AER v1.0`

The version of the repository structure, governance and operating rules.

### AETF Research State Version

`AETF v0.1.2`

The current development state of the AX Engineering Thinking Framework research content.

AER and AETF versions are managed separately.
Research-asset changes do not automatically change the repository structural version.

---

## Current Research Status

Current Phase:

`Post-RC-004 Operationalization`

Current Status:

`Approved proposal-stage Core integrated; research-closure automation prioritized`

Current Operational Objective:

Reduce the manual cost of closing an AER research discussion by moving from repeated Handoff, Codex, Diff and Commit approvals to one human approval of the research summary followed by LLM-managed application, validation and Commit.

This is an approved implementation target, not a completed current capability.
The existing repository-governance and Git-safety rules remain in force until the automation MVP is implemented and validated.

---

## Current Approved Research Assets

### Principle

- `02_PRINCIPLES/PR001_PROPOSAL_STAGE_REASONING.md`

### Evidence

- `05_EVIDENCE/EV001_PROPOSAL_RFP_VALIDATION_CASES.md`
- `05_EVIDENCE/EV002_RFP_BOTTLENECK_VALIDATION_CASES.md`

### Reasoning

- `06_REASONING/RS001_PROPOSAL_MODEL_GENERALIZATION.md`
- `06_REASONING/RS002_RFP_BOTTLENECK_REASONING_KERNEL.md`

### Decisions

- `07_DECISIONS/DEC001_ADOPT_PROPOSAL_STAGE_REASONING_MODEL.md`
- `07_DECISIONS/DEC002_ADOPT_RFP_BOTTLENECK_REASONING_KERNEL.md`

### Open Problem

- `08_OPEN_PROBLEMS/OP001_PM_Linkage_Criteria.md`
- Status: `Partially Resolved`

### Closed Research Sessions

- `09_RESEARCH_LOG/SESSION_003_PROPOSAL_STAGE_REASONING.md`
- `09_RESEARCH_LOG/SESSION_004_RFP_BOTTLENECK_REASONING.md`

For the detailed authoritative status map, see `00_GOVERNANCE/CURRENT_STATE`.

---

## Current Approved Model

The current proposal-stage Core is the combination of:

```text
DEC-001 Proposal-Stage Strategy Reasoning Model
+
DEC-002 RFP Bottleneck Reasoning Kernel
```

The approved Runtime follows this structure:

```text
Official RFP and source collection
→ Fact, requirement, evaluation, constraint, asset and information-gap separation
→ AS-IS, change need, TO-BE and customer-effect interpretation
→ Problem, cause and strategy Candidate generation
→ Source–Relation–Why–Target validation
→ Candidate / Working / Decision use-authority control
→ Confirmed / Conditional / Deferred / Invalid state control
→ Multiple Working Strategy maintenance
→ Strategy-changing assumption or condition-group identification
→ Failure-impact and realistic-alternative checks
→ Bottleneck-focused validation or conditional response
→ Decision Strategy selection
→ Requirement, evaluation, technology, schedule, cost, security and legal validation
→ Local reanalysis when additional information arrives
```

Required Bottleneck record:

```text
대상 전략·범위:
미확인 전제 또는 조건군:
전제 실패 시 실제 변화:
현실적 대체수단:
현재 조치:
재검토 조건:
```

---

## Validated Application Domain

First-level validation currently covers:

- Public-sector AX strategy proposals
- Public-sector ISP and ISMP proposals
- AI and data-platform consulting proposals
- Complex information-system implementation proposals
- Proposal-stage business understanding and strategy-structure generation
- RFP Link Governance and Bottleneck reasoning
- Incremental information update and local reanalysis

---

## Not Yet Validated

The following remain outside the validated scope:

- Operation and maintenance projects
- Simple equipment or solution delivery
- Research and development projects
- Private-sector proposals
- Pricing strategy
- Competitor prediction
- Final differentiation using actual company assets
- Transferability to other proposal managers
- Causal relationship with winning outcomes
- Universal application across all industries and proposal types

Unvalidated areas must not be represented as approved general rules.

---

## Current Open Research Questions

OP-001 remains `Partially Resolved`.

Remaining questions include:

- Link strength
- Minimum evidence threshold for Confirmed Link
- Intermediate-hypothesis criteria
- Priority when official information conflicts
- Direct/Mediated Link precision
- Combined Bottleneck interactions and chain effects
- Quantitative validation priority
- Cross-domain applicability

These questions are deferred until repeated failure, a structurally different case or a high-risk judgment demonstrates actual need.

---

## Repository Integration

RC-003:

- Commit: `4761da1`
- Title: `research: adopt proposal-stage strategy reasoning model`
- Status: Completed

RC-004:

- Commit: `4fbcb7f`
- Title: `research: add AER RFP bottleneck reasoning kernel`
- Status: Applied and pushed to `origin/main`

Repository structure remains at `AER v1.0`.
Research content remains at `AETF v0.1.2`.
Git history is authoritative for later documentation-synchronization Commits.

---

## Active Work Order

The approved execution order is:

1. Research Closure Automation MVP
2. `aer-reasoning` execution-integrity validation and minimum session binding if needed
3. Proposal Production Layer minimum structure
4. Dialectical Reasoning Pair manual prototype

### 1. Research Closure Automation MVP

Reuse the existing closure policy, ChatGPT–Codex protocol, Handoff specification, apply prompt and validation script.
Remove unnecessary manual transfer and repeated approval points rather than creating additional exception rules.

Target flow:

```text
Review existing research records
→ Summarize what will be stored today
→ One human approval, correction or rejection
→ Internal Handoff generation
→ Repository application
→ Consistency and Diff validation
→ Commit
→ Result report
```

### 2. AER Execution Integrity

Verify whether an `aer-reasoning` invocation keeps later turns bound to the current AER reasoning state.
Add only a minimum session-level binding if repeated tests demonstrate that it is necessary.
Do not add case-specific strategy rules.

### 3. Proposal Production Layer

This remains the next official reasoning-model research layer.
It will study the minimum transformation from Decision Strategy to connected Proposal Strategies, execution tasks, requirement and evaluation alignment, and a Proposal Blueprint.

### 4. Dialectical Reasoning Pair

Guilliman–Inquisitor is an experimental candidate, not part of the current Core.
Validate it manually before creating independent Agents.

---

## Current Boundary

The current Core does not include:

- Proposal Blueprint
- Proposal table of contents and page allocation
- Storyline and slide specification
- Requirement-to-slide placement
- PPT generation or rendering
- Deferred Diagnostic Modules as default Runtime
- External `aer-reasoning` skill implementation
- AER persistent conversation-mode implementation
- Guilliman–Inquisitor Agent implementation

Repository-external tools or memories are not considered official completed capabilities unless integrated through an approved Research Commit.

---

## Governance Notice

A research result becomes an official repository asset only after:

```text
Research Question
→ Reasoning
→ Knowledge Extraction
→ Human Approval
→ Repository Update
→ Validation
→ Traceable Research Commit
```

The current priority is to automate the operational steps after human approval without weakening research integrity, traceability or reversibility.
