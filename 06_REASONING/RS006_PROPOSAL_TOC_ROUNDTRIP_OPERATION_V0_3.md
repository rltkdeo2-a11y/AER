# Reasoning Record

Reasoning ID: RS-006

Title: Proposal TOC Workbook Human Roundtrip Operation v0.3

Status: Approved

Version: 0.3.0

Created: 2026-08-03

Updated: 2026-08-03

References:

- `06_REASONING/RS005_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_3.md`
- `05_EVIDENCE/EV009_PROPOSAL_TOC_HUMAN_ROUNDTRIP_VALIDATION.md`
- `07_DECISIONS/DEC011_ADOPT_PROPOSAL_TOC_ROUNDTRIP_OPERATION_V0_3.md`
- `09_RESEARCH_LOG/SESSION_016_PROPOSAL_TOC_HUMAN_ROUNDTRIP_VALIDATION.md`
- `scripts/proposal-toc-roundtrip-v0.3/aer-toc-roundtrip-engine.mjs`

Summary:

The first human-edited Case 3 workbook confirmed that contract v0.3 can be operated as a report-only roundtrip. A subsequent implementation review reopened the broad runtime claim and corrected output-path safety, v0.1 A3 counting, v0.2 planning-target evaluation, scoped format policy, machine-scope tracking, ambiguous page budgets, invalid inputs, and formula-error gating. Runtime implementation 0.3.2 additionally provides cell-addressed human guidance. Acceptance routine 0.1.0 applies explicit human decisions to a new workbook and normalized state while preserving the original inputs, contract version 0.3.0, and the RPA release Hold.

---

## 1. Research Question

Can a human PM edit the generated workbook in an ordinary Excel 2016 environment and return it for deterministic change detection without requiring manual change logs or surrendering human control over regeneration?

## 2. Operational Input and Output

Required input:

1. the baseline normalized state compatible with contract v0.1, v0.2, or v0.3;
2. the returned workbook containing `PM_WORKSPACE`; and
3. an explicit human command to perform re-import analysis.

Output:

- a JSON change report;
- independently recalculated page-budget status;
- format, structure, and formula-integrity findings;
- local owner-field changes separated from LLM-impacting changes; and
- a release recommendation of `HOLD` or `HUMAN_CONFIRMATION_REQUIRED`;
- structured human guidance separated into required corrections, confirmations, and no-action notes; and
- display text that uses sheet names, Excel cell addresses, current values, and plain-language actions rather than internal identifiers.

The operation does not modify the input workbook or baseline state. The report path must be a distinct `.json` path. Input-path collision is rejected before import and the report is written through a temporary file before replacement.

After the human explicitly confirms detected changes, the separate acceptance operation requires:

1. the returned workbook and its prior normalized baseline;
2. an internal decision object containing the accepted existing changes and any approved split;
3. distinct output paths for the accepted workbook, accepted normalized state, and verification report.

It creates copies rather than modifying the returned workbook or prior baseline. It assigns machine identity and inherited scope internally, synchronizes `PM_WORKSPACE`, page formulas, change review, system snapshot, mapping, and draft RPA specification, then re-runs the report-only analyzer against the accepted pair.

Human-facing instructions must not ask a PM to edit `node_id`, page-budget IDs, or other machine identifiers. A typical instruction identifies an editable cell directly, states its current value, proposes a concrete replacement when one is supported, explains the reason, and states whether an alternative human allocation is acceptable. Allowed title edits are confirmations, not forced reversions. Owner-only edits are explained as requiring no action.

## 3. Identity and Change Rules

`node_id` remains the identity key. Unknown or blank identifiers are `NEW / STRUCTURAL` and receive a deterministic provisional candidate identifier in the report. A new identifier becomes canonical only through the explicit acceptance operation. The human does not enter it. Missing baseline identifiers are `DELETED`, except a missing official node is `OFFICIAL_STRUCTURE_BLOCK / BLOCK`. Duplicate identifiers are `DUPLICATE_ID / BLOCK`.

Change precedence remains:

1. official structure block;
2. parent or level change;
3. volume or page-budget scope change;
4. A3 format change;
5. physical-page change;
6. requirement-placement change;
7. title change; and
8. unchanged or local-only change.

When more than one field changes on one row, the primary material classification follows this precedence while owner, note, and human-check changes remain separately observable.

## 4. Excel 2016 Boolean Compatibility

The A3 input is a Boolean state, not a dependency on a graphical checkbox control. Excel versions may render the same field as a checkbox or as `TRUE/FALSE`.

Accepted true encodings are:

- Boolean `true`;
- `TRUE`;
- `Y` or `YES`;
- numeric or textual `1`; and
- `CHECKED`.

Accepted false encodings include Boolean `false`, `FALSE`, `N`, `NO`, numeric or textual `0`, `UNCHECKED`, and blank. An unrecognized nonblank token is `INVALID_BOOLEAN / BLOCK`. This compatibility rule changes only the editing surface interpretation and does not change an RFP's A3 permission or page-count rule.

## 5. Page and Release Rules

Every page budget is recalculated independently from known leaf rows under its source contract:

- v0.1 applies the authoritative A3 multiplier to physical sheets;
- v0.2 preserves `RFP_UNSPECIFIED` and evaluates an explicit human planning target separately from the absent RFP target; and
- v0.3 evaluates every exact or unlimited budget independently and applies a scoped A3 prohibition only to its affected volume.

Unlimited budgets remain `N/A`. A prohibited A3 selection is `FORMAT_CHANGED / BLOCK`; an allowed A3 selection uses a multiplier only when the normalized state contains an authoritative multiplier.

An exact budget is `INDETERMINATE`, never `PASS`, when page-bearing new rows lack a recognized budget, a known leaf lacks a page value, a page value is invalid, or node identity is duplicated. A changed `volume_id` or `page_budget_id` is `BUDGET_SCOPE_CHANGED / STRUCTURAL`.

The result remains `HOLD` when any of the following is present:

- a blocking change;
- a structural change; or
- an exact page budget that does not equal its target;
- an indeterminate page budget; or
- a spreadsheet formula error.

Even when these checks pass, release remains `HUMAN_CONFIRMATION_REQUIRED`. Re-import never authorizes RPA release.

## 6. Human Control Boundary

The re-import analyzer is report-only. It does not:

- regenerate a TOC;
- rewrite page assignments;
- update mappings or RPA specifications;
- accept a new external source automatically; or
- treat a detected edit as approval.

A later material update may be re-evaluated at any time. The acceptance operation runs only after explicit human confirmation, never releases RPA, and never overwrites the returned workbook or prior baseline. Content regeneration and RPA release still require separate explicit commands.

## 7. Scope and Limitations

Validated:

- one actual human-edited Case 3 workbook;
- synthetic regression across title, page, A3, owner, new-row, and official-structure changes;
- Excel 2016 Boolean A3 input;
- independent page-budget recalculation; and
- report-only operation;
- one actual human-confirmed rename and one actual human-confirmed split;
- preservation of a 5-plus-4 page split against the original 9-page allocation;
- synchronization of the accepted workbook's baseline, mapping, change-review, and draft RPA system sheets; and
- zero-change re-import of the accepted 180-row workbook against the accepted 180-row normalized state.

Not validated:

- multi-user concurrency;
- malicious workbook tampering or forensic integrity;
- graphical checkbox behavior in every Excel release;
- arbitrary workbook layouts without the contract headers;
- automatic acceptance without an explicit decision object;
- arbitrary split and merge semantics beyond the observed one-source/two-leaf split;
- PPT generation or RPA execution; and
- proposal quality or productivity improvement.

Reasoning Status:

Approved
