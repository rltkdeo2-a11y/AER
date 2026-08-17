# Decision Record

Decision ID: DEC-007
**Title:** Separate Semantic Runtime Binding from Governance Closure
**Status:** Approved — Provisional Operating Decision
**Version:** 1.0
**Decision Date:** 2026-07-30
**Owner:** Human Co-Researcher
**Domain:** Runtime Binding and Governance Boundary
**Related Evidence:** EV-006
**Related Session:** SESSION-021 Runtime Binding Layer Separation Validation
**Related Decisions:** DEC-003, DEC-004, DEC-005, DEC-006
**Closure Mode:** Standard
**Git Permission:** Apply Only

---

## 1. Decision

AER provisionally separates:

1. **Semantic Runtime Binding:** reload authoritative Current State and relevant Decisions, classify input as `CONTINUE`, `REVISE`, `REOPEN`, or `NEW_SCOPE`, and prevent silent replacement of canonical reasoning state.
2. **Governance Closure:** provide authorization, accountability, auditability, release control, and recoverable repository change through Handoff, Closure, and Commit controls.

Current evidence does not justify describing Handoff, Closure, or Commit as demonstrated enhancers of semantic State Departure detection. They remain active governance controls and are not removed by this decision.

## 2. Basis

EV-006 used 45 repeated synthetic observations and three independent blind scorers. Reloaded Current State and Decision content performed consistently better than no reload. Adding valid approval provenance to matched content did not produce a reproducible incremental advantage.

This tests pre-existing provenance during later reference, not the cognitive effect of performing a live approval ritual. It is not evidence of statistical equivalence, B superiority, or lack of governance value.

## 3. Operating Rule

For ordinary semantic work:

- load authoritative active state and relevant Decisions;
- identify the governing accepted conclusion;
- classify the requested movement;
- preserve canonical state unless revision or reopening is justified;
- provide a safe alternative when a request conflicts with accepted state.

Use Handoff, Closure, and Commit for authoritative mutation, Final promotion, release or publication, protected-file change, high-loss or disputed judgment, audit/accountability needs, and transfers where authorization provenance is material.

## 4. Non-Effects

DEC-007 does not modify AER Core, weaken DEC-003 Global Closure, change `00_GOVERNANCE/CURRENT_STATE` authority, permit DEC-006-prohibited silent alteration, remove repository safeguards, establish A/B equivalence, disprove a live-ritual effect, or establish AER's real-work effectiveness.

## 5. Required Next Validation

Before broader simplification or permanent toolization, run an actual-work pilot that records naturally occurring departure candidates and measures missed conflicts, false reopening, recovery cost, latency, and governance overhead. It must distinguish semantic failures from audit or release failures and retain governance for authoritative release actions.

## 6. Reopen Conditions

Reopen if provenance repeatedly catches a material departure matched reload misses; lightweight operation causes authorization, audit, recovery, or release failure; longer tasks or other models show stable A/B separation; live approval activity independently improves reasoning; false `REOPEN` or missed `REVISE` becomes unacceptable; or Runtime Binding changes invalidate EV-006.

## 7. Decision Status

DEC-007 is approved provisionally. The layers have different evidence claims; governance remains active, while its semantic-detection benefit remains unproven. Actual-work validation is required before broader reduction or redesign.
