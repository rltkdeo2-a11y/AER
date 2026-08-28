# Research Session Log

Session ID: SESSION-022

Title: Small-Organization Knowledge Continuity MVP Checkpoint

Date Started: 2026-08-25

Checkpoint Approved: 2026-08-26

Status: Detailed research checkpoint approved; Minimum Viable Learning Product validation authorized; product value and generalization unvalidated

Research Domain: Small-organization knowledge continuity, cross-functional decision traceability, and OSS product hypothesis

Closure Mode:

Standard

Git Permission:

Autonomous Closure for an exact candidate Commit in an independent `EXECUTION` repository; canonical promotion remains owner-controlled

External Research Anchors:

- Toss Tech, `토스 프론트엔드 개발자들이 더 이상 문서를 찾지 않는 이유` (2024-11-15): https://toss.tech/article/toss-frontend-ai-docs
- Toss Tech, `2. 전문성 밖으로 나아가기` (2026-06-19): https://toss.tech/article/technical-writing-2
- Consortium for Service Innovation, Knowledge-Centered Service / Knowledge-Centered Success library: https://library.serviceinnovation.org/KCS/
- W3C PROV-O: https://www.w3.org/TR/prov-o/

---

## 1. Checkpoint Purpose and Sufficiency Contract

This object preserves the recoverable reasoning state of a long exploratory discussion. It is deliberately more detailed than a closure summary because its purpose is to let a later AER-bound session resume without repeating the discovery path or silently restoring rejected product directions.

The checkpoint is sufficient only if a future researcher can determine from repository authority and this object, without the source conversation:

- the real-world observation that initiated the research;
- why the problem is broader than document storage or project management;
- what the Toss cases contributed and what they did not establish;
- why Jira, Confluence, Obsidian, a small KMS, a PMS, NAS search, and generic RAG were not accepted as the product definition;
- what prior methods and OSS components already cover;
- what candidate control-layer gap remains;
- which propositions are observations, working hypotheses, decisions, assumptions, Holds, rejected paths, or open problems;
- what the MVP must test and what would falsify the current direction; and
- the exact first action of the next research stage.

This is not a verbatim transcript. Repetition and conversational wording are omitted, but path-dependent corrections, negative knowledge, limitations, and reopening conditions are preserved because losing them would make the checkpoint itself a future bottleneck.

---

## 2. Originating Observation

The research began after the human researcher interviewed for a PM role at a new company. The human asked whether management artifacts from prior projects had been preserved, managed, and remained available for reference. The company answered that artifacts remained, but it was not known what had been used, whether everything existed, or how the materials related to prior work. The company intended to introduce Jira and Confluence and noted that well-managed documentation was uncommon.

This interview was not treated as evidence against Jira or Confluence. It exposed a wider concern: introducing a project and documentation tool may improve storage discipline, but it does not by itself reconstruct what judgments were made, why they changed, which organizational functions affected them, what remains valid, and how the result should guide later work.

The human connected this observation to repeated experience in organizations of roughly 50 people or fewer:

- document management was often weak before knowledge management was considered;
- project artifacts and organizational judgments were fragmented across local files, shared storage, messages, and individuals;
- important context remained in the memory of key personnel;
- when a key person left, not only a record but sometimes the organization's practical capability in that area disappeared; and
- systems requiring unfamiliar work habits could become an additional burden, especially for non-development roles.

These are bounded human observations. They have not been established as population-level facts about all small organizations, and no market-frequency or economic-loss study has yet been performed.

---

## 3. Research Reset and Current Problem Definition

The discussion initially produced many solution ideas and repeatedly drifted toward product forms that the human then had to challenge. To reduce that cognitive burden and prevent the solution from hardening outside the human's reviewable understanding, the research was explicitly reset around the following proposition:

> We observe loss of work knowledge and decision context when people and roles change in small organizations. The Toss cases indicate that this is connected not only to tool absence but also to authoring burden, validity, responsibility, and governance. It remains unverified whether a separate OSS product is necessary or what cannot be solved by existing wiki, Obsidian, search, and operating methods.

The research then separated two questions that must not be collapsed:

1. What functions can be assembled or implemented?
2. Does the resulting connection of functions resolve a meaningful problem better than existing alternatives?

The existence of mature individual features does not end product inquiry. New products may arise from a better connection, placement, interaction, or operating model among existing functions. Conversely, assembling existing features does not by itself establish a product edge.

The current problem definition is therefore:

> When people, roles, projects, and organizational boundaries change, how can an organization preserve and reuse not only files but also the reasons for decisions, their changes, cross-functional effects, current validity, and follow-up responsibility, without requiring every worker to adopt a heavy new documentation practice?

The intended boundary is organization-wide. Development work is one possible source domain, not the conceptual center.

---

## 4. What the Toss Cases Contributed

### 4.1 2024 frontend case

The 2024 Toss Tech article describes a developer-facing path:

- developers often preferred asking a colleague over navigating producer-structured documentation;
- a RAG-based tool placed question answering in IDE and internal-messenger contexts and returned source-grounded answers;
- a messenger bot summarized useful discussion threads and opened documentation pull requests; and
- documentation was created closer to the moment knowledge was exchanged instead of as a separate writing task.

The important lesson was not that an IDE chatbot should be copied. The case showed that knowledge access and knowledge capture can be placed inside existing behavior rather than requiring users to visit and operate a separate repository.

### 4.2 2026 organization-wide knowledge-system case

The 2026 Toss Tech article reports a broader internal knowledge platform and identifies several problems in prior arrangements:

- repository and pull-request workflows were barriers for some non-development roles;
- stale, unfinished, or contextless material accumulated in existing documentation tools;
- knowledge was fragmented across static sites, document tools, code, internal messages, and individual memory;
- easier authoring increased the separate problem of maintaining quality;
- even improved authoring still depended on someone deciding to write; and
- the organization was working toward automatic documentation and updating from code changes, decisions, and discussions.

The article explicitly frames the difficult middle stage as determining what is still valid knowledge, including recency, actual use, and consistency between policy and implemented code. It also describes moving the professional judgment of technical writers into system rules so that specialists can eventually leave routine maintenance behind.

