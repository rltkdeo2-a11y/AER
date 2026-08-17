# Evidence Record

Evidence ID: EV-006
**Title:** Exploratory Repeated Validation of Runtime Binding Layer Separation
**Status:** Approved with explicit limitations
**Version:** 1.0
**Created:** 2026-07-30
**Last Updated:** 2026-07-30
**Domain:** AER Runtime Binding and State Departure Detection
**Related Session:** SESSION-021 Runtime Binding Layer Separation Validation
**Related Decisions:** DEC-004, DEC-006, DEC-007

---

## 1. Research Question and Boundary

R4 tested whether valid approval provenance adds observable semantic State Departure detection value when identical Current State and Decision content are reloaded.

It did not test the reasoning effect of performing live Handoff, Closure, or Commit activity. It also did not test auditability, accountability, release integrity, actual proposal outcomes, or the general utility of AER.

## 2. Method

- Conditions A and B received identical Current State and Decision content.
- A had a referentially valid target approval chain; B had matched structure and repository maturity without a complete target chain.
- C received no authoritative context reload and could not read repository files.
- Provenance was encoded through referential integrity, not status cue words; commit wording was neutral.
- Five cases (K1, K5, K3, T1, T2) ran under all three conditions, three times in fresh sessions: 45 planned observations.
- Common prompts concealed condition labels and expected answers.
- Raw records, blind items, and the private mapping were separated.
- GPT, Grok, and Gemini independently rescored blind items.
- Cross-scorer comparison used conflict recognition, state classification, safe alternative, and unauthorized-state-change prevention. Inconsistently defined document-specificity and false-positive axes were excluded from the common aggregate.

One empty C/K5 observation was invalidated and replaced by a new independent C session before aggregation. The corrected bundle contained 15 observations per condition. Bundle SHA-256:

`5B20BA11487FACEF9A8F47C35DE4855C53405979BECEF368A65E8E3E1B3BAE88`

Raw transcripts, the preregistration, private mapping, and scorer outputs remain external working artifacts; they are not canonical repository state.

## 3. Results

Each condition supplied 60 judgments on the four common axes.

| Scorer | A: Success / Partial / Failure | B: Success / Partial / Failure | C: Success / Partial / Failure |
|---|---:|---:|---:|
| GPT | 57 / 3 / 0 | 60 / 0 / 0 | 21 / 15 / 24 |
| Grok | 54 / 6 / 0 | 52 / 8 / 0 | 22 / 22 / 16 |
| Gemini | 60 / 0 / 0 | 60 / 0 / 0 | 23 / 17 / 20 |

Across 180 common-axis judgments, complete three-scorer agreement was 136/180 (75.6%). Pairwise agreement was GPT–Gemini 159/180 (88.3%), Grok–Gemini 151/180 (83.9%), and GPT–Grok 142/180 (78.9%). Disagreement is retained as a limitation.

## 4. Findings

Within this repeated synthetic boundary:

1. reloaded Current State and Decision access was associated with substantially better State Departure handling than no reload;
2. valid approval provenance did not show a reproducible incremental semantic-detection advantage over matched content reload;
3. small A/B differences changed direction by scorer and no A/B failures were observed;
4. this is not statistical equivalence and does not establish interchangeability outside the tested setting;
5. the result does not negate the authorization, audit, accountability, release-control, or recovery value of governance provenance.

C differs from A/B in authoritative context availability, so its result supports the tested reload boundary, not every Runtime Binding component individually.

## 5. Limitations and Reopen Conditions

Reopen or qualify EV-006 if real work reveals departures only valid provenance catches; longer tasks, other models, or larger state sets reverse the pattern; direct Decision reload masked a provenance effect; the response contract over-constrained behavior; independent reproduction fails; or reduced governance causes audit, release, accountability, or recovery failure.

## 6. Evidence Status

EV-006 is approved as repeated exploratory evidence with explicit limitations. It supports DEC-007's provisional layer separation. It does not validate AER as a whole or change the AER Core, AER v1.0, or AETF v0.1.2.
