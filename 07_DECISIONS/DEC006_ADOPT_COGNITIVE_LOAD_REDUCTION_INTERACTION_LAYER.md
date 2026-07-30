# Decision Record

Decision ID: DEC-006

Title: Adopt a Cognitive-Load-Reduction Interaction Layer Without Changing AER Core

Status: Approved

Version: 1.0

Decision Date: 2026-07-30

Effective Date: 2026-07-30

Decision Owner:

Human Co-Researcher

Research Domain:

AER Human Cognitive Support and Interaction Safety

Related Research Session:

SESSION-012 Cognitive-Load-Reduction Interaction Design

Related Decisions:

- DEC-003 Global Impact and Consistency Closure
- DEC-004 First-Stage Stability and Execution-Integrity Reopening
- DEC-005 Tiered Runtime Selection and Production-Layer Transformation

Closure Mode:

Standard

Git Permission:

Apply Only

---

# 1. Decision Summary

A cognitive-load-reduction interaction layer is adopted outside AER Core.

Its purpose is to help a human worker concentrate on judgment after obtaining source material by reducing the amount of reasoning state that must be handled at one time. It may compress, sequence, and progressively disclose information for interaction, but it must not delete, replace, or silently alter the canonical AER reasoning state.

The adopted structure is:

```text
authoritative sources and approved state
→ AER Core canonical reasoning state
→ Safety Mediation Layer
→ Cognitive Projection Layer
→ Human Interaction Layer
→ explicit input classification and state transition
→ updated canonical state and audit trace
```

AER Core, its existing Link structure, use authority, validation states, Bottleneck logic, and Global Impact and Consistency Closure remain unchanged.

---

# 2. Purpose and Design Position

AER is treated as a human reasoning-support system, not as a replacement decision maker. The interaction layer should reduce the amount of state presented at once while preserving the full reasoning needed for safe decisions.

The following distinction is mandatory:

```text
reasoning limit ≠ display limit
hidden from the current view ≠ removed from the reasoning state
human acknowledgment ≠ evidence validation
human selection ≠ automatic Final Conclusion
summary screen ≠ canonical state
```

Time saving and decision-quality improvement are not adopted as current acceptance metrics. No unsupported quantitative performance claim is made.

---

# 3. Three-State Separation

## 3.1 Canonical Reasoning State

The canonical state is the complete authoritative state processed under AER Core. It retains, as applicable:

- objective and official baseline;
- confirmed conclusions and preserved limitations;
- Fact, Observation, Inference, Decision, Assumption, and Open Problem classification;
- source references and Link structure;
- Candidate, Working, and Decision use authority;
- Confirmed, Conditional, Deferred, and Invalid validation states;
- Bottleneck, failure impact, alternatives, and unresolved risk;
- mutable scope, stop or reopening conditions, and progress pointer; and
- Candidate Conclusion, Whole-Process Impact, Global Consistency, and Final Conclusion status.

Projection or interaction controls have no authority to weaken or overwrite this state.

## 3.2 Cognitive Projection State

The projection state is a temporary, traceable view derived from the canonical state for a specific human decision. It may reorder, group, summarize, or defer display of non-blocking detail. Every projected claim must remain traceable to the canonical state or be explicitly marked as an assumption, inference, or unresolved item.

## 3.3 Interaction State

The interaction state controls the current focus, visible depth, blocking question, queued questions, user-requested expansion, and the next permitted action. It is not a second reasoning model and cannot independently validate evidence or close a conclusion.

---

# 4. Safety Mediation Gates

Every projection must pass the following gates before it is presented as decision-ready.

## Gate A: Authority and State Legality

- Confirm the authoritative source set and current Active Reasoning State.
- Prevent State Departure, duplicate rediscovery, and unmarked assumption-to-fact promotion.
- Stop if the projection is based on stale, missing, or conflicting authority.

## Gate B: Compression Safety

- Preserve mandatory constraints, material uncertainty, failure conditions, limitations, and reopening conditions.
- Do not hide a FATAL or MATERIAL conflict, an unresolved blocking dependency, or the reason a conclusion remains Conditional or Deferred.
- Expand rather than compress when safe summarization cannot preserve meaning.

## Gate C: Importance-Based Expansion

Increase visible depth when importance, uncertainty, irreversibility, cross-system effect, dispute risk, or potential loss is high. A human request for more detail also triggers expansion. This gate changes presentation depth, not the selected AER Runtime under DEC-005.