### 4.3 Accepted transfer and explicit boundary

The accepted transfer from the Toss cases is:

- reduce separate authoring intent;
- capture useful traces in the flow of work;
- distinguish accumulation from valid knowledge;
- connect documentation to actual use and updating;
- put professional review criteria into a repeatable system; and
- deliver knowledge where work occurs.

The following were not established:

- that Toss's internal implementation can be copied into a small organization;
- the exact algorithm or governance by which Toss determines validity;
- that the reported internal usage metrics imply external product demand;
- that a centralized SSoT is always preferable to source-retaining federation; or
- that organizations without Toss's specialist staff, technical infrastructure, or work ethic can obtain the same outcome.

The Toss cases are a strong design anchor and prior organizational case, not direct validation of the current OSS hypothesis.

---

## 5. Required Cross-Functional Outcome

The human expressed the desired outcome through an A-to-B project-handoff scenario.

An employee joins after project A and becomes responsible for project B, which follows from A. The prior owner has left. The employee should be able to ask:

> What happened in project A, how and why did it lead to project B, what remains valid, and what work should I perform next in sequence?

A sufficient answer cannot rely only on the former project manager's records. It may need to include:

- a sales change to contracted scope;
- a finance record of increased or reduced project cost following a date change;
- an operations constraint that changed delivery or support responsibility;
- a design, R&D, or technical decision and its rationale;
- a meeting decision and the later action or implementation that confirmed or superseded it;
- an unresolved conflict or missing approval; and
- the present owner or role responsible for the next action.

The product value, if it exists, is not only onboarding. It is continuity of organizational judgment and execution across functions without repeatedly locating people, visiting departments, or reconstructing decisions by oral relay.

Meeting-minute-based routing of work to stakeholders was considered a plausible downstream application. It is not yet adopted as an MVP requirement because automated minutes, action extraction, responsibility assignment, and organizational authority introduce separate validation problems.

---

## 6. Directional Drift and Corrections Preserved

### 6.1 Development-project and PMS drift

Because the Toss examples and many available tools are development-centered, the discussion repeatedly narrowed into project artifacts, tickets, and developer workflows. The human identified the resulting failure test: if a person introducing Jira and Confluence can reasonably respond, "Should we not first operate the management system we already planned?", then the new concept has not yet established a distinct problem or value.

Correction:

- project sequence is one test shape;
- the product hypothesis must represent cross-functional organizational judgment;
- it must not become a weaker Jira, Confluence, or PMS; and
- SI is an initial adversarial fixture because it has rich changes and formal artifacts, not because development projects define the product.

### 6.2 Small KMS or wiki drift

An OSS that indexes a directory and offers search, pages, or extension points risks becoming "a small KMS that users must operate themselves." That returns responsibility to the organization to write, classify, update, and govern material consistently.

Correction:

- the core must participate in the knowledge lifecycle;
- it must surface evidence changes, conflicts, stale claims, reuse, and gaps;
- it should request bounded review rather than require document rewriting; and
- storage and editing are replaceable surrounding capabilities, not the product center.

### 6.3 Obsidian and personal-wiki equivalence

Obsidian-like systems can link files and support personal or team knowledge organization. The unresolved organizational problem is different when it requires source authority, role-based validation, lifecycle changes, cross-functional access, and responsibility for superseding or holding claims.

Correction:

- backlinks or a knowledge graph are not sufficient differentiation;
- the candidate value lies in governed transition and use, not visual linkage alone.

### 6.4 Generic RAG drift

RAG can retrieve relevant passages and generate source-linked answers. A baseline RAG does not necessarily determine whether a source was superseded, whether a claim is an unapproved inference, whether combined sources may be disclosed to the requester, or which downstream conclusions must be reviewed when a source changes.

Correction:

- search quality remains useful but subordinate;
- retrieval must operate after source and claim access filtering;
- answers must disclose state and uncertainty; and
- source changes must produce review work, not only re-indexing.

### 6.5 Governance regression

The discussion recognized that very small organizations may have informal roles, weak work discipline, inconsistent storage, and ad hoc decisions. No software can infer legitimate authority from chaos without assumptions.

Correction:

- lightweight governance is part of the problem, not an external condition assumed to exist;
- the MVP may use explicit synthetic roles and authority to test mechanics;
- actual organizational policy discovery and adoption remain future work; and
- automation must not conceal missing ownership or ambiguous authority.

---

## 7. Prior Methods and Novelty Boundary

Knowledge-Centered Service / Knowledge-Centered Success already describes mature ideas such as creating and improving knowledge in the workflow, reuse as review, and lifecycle states. This weakens any claim that the general knowledge-loop method is new.

The research therefore does not claim novelty in:

- capturing knowledge while solving work;
- improving knowledge through reuse;
- assigning lifecycle or validation states;
- using RAG to answer from documents;
- representing provenance; or
- connecting existing tools through automation.

KCS naming, current guide licensing, and trademark conditions must also be reviewed before copying terms, templates, or branding into an OSS product.

The remaining working edge candidate is narrower:

> Can a small, source-retaining control layer make provenance, authority, validity, access, change impact, reuse, and knowledge gaps operational for small organizations without dedicated knowledge-management specialists and without becoming another heavy authoring or project-management tool?

This is a product-integration and operating hypothesis, not an approved novelty claim.

---

## 8. OSS Reuse and Build Boundary

The preliminary OSS review supports a single deployable core rather than a new stack of search, editing, parsing, identity, graph, and workflow products.

### Reuse directly or as standards

- PostgreSQL: durable relational store and row-level access-policy foundation.
- pgvector: optional semantic retrieval inside PostgreSQL; not truth authority.
- W3C PROV subset: vocabulary for entity, activity, agent, derivation, attribution, generation, revision, and invalidation relations.
- CloudEvents: common envelope for source-change, review, validation, reuse, and invalidation events.
- REST and MCP: interfaces for applications and AI clients.

### Connect as replaceable adapters

- Docling: document parsing, OCR, table extraction, and unified document representation.
- Apache Tika: broad text and metadata extraction fallback.
- Onyx: optional adapter for organizations already operating its search or RAG stack.
- BookStack or another wiki: optional publishing target.
- n8n or Automatisch: user-managed external workflow connection through Webhooks, not a required embedded core.

