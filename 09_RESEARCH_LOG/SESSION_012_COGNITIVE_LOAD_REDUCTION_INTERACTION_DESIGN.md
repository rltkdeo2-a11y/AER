# Research Session Log

Session ID: SESSION-012

Title: Cognitive-Load-Reduction Interaction Design

Date Started: 2026-07-30

Date Applied: 2026-07-30

Status: Approved interaction architecture recorded; implementation code and usability validation deferred

Research Domain: AER Human Cognitive Support and Interaction Safety

Closure Mode:

Standard

Git Permission:

Apply Only

Related Decision:

DEC-006 Adopt a Cognitive-Load-Reduction Interaction Layer Without Changing AER Core

---

## 1. Research Question

How can AER reduce the human worker's cognitive burden and focus interaction on decisions without weakening, truncating, or silently changing the reasoning state required by AER Core?

---

## 2. Human Purpose and Approved Direction

The human purpose is to use AER as a reasoning-support system after the worker has obtained source material. AER should shorten the amount of reasoning work that must be actively carried by the human so that attention can be concentrated on judgment.

The discussion explicitly excluded time reduction and decision-quality improvement as current measurement criteria. The adopted design is therefore evaluated by structural safety and preservation of reasoning authority, not by an unsupported productivity score.

The approved direction is:

- preserve the full AER canonical state;
- place cognitive-load controls outside AER Core;
- derive safe, traceable projections for the current decision;
- disclose detail progressively without treating hidden detail as removed;
- ask one blocking question at a time while preserving a visible queue; and
- reflect human input only through explicit state classification and transition.

---

## 3. Design Alternatives Considered

### Alternative A: Simplify AER Core

Rejected. Removing Core steps or state to reduce interaction burden could damage existing Link, Bottleneck, validation-state, and Global Consistency functions.

### Alternative B: Replace the Full State With a Summary

Rejected. A summary can support interaction but cannot become canonical authority because compression may omit limitations, conflicts, and reopening conditions.

### Alternative C: Add a Non-Core Interaction Architecture

Selected. Safety mediation, cognitive projection, and interaction control can reduce visible complexity while keeping the complete reasoning state and existing Core authority intact.

---

## 4. Approved Architecture

```text
Authority and Session Binding
→ AER Core Canonical Reasoning State
→ Safety Mediation Layer
   - authority and state legality
   - compression safety
   - importance-based expansion
   - closure protection
   - human change control
→ Cognitive Projection Layer
   - Level 1 Decision Brief
   - Level 2 Rationale and Alternatives
   - Level 3 Full Trace and Audit
   - Delta / Conflict / Hold Cards
→ Human Interaction Layer
   - current focus
   - one blocking question
   - queued questions
   - requested depth
→ Input Classification
   - CONTINUE / REVISE / REOPEN / NEW_SCOPE
→ AER Core State Transition and Audit
→ next safe projection
```

The Safety Mediation Layer is not an independent decision maker. It controls whether and how canonical information may be projected. The Cognitive Projection Layer is not a second state of truth. The Human Interaction Layer controls attention and sequencing only.

---

## 5. Canonical, Projection, and Interaction State

The design separates three states to avoid accidental loss of reasoning information.

### Canonical State

The full authoritative reasoning state, including source links, evidence classification, use authority, validation state, limitations, open problems, failure conditions, Global Consistency status, and the progress pointer.

### Projection State

A decision-specific view derived from canonical state. It may summarize and reorder information but must preserve traceability and expose any material condition that could change the decision.

### Interaction State

The current display depth, focus, blocking question, question queue, expansion request, and next interaction action. It cannot validate evidence or alter canonical conclusions.

---

## 6. Cognitive Projection Contract

### Level 1: Decision Brief

Default fields:

1. objective or decision now;
2. current conclusion and status;
3. decisive grounds;
4. material risk, conflict, or limitation;
5. one required human action; and
6. next state after the action.

### Level 2: Rationale and Alternatives

Adds alternative options, dependencies, changed assumptions, failure mechanisms, and supporting Link paths.

### Level 3: Full Trace and Audit

Adds source-level traceability, validation-state details, rejected alternatives, state-transition history, and closure checks.

### Context Cards

- Delta: material changes since the last approved state.
- Conflict: the conflicting claims or constraints and their decision effect.
- Hold: the blocking condition and the evidence or choice needed to release it.

---

## 7. Interaction and Human-Authority Rules

- Display no more than one blocking question at a time.
- Keep other necessary questions in a queue and preserve their dependencies.
- Continue safely under a marked assumption when the question is non-blocking.
- Prefer changed information over replaying already approved discussion.
- Permit human-requested expansion at any time.
- Classify material human input before modifying canonical state.
- Do not treat view acceptance as evidence validation.
- Keep use authority separate from validation state.
- Do not treat a generic request such as “next” as repository approval or semantic approval beyond its explicit context.

---

## 8. Safety Invariants

The following invariants apply across every view and interaction:

```text
display limit is not a reasoning limit
hidden is not deleted
compressed is not invalidated
human acceptance is not validation
selection is not Final Conclusion
projection is not canonical authority
interaction convenience is not change authority
```

Any violation produces `HOLD` and returns the issue to the canonical reasoning path.

---

## 9. Compatibility With Existing AER

The design preserves:

- DEC-001 proposal-stage reasoning;
- DEC-002 Link Governance and Bottleneck reasoning;
- DEC-003 Global Impact and Consistency Closure;
- DEC-004 State Departure and execution-integrity boundaries;
- DEC-005 tiered Runtime selection;
- Candidate, Working, and Decision use authority;
- Confirmed, Conditional, Deferred, and Invalid validation states; and
- existing governance for Handoff, protected files, Stage, Commit, and Push.

Importance-based display expansion does not automatically select B or C Runtime. Runtime selection continues to follow DEC-005.

---

## 10. Explicit Non-Goals

This session does not:

- change AER Core;
- introduce a new reasoning operator;
- reopen or implement the Proposal Production Layer;
- implement RAG, an external agent, or a user interface;
- remove or supersede prior discussion records;
- establish time-saving or decision-quality metrics;
- claim actual-work usability validation; or
- change AER v1.0 or AETF v0.1.2.

The Runtime `SubagentStart` activation observation remains a separate pending execution-validation item and is not resolved by this design.

---

## 11. Validation and Reopening Plan

The next validation, when separately approved, should use bounded actual decisions and check whether:

- Level 1 retains every decision-changing condition;
- expansion triggers before material context is lost;
- the question queue preserves dependency order;
- human input always produces an explicit transition;
- Delta, Conflict, and Hold Cards remain traceable to canonical state; and
- the interaction layer never performs independent Core reasoning.

Reopen the design on hidden material risk, repeated status misunderstanding, implicit state change, unsafe question sequencing, failure of traceability, or duplication of AER Core.

---

## 12. Repository Application Result

Created:

- `07_DECISIONS/DEC006_ADOPT_COGNITIVE_LOAD_REDUCTION_INTERACTION_LAYER.md`
- `09_RESEARCH_LOG/SESSION_012_COGNITIVE_LOAD_REDUCTION_INTERACTION_DESIGN.md`

Intentionally unchanged under the approved scope:

- AER Core and DEC-001 through DEC-005;
- AER v1.0 and AETF v0.1.2;
- `00_GOVERNANCE/CURRENT_STATE`;
- Production Layer implementation and SESSION-011 Hold conditions;
- Runtime implementation files; and
- README, CHANGELOG, and existing index files.

Commit and Push:

- Not performed under Apply Only approval.
