# Reasoning Record

Reasoning ID: RS-005

Title: Proposal TOC Workbook Contract v0.3 for Split RFP Authority and Multiple Page Budgets

Status: Approved

Version: 0.3.0

Created: 2026-08-03

Updated: 2026-08-03

References:

- `06_REASONING/RS004_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_2.md`
- `06_REASONING/contracts/proposal-toc-v0.3/proposal-toc-contract-v0.3.json`
- `06_REASONING/contracts/proposal-toc-v0.3/proposal-toc-state-v0.3.schema.json`
- `06_REASONING/contracts/proposal-toc-v0.3/case3-representative-state.json`
- `05_EVIDENCE/EV008_PROPOSAL_TOC_CONTRACT_CASE3_VALIDATION.md`
- `07_DECISIONS/DEC010_ADOPT_PROPOSAL_TOC_WORKBOOK_CONTRACT_V0_3.md`
- `09_RESEARCH_LOG/SESSION_015_PROPOSAL_TOC_WORKBOOK_CASE3_VALIDATION.md`

Summary:

Case 3 separates proposal rules and technical requirements across an RFP and task specification, creates two exact page budgets plus an unlimited appendix scope, and delegates consortium policy to a missing bid notice. Contract v0.3 adds only the source-authority and page-budget structures required to preserve those observations without turning the workbook into a general exception system.

---

## 1. Research Question

Can contract v0.2 faithfully represent a two-volume proposal whose official hierarchy, page rules, technical requirements, and consortium policy are governed by different documents and independently counted scopes?

## 2. Case 3 Observations

The RFP:

- fixes Volume 1 at A4, maximum 100 counted pages for chapters I through IV;
- makes Volume 1 chapter V appendices and evidence unlimited;
- fixes Volume 2 at A4, maximum 300 counted pages for chapters I through VI;
- excludes cover, TOC, dividers, acceptance table, and evidence as stated by the applicable rule;
- allows A4 portrait and, when unavoidable, A4 landscape, but does not authorize A3;
- prohibits company, affiliate, CI, photograph, or person-identifying content in Volume 2 and applies a seven-point penalty;
- delegates technical detail to the separate task specification; and
- delegates consortium policy to the bid notice, which was not supplied in this case.

The task specification contains 110 requirement groups across eleven categories and states that its technical requirements control when a proposal differs unless the authority accepts otherwise.

## 3. v0.2 Incompatibility

Version 0.2 has one page-constraint object and a flat source registry. It cannot represent:

1. two exact page budgets and one unlimited scope in the same proposal;
2. domain-specific authority between the RFP, task specification, and bid notice;
3. an unresolved delegated source that blocks only consortium confirmation; or
4. a Volume 2 content prohibition that must gate release.

Flattening these observations would either lose an official rule or incorrectly block all draft generation. This satisfies the v0.2 reopening condition. Versions 0.1 and 0.2 remain frozen.

## 4. v0.3 Minimum Extension

Version 0.3 adds:

- `page_budgets[]` with `RFP_EXACT`, `RFP_UNLIMITED`, and preserved `RFP_UNSPECIFIED` modes;
- `source_relationships[]` for explicit delegation;
- `source_authority_matrix[]` for domain-specific authority; and
- `content_policies[]` for scoped forbidden-content or format rules.

No general exception language, workflow engine, or automatic conflict resolver is added.

## 5. Case 3 Generation Result

The generated state and workbook contain:

- 45 official fixed nodes: 11 level-1 and 34 level-2;
- 179 total TOC rows and 134 leaf rows;
- all 110 task-specification requirement groups;
- 297 atomic review obligations and 297 MAIN mappings;
- exact initial allocations of 100 and 300 pages, calculated from leaves only;
- a visible but prohibited A3 checkbox whose selection produces Block;
- a Volume 2 anonymity gate;
- a missing-bid-notice consortium gate; and
- RPA release Hold pending human confirmation and explicit release.

## 6. Re-import Rules

Stable `node_id` remains the identity key. New rows, deletion, parent changes, level changes, page changes, format changes, requirement placement, and title changes remain observable. Owner-only changes remain excluded from LLM impact.

Page completion is evaluated independently for every budget. An unlimited budget is never treated as an exact target. A prohibited A3 selection is classified as `FORMAT_CHANGED / BLOCK`, not multiplied.

## 7. Scope and Limitation

This validates the third observed RFP pattern. It does not validate PPT generation, RPA execution, automated identity scanning, bid-notice interpretation without the source, PM productivity, proposal quality, or universal RFP coverage.

Reasoning Status:

Approved