### Build as the candidate core

- evidence registry with source locator, version, hash, access snapshot, and extraction state;
- claim ledger with evidence links and direct/inferred/approved distinction;
- authority and lifecycle transition rules;
- source-bound effective visibility;
- dependency invalidation and review routing;
- reuse, correction, and knowledge-gap event semantics; and
- a minimal review inbox for approve, correct, hold, supersede, or reject.

### Exclude from the initial core

- wiki or rich-document editor;
- PMS, ticket, schedule, or kanban management;
- OCR engine or vector database implementation;
- separate graph database;
- full identity provider;
- messenger or meeting-recording bot;
- visual workflow designer; and
- universal connector catalogue.

License findings are preliminary engineering screening, not legal advice. Model licenses, data egress, source-available restrictions, copyleft boundaries, enterprise-only permission features, and dependency license changes require separate review before release.

---

## 9. Current Product Working Hypothesis

The minimum conceptual flow is:

```text
existing source systems
→ source-specific capture and extraction
→ evidence registry
→ claim ledger
→ authority, lifecycle, access, and dependency evaluation
→ review, correction, reuse, and gap events
→ source-grounded answers, handoff, and next-work guidance
```

Existing tools remain authoritative sources for their own records. The control layer does not silently replace them with an AI-generated canonical copy.

### Evidence registry

Each source reference should preserve enough information to determine:

- where the source came from;
- which version was examined;
- whether the content or permissions changed;
- when the source was last synchronized;
- whether the source remains reachable; and
- which extracted claims depend on it.

### Claim ledger

The atomic managed unit is a claim such as:

- "The contracted scope includes the added integration interface."
- "The delivery date moved by two weeks."
- "The date change increased the approved business cost."
- "Project B was initiated because project A left a validated residual requirement."

A claim must distinguish source statement, system inference, and human-approved judgment. The ledger should not imply that every sentence must be manually authored or reviewed independently; the useful granularity remains an MVP question.

### Lifecycle and dependency

Candidate states include unvalidated, validated, held, superseded, and archived. Exact names and transitions are not yet fixed. A source update should identify dependent claims and outputs that require review. It must not automatically convert a newer file into true knowledge merely because its timestamp is later.

### Interaction

The user-facing burden should be bounded review rather than routine rewriting. The minimal review action is approve, correct, hold, supersede, reject, or assign responsibility. Whether this is sufficiently lighter than existing documentation work is an empirical MVP question.

---

## 10. Validity and Authority: The Central Unresolved Layer

The diagrammatic sequence `work → accumulate → update → use` compresses the most difficult transition into "determine valid knowledge." This middle layer is central to the hypothesis.

An LLM must not become the unreviewed authority that declares organizational truth. Initial validity evaluation requires at least:

- evidence identity and version;
- direct statement versus derived inference;
- effective date and supersession;
- responsible role or authority;
- conflict state;
- actual implementation or use evidence when applicable;
- review history; and
- explicit uncertainty or missing information.

The exact criteria vary by domain. A signed contract amendment, a finance approval, a meeting decision, a deployed code change, and a working-level message do not have the same authority. The MVP should encode a bounded synthetic policy, not pretend to discover a universal hierarchy.

Unknown or stale authority must remain visible. `HOLD` is a valid result when:

- sources conflict without an authorized resolution;
- the responsible role is absent;
- an approval cannot be found;
- the source was deleted, moved, or changed without reprocessing;
- the access-control snapshot is stale; or
- a derived claim exceeds the evidence.

---

## 11. Access-Control Safety Invariant

The initial safety invariant is:

> A derived claim or generated answer must not be visible more broadly than any supporting source.

When a claim combines sources with different permissions, effective visibility is initially the intersection, not the union. Retrieval and generation must filter inaccessible evidence and claims before answer composition, not remove sensitive citations after generation.

If an adapter cannot confirm permission freshness, sensitive dependent claims should be denied or held rather than exposed under an optimistic assumption.

This invariant is an approved safety direction for the MVP. It is not a complete enterprise authorization model and has not been validated against every source system.

---

## 12. Decision to Proceed Through an MVP

The human approved proceeding to an MVP rather than continuing indefinite conceptual revalidation.

MVP means `Minimum Viable Learning Product` in this session. It is a falsification instrument, not a reduced commercial release.

The single primary question is:

> Does explicit management of evidence, claim state, authority, access, and change impact produce a materially more correct, traceable, and safe A-to-B project handoff than file search or baseline RAG?

The first bounded scenario is:

- project A precedes project B;
- the former owner is unavailable;
- relevant records span project, sales, finance, and operations;
- some sources conflict or were superseded;
- some conclusions are inferential;
- some records have restricted access; and
- the new owner asks what happened, why B exists, what remains valid, and what to do next.

### Minimum included capability

- ingest a bounded folder containing PDF, DOCX, XLSX, image, and Markdown fixtures;
- record file identity, version or hash, source locator, and synthetic access policy;
- extract evidence and candidate claims;
- distinguish direct evidence, inference, and approved judgment;
- approve, correct, hold, supersede, and reject through a minimal review path;
- answer the handoff question with claim-level evidence and status;
- prevent unauthorized claim or source disclosure; and
- invalidate dependent claims or outputs after a source change.

### Explicitly excluded capability

- polished organization-wide UX;
- real Jira, Confluence, email, Slack, or NAS deployment;
- full meeting transcription and action routing;
- production identity integration;
- universal domain ontology;
- project planning or ticket execution;
- autonomous organizational decision making; and
- product-market-fit claims.

---

## 13. Synthetic Case Strategy and Independence

The synthetic case is a first-stage test harness, not final evidence of need or adoption.

The case package must separate:

```text
source_documents/       inputs visible to the MVP
evaluation_questions/   questions visible to the implementer
ground_truth/           hidden event, validity, and dependency ledger
access_matrix/          role-based disclosure conditions
```

Generation and validation roles should be separated:

- case generator creates a structured event ledger and source documents;
- adversarial mutator introduces bounded conflicts, omissions, version changes, ambiguous wording, and permission differences;
- case auditor checks that intended truths and contradictions are internally consistent;
- MVP implementer receives no hidden ground truth; and
- evaluator compares outputs with the frozen ledger and access matrix.

Free external models may be used as constrained document drafters. They must not be sole authorities for dates, amounts, dependencies, or expected answers. Dates, amounts, version chains, cross-document references, and permissions should be generated from or checked against structured data and deterministic consistency rules.

The first SI fixture should remain bounded enough to test the control loop rather than parser scale. The working target is approximately 20–40 documents, 3–5 organizational roles, two connected projects, and roughly ten material decisions. These numbers are design guidance, not approved universal thresholds.

If the SI gate passes, structurally different R&D and sales/finance/operations cases should test whether the system overfits development artifacts and vocabulary.

---

## 14. MVP Success, Failure, and Stop Rules

### Required success behaviors

The MVP must demonstrate that it can:

- reconstruct the material A-to-B causal and temporal path;
- include cross-functional contractual, financial, operational, and project effects;
- trace every material answer claim to accessible evidence;
- distinguish source fact, inference, approved judgment, and unresolved state;
- avoid presenting superseded or expired information as current;
- detect intended conflicts and missing authority;
- withhold restricted facts and avoid indirect disclosure through derived claims;
- route source changes to dependent claims and outputs for review;
- support correction without requiring a reviewer to rewrite a complete document; and
- state when the available evidence cannot answer the question.

### Comparative requirement

The same fixture and questions must be run against at least:

- ordinary file or keyword search; and
- a baseline source-citing RAG configuration.

The control-layer hypothesis is not supported merely because the MVP generates a plausible narrative. It must show material advantage in validity, traceability, permission safety, or change handling attributable to the candidate core.

### Failure or reduction conditions

Reduce, revise, or stop the current product hypothesis when:

- baseline RAG resolves the handoff with equivalent correctness and safety without the additional control layer;
- claim-level review creates more burden than the avoided reconstruction work;
- valid claim granularity cannot be represented without extensive domain-specific modeling;
- permission and source synchronization cannot be made safe within a small-organization operating envelope;
- source change produces excessive or unusable review cascades;
- the benefit appears only in development-heavy SI artifacts; or
- the system still depends on disciplined manual documentation equivalent to the original bottleneck.

### Evidence boundary

Passing synthetic tests establishes bounded functional behavior only. It does not establish actual organizational recurrence, market demand, usability, cost effectiveness, governance adoption, long-term maintainability, or causal business improvement.

---

## 15. Current State Classification

| Type | Current proposition | Status |
|---|---|---|
| Observation | Important artifacts and decision context can remain fragmented or become unusable when key personnel leave small organizations. | Human-observed; broader recurrence unvalidated |
| Observation | Tool-adoption burden differs by role and can inhibit use. | Human-observed; magnitude unmeasured |
| External case | Toss reports workflow-embedded access, capture, updating, and validity work across multiple organizational knowledge sources. | Verified article content; external transfer unvalidated |
| Working Hypothesis | A source-retaining knowledge-control layer can improve cross-functional continuity. | Active, unvalidated |
| Working Hypothesis | Claim-level provenance and lifecycle control add value beyond baseline RAG. | Primary MVP hypothesis |
| Decision | Proceed to a bounded Minimum Viable Learning Product. | Human approved |
| Decision | Separate case generation, audit, implementation, and evaluation. | Human approved |
| Decision | Begin with SI, then test R&D and sales/finance/operations if the first gate passes. | Human approved as research sequence |
| Safety Direction | Derived visibility cannot exceed supporting-source visibility; use permission intersection and deny/HOLD on unknown freshness. | Approved for MVP; not a complete authorization model |
| Rejected Product Definition | Small wiki/KMS, PMS/Jira replacement, NAS search tool, Obsidian clone, or generic RAG wrapper. | Not adopted |
| Assumption | Small organizations will accept bounded review if separate authoring burden is reduced. | Unvalidated |
| Assumption | Source connectors can recover sufficiently reliable versions and permissions. | Unvalidated |
| HOLD | Meeting-derived automatic stakeholder work routing. | Future application; outside MVP |
| HOLD | Actual-company PoC and AX consulting packaging. | Requires synthetic MVP gate and separate authorization |
| Open Problem | Exact validity authority, lifecycle policy, claim granularity, and review responsibility. | Must be bounded in the fixture, not generalized |
| Open Problem | Independent edge over configured existing-tool combinations. | Must be tested comparatively |

---

## 16. Active Reasoning State

### Current objective

Create and execute a bounded comparative MVP test of the knowledge-control-layer hypothesis without converting the hypothesis into an approved product claim.

### Official baseline

- AER v1.0 and AETF v0.1.2 remain unchanged.
- AER Core and existing Runtime selection remain unchanged.
- Existing Production Layer and PPT RPA Holds remain unchanged.
- Existing Runtime priority and AX conclusions remain unchanged.
- This is a new research scope recorded as a repository-wide Session checkpoint, not an AER Core extension.

### Confirmed discussion conclusions

- The research target is cross-functional organizational continuity, not development project management.
- Existing tools remain source systems; the candidate layer coordinates evidence and knowledge state above them.
- Validity, authority, permissions, and change impact are central rather than optional enhancements.
- The next justified action is a falsifiable MVP, not further unconstrained product ideation.

### Assumptions and unknowns

- recurrence, value, usability, governance fit, and market need remain unknown;
- exact schemas and policies remain mutable within the MVP boundary;
- OSS integration feasibility is preliminary; and
- synthetic evidence cannot close real-organization claims.

### Open question

Does the smallest control layer produce material comparative value over search and baseline RAG on a frozen, adversarial, cross-functional handoff fixture?

### Mutable scope

- fixture schema and size;
- claim representation;
- bounded synthetic roles and policy;
- minimal storage, extraction, review, and query implementation; and
- evaluation rubric details that preserve the approved success and failure semantics.

### Stop or reopening conditions