## Gate D: Closure Protection

- Preserve the distinction between Candidate Conclusion and Final Conclusion.
- Do not present a result as final before required Whole-Process Impact and Global Consistency checks pass.
- Keep unresolved conflicts visible through a Conflict or Hold presentation.

## Gate E: Human Change Control

- Classify material human input as `CONTINUE`, `REVISE`, `REOPEN`, or `NEW_SCOPE` before changing the canonical state.
- Record what changed, why it changed, and what prior conclusion or limitation remains in force.
- Treat human acceptance of a view as acknowledgment or selection only; evidence status changes and repository authority still require their applicable validation and governance.

Gate outcomes are `PASS`, `EXPAND`, or `HOLD`. `HOLD` prohibits a decision-ready presentation until the blocking issue is resolved or explicitly dispositioned.

---

# 5. Output Model

## Level 1: Decision Brief

The default interaction view contains only the minimum safe decision set:

1. current objective or decision;
2. recommended or current conclusion and its status;
3. decisive supporting grounds;
4. material conflict, uncertainty, or limitation;
5. the one human action or answer needed now; and
6. the next state after that action.

Level 1 must not omit information that would change the decision or invalidate its apparent readiness.

## Level 2: Rationale and Alternatives

Level 2 expands the decision rationale, alternatives, dependencies, changed assumptions, failure mechanisms, and supporting Links. It is shown on request or when Gate C requires expansion.

## Level 3: Full Trace and Audit

Level 3 exposes the canonical trace needed for audit, dispute, high-loss review, or detailed verification, including source references, Link paths, validation states, rejected alternatives, state transitions, and closure checks.

## Context Cards

- `Delta Card`: what materially changed since the last accepted state.
- `Conflict Card`: which claims, constraints, or sources conflict and why the conflict matters.
- `Hold Card`: what prevents safe continuation, what is known, and what resolves the hold.

Cards are projections of canonical state. They do not create independent facts or decisions.

---

# 6. Interaction Rules

1. Present one blocking question at a time.
2. Queue additional questions and disclose the queue without forcing the human to answer all items simultaneously.
3. Do not ask a non-blocking question when safe progress is possible under an explicitly marked assumption.
4. Prefer a Delta view over repeating an already approved discussion.
5. Allow the human to request Level 2 or Level 3 detail at any time.
6. After material human input, classify the input and update the canonical state before presenting the next decision-ready view.
7. Preserve Deferred and unresolved items even when they are not displayed in Level 1.
8. Never convert interface convenience, silence, or a generic “continue” instruction into semantic approval.

---

# 7. State-Transition Contract

```text
canonical state
→ projection request for a specific decision
→ Gates A–E
→ PASS: present the selected depth
   EXPAND: increase depth and rerun the affected gate
   HOLD: present the blocking condition only
→ human input
→ CONTINUE / REVISE / REOPEN / NEW_SCOPE classification
→ AER Core reanalysis or preserved state
→ transition and Delta record
→ next projection
```

No interaction-layer shortcut may bypass AER Core, alter evidence status directly, or skip Global Consistency Closure.

---

# 8. Boundaries and Limitations

This Decision:

- does not modify the AER Core reasoning sequence or add a Core operator;
- does not change DEC-001 through DEC-005;
- does not change AER v1.0 or AETF v0.1.2;
- does not implement a user interface, external agent, RAG system, or Proposal Production Layer;
- does not reopen the Production Layer Hold recorded in SESSION-011;
- does not claim measured time reduction or decision-quality improvement;
- does not reduce source-verification, evidence, or repository-governance requirements; and
- does not treat progressive disclosure as permission to suppress material risk.

The design is approved as a safe interaction architecture. Its usability and behavior in repeated actual work remain unvalidated.

---

# 9. Stop and Reopening Conditions

Further abstract design expansion stops when the architecture, invariants, gates, views, and transition contract are sufficient to guide a bounded implementation.

Reopen this Decision when actual use shows one or more of the following:

- a material condition was hidden or lost through compression;
- users repeatedly misunderstand the status or authority of a conclusion;
- human input changes the canonical state without an explicit transition;
- the one-question queue conceals dependencies or creates unsafe delay;
- progressive disclosure prevents timely recognition of a high-impact conflict;
- the interaction layer duplicates or changes AER Core reasoning; or
- a structurally different use case cannot be represented safely by the three-state separation.

Decision Status:

Approved
