# AER Research Closure Policy

Policy ID: AER-RC-001

Version: 1.0

Status: Approved

Purpose:

Define the minimum repository work required to close an AER research session without allowing repository administration to exceed the value of the research itself.

---

## 1. Core Closure Principle

Research closure must preserve:

- approved conclusions,
- supporting evidence,
- limitations,
- unresolved questions,
- traceability of repository changes.

Research closure must not create duplicate documentation merely to repeat the same conclusion, status, version, or Commit information.

The default target is:

- one human diff review,
- one research Commit,
- no duplicate status Commit,
- no manual copying of full documents between ChatGPT and VS Code,
- no README or CHANGELOG update for ordinary research sessions.

---

## 2. Closure Cost Target

Closure effort should remain proportional to research value.

Default operational targets:

### Lightweight Closure

Target duration:

5 to 10 minutes

Default changed files:

1 to 2

### Standard Closure

Target duration:

10 to 20 minutes

Default changed files:

2 to 4

### Release Closure

Target duration:

Determined by release scope

Release Closure is exceptional and must not become the default.

These targets are operational guidance, not absolute limits.

Codex must warn when the proposed change set materially exceeds the default range.

---

## 3. Closure Mode Selection

The Handoff must explicitly select one Closure Mode.

Codex must not choose Release merely because several files could be updated.

When uncertain between two modes, prefer the lighter mode and report what would remain undocumented.

---

# 4. Lightweight Closure

## 4.1 Intended Use

Use Lightweight Closure for:

- correcting an existing research object,
- restoring missing content,
- adding a small evidence note,
- clarifying an existing conclusion,
- recording a minor research observation,
- updating one Open Problem without creating a new framework object,
- closing an exploratory session that produced no reusable principle.

## 4.2 Default Repository Actions

Allowed by default:

- modify one existing research object,
- optionally modify one directly related Open Problem or session log.

Normally prohibited:

- README modification,
- CHANGELOG modification,
- CURRENT_STATE modification,
- version change,
- new Decision object,
- new Principle object,
- new release record.

## 4.3 Maximum Default Scope

Default maximum:

- 2 changed files,
- 1 Commit,
- no follow-up status Commit.

If more files appear necessary, Codex must explain why Lightweight is insufficient before editing them.

## 4.4 Typical Examples

Example A:

Restore missing content in an Evidence object.

Expected changes:

- one Evidence file.

Example B:

Clarify an unresolved question in an Open Problem.

Expected changes:

- one Open Problem file,
- optionally one Session file.

Example C:

Record that a proposed hypothesis was rejected.

Expected changes:

- one Session or Reasoning file.

---

# 5. Standard Closure

## 5.1 Intended Use

Use Standard Closure for:

- adopting a reusable reasoning result,
- creating or materially revising a Principle,
- adding substantive Evidence,
- updating a related Open Problem,
- recording a completed research session,
- integrating a validated but non-release-level model refinement.

## 5.2 Default Repository Actions

A Standard Closure may include:

- one Session or Reasoning record,
- one reusable research object such as Principle or Evidence,
- one related Open Problem update,
- optionally one CURRENT_STATE update only when the active research direction materially changes.

Normally prohibited:

- README modification,
- CHANGELOG modification,
- repository structural version change,
- framework release declaration,
- duplicate Decision and Principle objects containing substantially the same content.

## 5.3 Maximum Default Scope

Default maximum:

- 4 changed files,
- 1 Commit,
- no second Commit solely to record completion or the first Commit hash.

When more than 4 files are proposed, Codex must first report:

1. why each file is necessary,
2. which information would be duplicated,
3. whether a lighter change set is possible.

## 5.4 Object Selection Rules

Create a Principle only when:

- the conclusion is reusable,
- it has evidence beyond a single isolated case,
- the human has approved it as a general rule.

Create a Decision only when:

- meaningful alternatives existed,
- the human explicitly selected one,
- recording the choice is useful independently of the Principle or Reasoning.

Create Evidence separately only when:

- the evidence record has reusable value,
- the evidence is substantial,
- it should be independently traceable.

Create a Session record when:

- the research process itself must be traceable,
- the session contains decisions or unresolved questions not captured elsewhere.

Do not create all object types by default.

## 5.5 Typical Examples

Example A:

A repeated reasoning pattern is validated across several cases.

Expected changes:

- one Reasoning or Session record,
- one Principle,
- one related Open Problem update.

Example B:

A new evidence set changes the strength of an existing Principle.

Expected changes:

- one Evidence file,
- one Principle modification,
- optionally one Open Problem modification.

---

# 6. Release Closure