- Do not reopen rejected product forms without new evidence showing the control-layer boundary is unnecessary or wrong.
- Reopen the problem definition if evidence shows the primary loss is not judgment continuity or if the proposed review burden reproduces the original authoring bottleneck.
- Stop product strengthening when comparative evidence is absent or negative.
- Do not infer actual organizational effectiveness from synthetic PASS.

### Progress pointer

The conceptual exploration and preliminary OSS mapping are checkpointed. The next work item is not implementation. It is to define and freeze the external synthetic-case generation and audit contract, then create the SI fixture outside the implementation context.

---

## 17. Next-Session Resumption Contract

A next session must begin by reading:

- `AGENTS.md`;
- `BOOTSTRAP.md`;
- `00_GOVERNANCE/CURRENT_STATE`;
- this SESSION-022 object; and
- the applicable approved Handoff for its specific stage.

The next session should classify its scope as one of:

### Case-specification session

Produce the schema, artifact inventory, ground-truth contract, access matrix, mutation rules, audit checks, and evaluation questions. Do not implement the MVP and do not expose hidden answers to a later implementer.

### Case-generation session

Generate source documents from the frozen structured ledger. Do not change product architecture or success criteria to accommodate generation convenience.

### Case-audit session

Inspect both sources and hidden truth for unintended contradictions, trivial clues, impossible authority, and inconsistent dates or amounts. Do not implement the MVP.

### MVP-implementation session

Receive only approved visible inputs. Do not read hidden ground truth, weaken permission tests, expand into a wiki or PMS, or treat plausible narrative generation as success.

### Evaluation session

Compare outputs with frozen ground truth, access policy, and baselines. Preserve negative results and apply the failure or reduction conditions in this object.

The immediate next session should be the case-specification session unless the human explicitly selects another approved stage.

---

## 18. Explicit Non-Effects

This checkpoint does not:

- create a new Principle, Decision, or Evidence object;
- claim a novel method or product edge;
- approve implementation architecture beyond the bounded MVP hypothesis;
- change AER Core or AER Runtime;
- change the repository's current priority;
- release any existing Hold;
- change AER v1.0 or AETF v0.1.2;
- establish a commercial, legal, licensing, privacy, or security conclusion; or
- authorize canonical promotion or Push from an Agent execution environment.

Further research must preserve this boundary until new evidence is explicitly classified and approved.

---

## 19. Successive Checkpoints / Addendum

This is an append-only reconciliation of successive state transitions within `SESSION-022`. Sections 1–18 and their original wording and historical status are preserved. The entries below do not rewrite an earlier checkpoint when a later result became available.

The checkpoint occurrence dates below are taken from the available approved or external working records. Where an exact approval time is not preserved, only the recorded date is used. The reconciliation record was prepared in an independent `EXECUTION` candidate on 2026-08-28; it is not canonical until an owner-controlled promotion.

### 19.1 Minimum Learning PRD Closure

Checkpoint occurrence and approval: `2026-08-27` (external PRD-closure working record; non-canonical).

State at this transition:

- Minimum Learning PRD: `CLOSED`.
- Evaluation Contract / Validation Design: next stage; not yet closed at this transition.
- Final Pre-Blind Fixture v0.3 and R2 Targeted Re-Audit: not yet claimed as complete at this transition.
- Minimum Learning MVP implementation and non-blind technical validation: not yet claimed.
- Product value, comparative advantage, organizational effectiveness, and production readiness: unvalidated.

Boundary preserved at this transition:

- The PRD fixed the smallest falsifiable product hypothesis and G5-1–G5-9 scope.
- It did not authorize implementation before the evaluation contract was frozen.
- It did not create a Decision or Evidence object, alter AER Core, or authorize canonical promotion.

### 19.2 Evaluation Contract / Validation Design Closure

Checkpoint occurrence and approval: `2026-08-27` (current-session closure materials; exact wall-clock approval time is not preserved in repository authority).

State at this transition:

- Minimum Learning PRD: `CLOSED`.
- Evaluation Contract / Validation Design: `CLOSED`.
- B0 baseline, Critical Gates A–D, sealed truth, Task 1–3, Change Pulse, observation order, human-cost boundary, Task × Condition isolation, External New-PM contract, and verdict operationalization: fixed for subsequent apparatus work.
- Final Pre-Blind Fixture v0.3 and R2 Targeted Re-Audit: still pending completion at this transition.
- `PRE-BLIND CONTRACT READY`: `NO` until the targeted re-audit passed.
- MVP implementation and product validation: not claimed.

Boundary preserved at this transition:

- The contract froze the comparison and anti-tuning rules; it did not authorize changing fixture, truth, gates, baseline, cost calculation, or verdict rules to improve a later result.
- No blind execution was authorized, and no Decision or Evidence object was created.

### 19.3 Final Pre-Blind Fixture v0.3 and R2 Targeted Re-Audit PASS

Checkpoint occurrence and approval: `2026-08-27` (v0.3 audit and readiness records; exact approval wall-clock time is not preserved in repository authority).

State at this transition:

- Minimum Learning PRD: `CLOSED`.
- Evaluation Contract / Validation Design: `CLOSED`.
- Final Pre-Blind Fixture: `v0.3`.
- R2 Targeted Re-Audit: `PASS`.
- `PRE-BLIND CONTRACT READY`: `YES`.
- MVP implementation: not yet claimed as implemented in this transition.
- `RUN CONFIGURATION FREEZE`: not yet released; blind execution remained prohibited until the implementation and configuration were complete and symmetric.
- `BLIND EXECUTION READY`: `NO`.

Boundary preserved at this transition:

- R2 PASS confirms the targeted v0.3 control checks and protected invariants; it is not a product verdict.
- The fixture, sealed truth, gates, baseline, change-pulse contents, human-cost boundary, and verdict operationalization were not redesigned for Product advantage.
- No blind evaluation was run.

### 19.4 Minimum Learning MVP Implementation and Non-Blind Technical Validation PASS

Checkpoint occurrence and validation window: `2026-08-27`; checkpoint approval and technical-validation record: `2026-08-28` (independent external working record; non-canonical).

State at this transition:

