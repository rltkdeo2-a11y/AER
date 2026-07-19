# Decision Record

Decision ID: DEC-003

Title: Adopt Global Impact and Consistency Closure

Status: Approved

Decision Date: 2026-07-20

Effective Date: 2026-07-20

Decision Owner:

Human Co-Researcher

Research Domain:

AER Domain-Invariant Reasoning Discipline

Related Research Session:

SESSION-005 Global Reasoning Closure

Related Evidence:

EV-003 Autonomous Closure Self-Application Case

Closure Mode:

Release

---

# 1. Decision Summary

AER adopts global impact and consistency closure as a required boundary between a directly validated solution and a Final Conclusion.

A solution that passes Direct Validation and counterargument review remains a Candidate Conclusion. It becomes a Final Conclusion only after Whole-Process Impact Validation and Global Consistency Validation pass.

When closure identifies a material conflict, the solution or the Problem Definition must be revised and revalidated before PASS.

---

# 2. AER Target

AER is a domain-invariant reasoning discipline. It is not a universal domain-knowledge system and does not claim to generate correct answers for every domain.

The following vary by domain:

- domain knowledge
- input variables
- evidence standards
- validation intensity
- execution method

The following discipline remains invariant:

```text
Problem Definition
→ Separate Facts, Assumptions, and Unknowns
→ Identify Bottlenecks and Constraints
→ Construct Solution Hypothesis
→ Direct Validation and Counterargument Review
→ Candidate Conclusion
→ Whole-Process Impact and Global Consistency Closure
→ Revise Solution or Reopen Problem Definition when required
→ Revalidate
→ PASS
→ Final Conclusion and Execution
→ Post-Application Verification
```

---

# 3. Validation Boundary

## Direct Validation

Direct Validation asks whether the proposed solution itself is factually and logically viable.

## Global Closure

Global Closure asks whether the viable solution:

- improves the whole system or process,
- remains aligned with the higher-level purpose,
- respects material constraints, priorities, and stop rules,
- remains compatible with confirmed conclusions, and
- explicitly revises prior conclusions when sufficient grounds exist.

Confirmed conclusions are preserved as reasoning state, not treated as immutable constraints.

---

# 4. Closure Outcomes

Global Closure produces one of four outcomes:

- PASS: confirm the Candidate Conclusion.
- Revise Solution: retain the Problem Definition, revise the solution, and revalidate.
- Reopen Problem Definition: reconstruct the problem and reopen the alternative space.
- Hold or Stop: obtain necessary information or apply an existing stop rule.

A Candidate Conclusion must not silently overwrite confirmed state. When an earlier conclusion is revised, preserve the prior conclusion, reason for revision, replacement conclusion, and downstream impact.

---

# 5. Stop Condition

Global Closure does not require complete prediction of all consequences.

Stop when:

- no new conflict capable of changing the conclusion is found,
- no material damage to the higher-level purpose is found,
- no important new failure point is found,
- residual risk can be managed through execution or withdrawal conditions,
- additional analysis has low expected value, and
- the same issue repeats without new information.

Validation intensity must remain proportional to the problem, evidence, and risk.

---

# 6. Boundaries and Limitations

This Decision:

- does not claim validation across every domain,
- does not declare AER Core finally complete,
- does not create a new operator family or mandatory long checklist,
- does not define a Production Layer,
- does not depend on any named agent pattern or implementation technology, and
- does not promote execution-environment defects into the Core reasoning model.

Decision Status:

Approved