## 6.1 Intended Use

Use Release Closure only for:

- repository structure changes,
- governance changes,
- public framework release,
- AER repository version change,
- AETF research-state version change,
- major approved scope change,
- release-level documentation update.

## 6.2 Permitted Repository Actions

Release Closure may include:

- README,
- CHANGELOG,
- CURRENT_STATE,
- governance documents,
- specification documents,
- version records,
- multiple research objects,
- release notes.

## 6.3 Required Conditions

Release Closure requires all of the following:

- `Approval Status: Approved`
- `Closure Mode: Release`
- explicit human approval for protected-file modification
- explicit version decision
- complete changed-file justification
- repository-wide consistency validation
- one final diff review

## 6.4 Commit Policy

Prefer one release Commit when practical.

A second Commit is permitted only when it represents a genuinely independent correction or technical necessity.

Do not create a second Commit solely to write the first Commit hash into documentation.

Git history is the authoritative Commit record.

---

# 7. Files Not Updated by Default

The following files are not updated for ordinary research closure:

- README.md
- CHANGELOG.md
- 00_GOVERNANCE/CURRENT_STATE

Exceptions:

### README.md

Update only when:

- repository purpose changes,
- public structure changes,
- major public framework status changes,
- a release explicitly requires it.

### CHANGELOG.md

Update only when:

- preparing a release,
- grouping multiple research Commits into a release,
- governance explicitly requires a release note.

### CURRENT_STATE

Update only when:

- active research objective changes,
- active sprint or research phase changes,
- the next authoritative research direction changes.

Do not update CURRENT_STATE merely to record that a Commit succeeded.

---

# 8. Duplicate Documentation Control

Before creating or modifying a file, Codex must ask:

1. Is this information already preserved in another authoritative object?
2. Does this file have an independent research function?
3. Would omitting this update materially reduce future research usability?
4. Is the file being changed only to repeat status or Commit information?

If the answer to Question 4 is yes, do not modify the file unless the Handoff explicitly justifies it.

---

# 9. Minimum Sufficient Record

A research closure is sufficient when a future researcher can determine:

- what question was examined,
- what conclusion was approved,
- what evidence supports it,
- where the conclusion applies,
- where it does not apply,
- what remains unresolved,
- what repository files changed.

The closure need not preserve:

- every conversational turn,
- every discarded hypothesis,
- every intermediate draft,
- repeated summaries of the same decision,
- Commit hashes in multiple documents.

---

# 10. Automatic Downgrade Check

Before applying a Standard or Release Handoff, Codex must evaluate whether the task can be completed using a lighter mode.

Codex must report:

- requested Closure Mode,
- minimum sufficient Closure Mode,
- proposed changed-file count,
- protected files affected,
- duplicated content risk.

Codex must not silently change the approved Closure Mode.

It may recommend a downgrade and wait for human confirmation.

---

# 11. Escalation Conditions

Codex must stop and request human review when:

- the change set exceeds the default file limit,
- a protected file is required unexpectedly,
- a new version appears necessary,
- multiple objects would contain substantially duplicated content,
- existing repository conventions conflict,
- the Handoff does not provide enough evidence for a Principle,
- a Release Closure appears necessary despite a lighter approved mode.

---

# 12. Git Workflow by Closure Mode

## Lightweight

Default sequence:

1. Apply approved change.
2. Validate.
3. Present diff summary.
4. Wait for Stage approval.
5. Commit once.
6. Push only after separate approval.

## Standard

Default sequence:

1. Inspect related objects.
2. Propose minimum change set.
3. Apply approved change.
4. Validate object IDs, paths, scope, and limitations.
5. Present one consolidated diff.
6. Wait for Stage and Commit approval.
7. Commit once.
8. Push only after separate approval.

## Release

Default sequence:

1. Confirm release approval and version decision.
2. Inspect repository-wide impact.
3. Apply approved changes.
4. Run repository-wide consistency validation.
5. Present complete diff and release summary.
6. Wait for explicit Commit approval.
7. Commit.
8. Push only after separate approval.

---

# 13. Completion Reports

Every closure report must contain only:

- Closure Mode,
- files created,
- files modified,
- files intentionally not modified,
- validations performed,
- warnings,
- proposed Commit title,
- required next approval.

Do not produce a long procedural narrative unless a validation failure requires explanation.

---

# 14. Policy Success Criterion

This policy succeeds when:

- research conclusions remain traceable,
- zero-byte and wrong-path errors are prevented,
- ordinary closure completes within minutes rather than hours,
- the user reviews one concise diff,
- repository management remains subordinate to research activity.