- Minimum Learning PRD: `CLOSED`.
- Evaluation Contract / Validation Design: `CLOSED`.
- Final Pre-Blind Fixture: `v0.3`.
- R2 Targeted Re-Audit: `PASS`.
- `PRE-BLIND CONTRACT READY`: `YES`.
- Minimum Learning MVP IMPLEMENTATION: `PROVISIONAL CLOSED`.
- NON-BLIND TECHNICAL VALIDATION: `PASS`.
- `RUN CONFIGURATION FREEZE`: `HOLD`.
- `BLIND EXECUTION READY`: `NO`.

Technical-validation boundary:

- The implementation is a SQLite persistent minimum control state using only `source → statement → relation`, `revision`, and operation log structures.
- Unit tests and the v0.3 Public Run and Change Pulse mechanics passed the recorded non-blind checks without opening sealed truth and without running blind evaluation.
- The implementation and its `RUN_CONFIGURATION.json` remain external working artifacts in an independent candidate workspace. They are not canonical repository assets and are not promoted by this research-state reconciliation.
- This transition does not claim product validation, comparative superiority, organizational effectiveness, market demand, or production readiness.

### 19.5 Addendum Authority and Non-Effects

- These four entries are successive checkpoints of `SESSION-022`, not new repository-wide Sessions.
- The pre-existing `62a71fcd...` candidate and `SESSION_023...` file are not canonical sources, are not copied into this record, and are not promoted.
- This addendum synchronizes already approved research state; it does not create a Principle, Decision, or Evidence object, change AER Core, release an existing Hold, or authorize blind execution.
- The final current state is maintained in `00_GOVERNANCE/CURRENT_STATE`; this Session retains the historical sequence and contemporaneous boundaries.

### 19.6 Pre-Blind Execution Freeze Checkpoint

Checkpoint occurrence and corrected freeze timestamp: `2026-08-28T03:08:01.333+09:00`.

Apparatus incident and bounded reopening:

- The five frozen Product file hashes matched their prior identities `5/5`; Product content was unchanged.
- The prior Product aggregate identity `3a1946974bbe05da4261e74152b64ea1d46fa25f3343ba4cc6049bf9c909689b` was not reproducible under the declared aggregate algorithm.
- The prior freeze at `2026-08-28T02:38:50.133+09:00`, raw configuration SHA-256 `c2d166321233f63ad30e9d6a5a602e8b717876d087e242be36a4b4053b94f071`, and normalized digest `caf7ae157b9d4928e4b83ac03b78b942531e619e728e53cc115f8e6a8f4bb102` are retained as an invalidated pre-freeze attempt with status `INVALIDATED_BY_HASH_IDENTITY_CORRECTION`.
- Reopening was limited to the Product aggregate identity, dependent configuration hashes, and freeze timestamp/status metadata. Product code/content, fixture, sealed truth, Evaluation Contract, Observation package content, model, tools, limits, condition boundary, and human-cost contract were not reopened.
- B0/Product symmetry was revalidated rather than redesigned because the Product content and execution-condition differences did not change.

State at this transition:

- Product content: `UNCHANGED`.
- Product file hashes: `5/5 PASS`.
- Corrected Product content SHA-256: `7d17b7dc8113a51ed00424f61c50c7b771a3dfb80a36d03e1ead1581032ccd7c`.
- `RUN CONFIGURATION FREEZE`: `PASS`.
- `B0 / PRODUCT SYMMETRY CHECK`: `PASS`.
- `BLIND EXECUTION READY`: `YES`.
- JSON unresolved values: `0`.
- No blind evaluation was run.

Frozen execution authority:

- Final configuration: `scripts/minimum-learning-mvp/RUN_CONFIGURATION.json`.
- Configuration raw SHA-256: `b8402f23aa4a9f38e80708983cb3bd95b625a0ab4cac85201f6ae99108d9258f`.
- Configuration normalized digest: `15f2fb8fae63f78e5c3f728e679f2ba4b6a62c14f6694b808b0721f680b28592`.
- Observation workspace/package generation logic: `scripts/minimum-learning-evaluation/observation_workspace.py`, SHA-256 `8ba1b794da3d9395ad03ab85e41fdfe77ce24dcda24456044251e722ded73462`.
- Frozen execution artifact manifest: `scripts/minimum-learning-evaluation/FROZEN_EXECUTION_ARTIFACT_MANIFEST.json`, SHA-256 `cbbd3fca3a31e3404eeb9301cab7f7e151a227170f66cb4fb641945630e4453d`.
- Observation package manifest: `scripts/minimum-learning-evaluation/frozen-observation-distribution-v0.3/OBSERVATION_PACKAGE_MANIFEST.json`, SHA-256 `5274e03e31be26fc0fca9ccf538baea9cd020b5dbe1ffcf84d916f4ad8367d1c`.
- Observation distribution sidecar: `scripts/minimum-learning-evaluation/frozen-observation-distribution-v0.3/OBSERVATION_DISTRIBUTION_SHA256.txt`, SHA-256 `546b627199e5714a94b6c21b7532965692a6d7e80da3071c91a6fa1940388cd6`.
- Public Run package SHA-256: `1d6c0f5bbd167c1865546a8fc40223a074113ad8f69d6284ffe3bf5ac56055b6`; Change Pulse package SHA-256: `d9ecd2cf2001d5fd0bd839fc3799560691268ae8e736112b3ec6ba82bd98c6b6`.
- Contract/manifest hashes: `10/10` match the corrected frozen configuration.

Artifact preservation decision:

- The ten exact Observation distribution ZIP files total only `135552` bytes.
- AER governance defines the candidate Git Commit, its validation manifest, and verified exact-object transport as the promotion authority, but does not establish a repository-governed immutable external store for these execution archives.
- The generator, cryptographic manifests, sidecar, and ten exact ZIP files are therefore preserved directly in the candidate Git object. No non-portable external local path is introduced as canonical authority.

Freeze boundary and non-effects:

- The authorized next step is `Blind Observation Execution` under the corrected frozen apparatus.
- Performance improvements or changes intended to improve PASS probability remain prohibited after this freeze.
- This checkpoint does not claim Product performance, comparative advantage, organizational effectiveness, market demand, or production readiness.
- This checkpoint creates no new Session, Principle, Decision, Evidence object, evaluation Gate, or blind result.

