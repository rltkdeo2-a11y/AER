# Reasoning Record

Reasoning ID: RS-004

Title: Proposal TOC Workbook Contract v0.2 for Unspecified RFP Page Limits

Status: Approved

Version: 0.2.0

Created: 2026-08-03

Updated: 2026-08-03

References:

- `06_REASONING/RS003_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_1.md`
- `06_REASONING/contracts/proposal-toc-v0.2/proposal-toc-contract-v0.2.json`
- `06_REASONING/contracts/proposal-toc-v0.2/proposal-toc-state-v0.2.schema.json`
- `06_REASONING/contracts/proposal-toc-v0.2/case2-representative-state.json`
- `05_EVIDENCE/EV007_PROPOSAL_TOC_CONTRACT_CASE2_VALIDATION.md`
- `07_DECISIONS/DEC009_ADOPT_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_2.md`
- `09_RESEARCH_LOG/SESSION_014_PROPOSAL_TOC_WORKBOOK_CASE2_VALIDATION.md`

Summary:

Case 2 demonstrates that the Case 1 page contract is not universal. The second RFP contains no total-page limit and gives no rule that A3 counts as two pages. Contract v0.2 therefore separates an official RFP constraint from a later planning target, makes the A3 multiplier nullable, and permits TOC generation while allocation and RPA release remain Hold.

---

## 1. Research Question

Can the frozen Case 1 contract represent a proposal RFP that prohibits joint contracting, provides an official TOC, but provides neither a total-page target nor an A3 page-count multiplier?

## 2. Case 2 Observations

The RFP:

- prohibits joint contracting;
- provides six level-1 and sixteen level-2 official TOC nodes;
- requires A4 portrait as the principle but allows A4 landscape or other paper in exceptional cases;
- contains no total-page limit;
- contains no rule that A3 equals two counted pages;
- requires a requirement-to-proposal cross-reference;
- includes CSR-004 AX execution planning in the requirement table, detailed writing guide, and evaluation table, but omits it from the official TOC; and
- contains inconsistent detailed-guide labels and numbering for chapter III, item 4, and other matters.

## 3. v0.1 Incompatibility

Version 0.1 requires:

- `target_pages` as a positive integer;
- `page_rule = EXACT`; and
- `a3_multiplier = 2`.

Filling those fields for Case 2 would promote an assumption to an RFP fact. Leaving them absent would violate the v0.1 schema. This satisfies the v0.1 reopening condition that a planned case cannot be represented without semantic loss.

Version 0.1 remains frozen as the Case 1 exact-page contract. It is not rewritten.

## 4. v0.2 Page Model

Version 0.2 separates:

- `page_constraint_mode`;
- `rfp_target_pages`;
- `planning_target_pages`;
- `allocation_basis`; and
- `a3_count_multiplier`.

Two page modes are valid:

1. `RFP_EXACT`: an authoritative RFP target exists and exact allocation is enforced.
2. `RFP_UNSPECIFIED`: no authoritative total target exists and the RFP target remains null.

For `RFP_UNSPECIFIED`, TOC generation may proceed. Allocation remains Hold until an explicit planning target is supplied. That target is labeled human, LLM draft, or another non-RFP basis and must never be reported as an RFP constraint.

## 5. Page Format Rule

The A3 checkbox remains an observable human edit because page-format changes must be detected during re-import.

However, v0.2 does not multiply counted pages unless an authoritative case-specific multiplier exists. In Case 2 an A3 selection produces review because the RFP allows other paper but defines no count conversion.

## 6. Source Conflict Rule

The official TOC page is the hierarchy authority. Detailed writing guidance, requirement tables, and evaluation items supply content obligations and conflict evidence.

For Case 2:

- chapter III remains `Consulting Delivery` rather than the conflicting detailed-guide label;
- other matters remains chapter VI rather than VII;
- duplicate detailed-guide numbering is recorded rather than copied; and
- CSR-004 is placed as L3 detail below the official L2 AX roadmap node.

This preserves the fixed RFP hierarchy while preventing omission of an evaluated requirement.

## 7. Generation and Re-import Effect

The workbook preserves v0.1 stable identity, change precedence, owner exclusion, human confirmation, and explicit RPA release.

The Case 2 workbook starts with:

- proposal mode `SOLO`, derived from the RFP prohibition;
- 22 official fixed nodes;
- 65 total TOC rows;
- 43 L3 requirement rows;
- 43 atomic obligations and 43 MAIN mappings;
- blank physical-page allocations;
- blank planning target;
- allocation status `HOLD`; and
- RPA status `HOLD`.

## 8. Scope and Limitation

This result validates one additional RFP structure. It does not establish a universal page-policy taxonomy, general A3 semantics, PM productivity improvement, or PPT production readiness.

Reasoning Status:

Approved
