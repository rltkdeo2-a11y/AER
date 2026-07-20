# Decision Record

Decision ID: DEC-005

Title: Adopt Tiered Runtime Selection and Production-Layer Transformation

Status: Approved

Version: 1.0

Decision Date: 2026-07-21

Effective Date: 2026-07-21

Decision Owner:

Human Co-Researcher

Research Domain:

AER Runtime Selection and Production-Layer Transformation

Related Research Session:

SESSION-007 Tiered Runtime and Production Layer Closure

Related Evidence:

EV-005 Tiered Runtime Comparative Validation

Closure Mode:

Release

---

# 1. Decision Summary

A tiered runtime model is adopted without changing AER Core:

1. AER Core is the default runtime for general complex judgment.
2. B-type independent counterargument reinforcement is a selective reinforcement runtime for judgments with high importance, uncertainty, or self-fixation risk.
3. The full C structure is a restricted high-precision validation mode for audit, dispute, and high-loss judgments.

The Adjudicator is not required in the general runtime.

---

# 2. Decision Basis

The approved comparative evidence established that:

- B was not always superior to A,
- B reliably added an independent opposing model and strategy revision,
- C did not generally improve conclusions beyond B in the three test records,
- C added severity classification, challenge disposition, and audit traceability, and
- general-runtime necessity of the Adjudicator was not supported.

The supporting tests and limitations are recorded in `05_EVIDENCE/EV005_TIERED_RUNTIME_COMPARATIVE_VALIDATION.md`.

---

# 3. Runtime Selection

## Default Runtime

Use AER Core for general complex judgment.

## Selective Reinforcement Runtime

Add B-type independent counterargument review when importance, uncertainty, or self-fixation risk is high. B must preserve genuine independence by producing an opposing model and allowing strategy revision rather than merely restating or absorbing the original position.

## Restricted High-Precision Validation Mode

Use the full C structure only when auditability, dispute handling, or potential loss makes explicit severity classification, challenge disposition, and audit traceability necessary.

---

# 4. Production Layer Principle

Strategy specificity is the degree to which this chain is logically closed:

```text
selection rationale
→ operating mechanism
→ execution and accountability
→ evidence of success
→ failure conditions and alternative path
```

Validation outputs are transformed as follows:

- counterargument → strategy selection rationale,
- failure mechanism → risk–response–evidence,
- alternative → superiority of the current strategy,
- disposition → application condition and design principle,
- reopening condition → decision gate, and
- residual risk → risk register and validation metric.

---

# 5. Stop and Reopening Decision

Similar RFP repeat testing is stopped. Research reopens only after an actual-application failure, a structurally different case, formal-only counterargument or automatic absorption by B, discovery by C of a FATAL or MATERIAL issue missed by B, or a disposition error in an audit or dispute environment.

---

# 6. Boundaries and Limitations

This Decision:

- does not modify the AER Core specification or reasoning sequence,
- does not make B or C the default runtime,
- does not claim universal superiority of B over A or C over B,
- does not require an Adjudicator in the general runtime,
- does not implement an external runtime or the Proposal Production Layer, and
- does not change AER v1.0 or AETF v0.1.2.

Decision Status:

Approved