### 19.7 Product Definition, Initial Market, and Project Continuity Checkpoint

Checkpoint occurrence and human approval: `2026-08-29T05:30:18.165+09:00`.

State classification relative to the earlier `SESSION-022` working hypothesis:

- `REVISE` — the current product and market focus is narrowed from a broad cross-functional knowledge-control-layer hypothesis to a first market wedge in development-team project continuity.
- `CONTINUE` — the repository-wide Session identity, source-retaining boundary, existing-system authority, unvalidated product status, and falsification-first research discipline remain unchanged.
- This refinement does not reopen the rejected PMS/Jira-replacement path. AER may become part of a project-management environment while continuing not to perform project management.
- This refinement does not alter the frozen apparatus or execution authority recorded in 19.6 and does not assert that blind execution occurred or that the Product passed any comparative gate.

#### 19.7.1 Approved Current Product Definition

The current product working definition is:

> **AER is a lightweight project continuity tool for development organizations with frequent personnel change. It connects work traces already distributed across Jira, Slack, Confluence, GitHub, and similar systems so that a project does not have to reconstruct its context from the beginning whenever a person changes.**

The shorter category statement is:

> **Jira manages project execution state; AER keeps project memory and continuity from leaving with a person.**

The durable product boundary behind those statements is:

- existing work systems remain the systems of record and retain their original authority, provenance, permissions, and locations;
- AER does not replace Jira, Slack, Confluence, GitHub, a PMS, a KMS, a wiki, a document store, or an enterprise search product;
- AER does not plan schedules or WBS, assign issues, track sprint progress, manage resources, or manage project cost;
- AER does not claim to recover knowledge that was never recorded; its realistic input boundary is work context already left as digital traces but not connected into a usable sequence;
- the product value is not accumulation or persistent state by itself. Internal state, graphs, RAG, or adapters are mechanisms only when they produce a user-visible continuity benefit;
- a generic multi-source search or connector collection is not the product. The candidate value is the meaning across sources: why work arose, what changed, what is currently valid, what evidence supports that state, and what a successor should understand first;
- the user should not have to perform a separate knowledge-management job for AER. The intended operating pattern is `connect → continue normal work → receive value when context must be recovered`.

The product is therefore not defined by one LLM vendor. AER owns the work-context structure and judgment boundary; a cloud, local, on-premises, or enterprise-internal model may be a replaceable inference engine. Different engines may support different capability profiles, and model substitution does not imply equal quality.

#### 19.7.2 Initial Market and Actors

The approved initial market hypothesis is:

> **A small Seed-to-Series-A/B IT organization, especially its development team, that has frequent personnel movement and hiring difficulty, lacks the scale or operating capacity for a strong KMS and governance program, yet leaves substantial digital work traces in Jira, Confluence, Slack, GitHub, or comparable tools and still relies on people to reconnect those traces when responsibility changes.**

`Seed-to-Series-A/B` is a practical market proxy, not an asserted causal boundary. Development-team size, number of simultaneous products or projects, turnover events, organizational maturity, and dependence on key individuals may prove more explanatory. A team of roughly 10–30 developers that has already experienced a key developer's departure or reassignment is a concrete interview and experiment candidate, not an approved universal threshold.

The relevant actors are distinct:

- the successor, newly hired developer, or internally reassigned developer bears the reconstruction and learning cost;
- the Tech Lead, development lead, CTO, PM, or PO repeatedly explains history and compensates for missing continuity and is a plausible first adopter or economic sponsor;
- the organization bears delayed independent work, lost expert focus, repeated analysis, implementation errors, and key-person risk.

The first value moment is defined at the situation level, not as a frozen UI:

> A developer leaves or moves, another developer assumes the work, and the successor can understand the necessary prior context without manually reconstructing Jira issues, Slack discussions, documents, pull requests, and oral explanations from the beginning.

Whether that value is delivered as conversational questions, an onboarding briefing, a context map, a handoff package, or another interaction remains a product-design question.

#### 19.7.3 Primary Pain and Causal Structure

The primary pain selected for first validation is:

> **When a developer changes or a new person joins, necessary work context is distributed across tools and people, so the successor and the existing team jointly reconstruct the past: the successor searches and relearns while experienced people repeatedly explain.**

The working causal chain is:

```text
personnel change or new hire
        ↓
digital traces remain, but context and validity are distributed
        ↓
the successor searches Jira, Slack, documents, PRs, code, and people
        ↓
experienced staff repeat explanations and recover missing links
        ↓
slower independent work + lost expert focus
        ↓
repeated decisions, misunderstanding, rework, or transfer omissions
        ↓
the organization repays a learning cost each time a person changes
```

Frequent turnover, hiring difficulty, weak governance, and distributed information are conditions or causes, not the user pain itself. AER does not directly solve hiring. The initial value hypothesis is the combined cost of the successor's context reconstruction and the existing expert's repeated explanation.

A concise problem expression preserved from the discussion is:

> **Every time one developer joins, the whole team is onboarding again.**

This is a candidate market message, not validated customer language.

#### 19.7.4 Competitive Positioning

The competitive frame has three layers:

1. Enterprise context and knowledge platforms such as Glean, Atlassian Rovo, Microsoft, and adjacent products demonstrate that cross-system AI context is an existing product category. Their existence does not validate AER's target, wedge, or product value.
2. Lower-cost AI search, knowledge, and OSS products remain material alternatives. AER cannot rely on being cheaper, being Korean, being OSS, or using an LLM as differentiation.
3. The strongest initial competitor is current behavior: ask a person, search Slack or Jira, inspect folders and code, write a handoff document, call a former colleague, or simply relearn the work.

AER is not intended to be a reduced enterprise knowledge platform or a "small Glean." The proposed difference is a different customer, cost structure, operating burden, and vertically narrow continuity task. It should provide enough value for a team that would not buy or operate enterprise knowledge infrastructure, without importing enterprise feature scope into the initial product.

Existing platforms already connect external sources and normally center the resulting context on their own ecosystem. The possible AER position is a source-neutral continuity layer that preserves original provenance and authority rather than claiming a new central system of record. Source neutrality and connector count alone are not defensible differentiation; the unresolved candidate edge is deeper handling of change, current validity, handoff order, and long-lived context across personnel transitions.

The concept's limited novelty is acceptable and potentially useful because existing products reduce category-education and technical-feasibility burden. It does not establish competitive advantage. Any future advantage would have to be earned through verified product knowledge about the minimum traces, review boundary, continuity interaction, and adoption pattern that work in small development organizations.

#### 19.7.5 Adoption Principle and Intended Success State

The adoption constraint is a product existence condition, not a cosmetic UX preference:

- the first useful result should require almost no new routine behavior;
- a dedicated administrator, taxonomy project, mandatory knowledge-authoring process, or consulting engagement must not be a prerequisite for first value;
- default behavior must work before organization-specific customization becomes an optional deeper service;
- connection, permission, indexing, and trust costs count as adoption cost even when the software license is free.

The intended user reaction is:

> **AER is not required to perform the work, but after using it properly, the user does not want to return to an environment without it.**

The stronger long-term north-star expression is:

> **If AER cannot be used in a closed environment, practitioners recognize the restored context-search, handoff, and relearning labor as additional project cost.**

These statements are aspirational product success criteria. They are not evidence of present user preference, willingness to pay, or productivity improvement.

#### 19.7.6 Expansion Direction

Expansion is ordered and conditional:

```text
growth-stage development teams
        ↓ validate personnel-change continuity value
project-based development and SI organizations
        ↓ validate project-level adoption and repeated handoffs
closed, on-premises, and internal-LLM environments
        ↓ validate security, ownership, deployment, and reduced-model capability
optional project-standard supporting tool
```

SI is no longer only an adversarial fixture in the product discussion. Repeated reports received by the human researcher from multiple large-SI developers support the existence and recurrence of personnel changes, hidden local know-how, repeated learning, and project-bounded loss. This is qualitative field observation, not prevalence measurement or proof that AER can reduce the loss.

The SI value hypothesis has two sides:

- performer: the project continues when freelancers, partner staff, developers, PMs, or vendors change;
- client: authorized project memory remains available when the delivery organization leaves or a maintenance or successor vendor changes.

The client-side hypothesis may also reduce vendor dependence, but it immediately introduces ownership, contract, security, retention, deletion, and cross-party permission boundaries. It therefore remains a later hypothesis, not an initial requirement.

A project-level deployment may be more plausible than organization-wide governance in SI, and project start/close boundaries may make onboarding, explanation time, context-search time, repeated questions, reanalysis, and maintenance-transfer time measurable. Closed environments also motivate interchangeable inference engines and OSS/on-premises deployment. Whether AER without a strong LLM remains useful rather than becoming another manual management tool is unvalidated.

#### 19.7.7 Unvalidated Hypotheses and Kill Conditions

The following remain assumptions or open problems:

- the Seed-to-Series-A/B development segment is the best initial market rather than only a convenient proxy;
- the primary pain is severe and frequent enough to cause adoption, budget, or meaningful behavior change rather than continued tolerance of the status quo;
- weak-governance teams still retain enough trustworthy digital traces to create useful continuity;
- one or two initial source connections can produce first value without a broad connector program;
- AER can outperform existing search, a general-purpose LLM, and manual reconstruction on a continuity task that users actually care about;
- useful context can be formed with near-zero additional authoring, classification, or review labor;
- provenance, uncertainty, current validity, conflict, and human-confirmation rules can prevent confidently wrong context without recreating the management burden the product aims to remove;
- authentication, permission synchronization, source freshness, indexing, and connection setup can remain proportionate to a small organization's capacity;
- the default product can create material first value without organization-specific consulting; if consulting or governance design is required before first value, the current lightweight-product hypothesis is close to failure;
- successors and experienced team members obtain enough combined benefit to create a viable adopter and buyer path;
- the development-team result, if established, transfers to SI performers, SI clients, closed networks, other project organizations, or organization-wide continuity;
- internal or local LLMs can support a useful capability profile, and an LLM-free minimum mode has independent value;
- source-neutrality, workflow fit, and accumulated continuity practice can become a durable advantage; no current moat is claimed;
- pricing, per-user versus per-project economics, paid connectors, support, customization, and OSS commercialization remain future questions;
- industry-standard status, strategic partnership, marketplace distribution, or acquisition by an incumbent are optional future outcomes, not current strategy evidence or decisions.

The current product hypothesis should be reduced, revised, or stopped if target organizations repeatedly show that the pain is tolerable, the traces are insufficient, the output is not more useful than current search or manual work, or the behavior and governance required before first value are substantial.

#### 19.7.8 Validation and Resumption Contract

The next sequence is:

> **product definition → evidence of actual target pain and past behavior → selection of one minimum value hypothesis → very small product or comparison experiment → observation of actual use**

The next research question is not "What is AER?" but:

> **Which pain in the selected target should AER attack first, and does the target's actual past behavior show enough cost to justify an experiment?**

Interviews, when used, should ask about a recent personnel-change event and past behavior: what the successor did first, which artifacts and people were consulted, how much existing-team time was consumed, what could not be found, what was misunderstood, and what rework followed. Hypothetical preference questions such as "Would this be useful?" are insufficient evidence.

A stronger later test may use one real project's authorized historical materials to compare the existing reconstruction method with an AER candidate method. Candidate outcome measures include time to independent work, experienced-staff explanation time, context-search time, repeated questions, repeated analysis, rework, and maintenance-transfer time. Search accuracy or graph quality alone is not the product outcome.

Checkpoint non-effects:

- no commercial product value, product-market fit, demand, willingness to pay, comparative advantage, or organizational effectiveness is claimed;
- no UI, connector minimum, model vendor, deployment mode, price, company-size threshold, SI product requirement, or long-term category standard is frozen;
- no new Session, Principle, Decision, Evidence object, evaluation gate, blind result, AER Core change, release, or protected-file change is created;
- the current apparatus state and authorized next action recorded in 19.6 remain unchanged by this product-definition checkpoint.
