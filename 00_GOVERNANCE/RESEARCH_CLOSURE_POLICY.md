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

The default Autonomous Closure target is:

- one human semantic approval,
- one minimum repository change set,
- one automated validation sequence,
- one research Commit,
- one non-force Push when authorized,
- no repeated manual transfer or Git approval.

Manual Closure remains available as fallback.

---

## 2. Closure Cost Target

Closure effort must remain proportional to research value.

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

These targets are operational guidance, not absolute limits. A materially larger change set must already be visible in the approved semantic summary or trigger a stop before Commit.

---

## 3. Two Independent Dimensions

Every approved Handoff must specify both:

### Closure Mode

- Lightweight
- Standard
- Release

Closure Mode determines documentation scope.

### Git Permission

- Analysis Only
- Apply Only
- Stage After Review
- Commit After Review
- Push After Review
- Autonomous Closure

Git Permission determines execution authority.

Do not treat Closure Mode as Git permission or Git permission as documentation scope.

---

## 4. Execution Modes

### 4.1 Autonomous Closure

Autonomous Closure is the default target operating mode for normal AER research closure.

Trigger:

```text
[AER 논의 종료]
```

ChatGPT presents a semantic approval summary containing:

- conclusions to record,
- items to defer or omit,
- impact on existing conclusions,
- expected repository scope,
- Closure Mode,
- execution boundary.

The human responds with one of:

```text
[승인]
[수정: ...]
[미반영]
```

`[승인]` authorizes the approved scope through editing, validation, explicit-path Stage, one Commit, and non-force Push to the approved branch.

Normal Autonomous Closure must not request separate:

- minimum-set approval,
- Diff approval,
- Stage approval,
- Commit approval,
- Push approval.

### 4.2 Manual Closure

Use Manual Closure only when:

- the human explicitly requests stepwise review,
- the automation environment is unavailable,
- an Autonomous Closure stop condition occurs.

Manual Closure uses the staged permissions and commands defined in the ChatGPT–Codex Research Command Protocol.

---

## 5. Closure Mode Selection

The Handoff must explicitly select one Closure Mode.

Codex must not choose Release merely because several files could be updated.

When uncertain between two modes, prefer the lighter mode when it can preserve the approved research meaning without creating an undocumented structural change.

In Autonomous Closure, Codex may derive the minimum sufficient file set inside the approved semantic and repository boundary without another human approval.

It must stop when the lighter mode would omit an approved material conclusion or require an unapproved protected-file or version change.

---

## 6. Lightweight Closure

### Intended Use

Use Lightweight Closure for:

- correcting an existing research object,
- restoring missing content,
- adding a small evidence note,
- clarifying an existing conclusion,
- recording a minor research observation,
- updating one Open Problem without creating a new framework object,
- closing an exploratory session that produced no reusable principle.

### Default Scope

Normally:

- 1 to 2 changed files,
- one Commit,
- no README, CHANGELOG, CURRENT_STATE, version, Decision, Principle, or release-record change.

If a larger scope is already stated in the approved summary, it may proceed only when the selected Closure Mode remains substantively correct.

---

## 7. Standard Closure

### Intended Use

Use Standard Closure for:

- adopting a reusable reasoning result,
- creating or materially revising a Principle,
- adding substantive Evidence,
- updating a related Open Problem,
- recording a completed research session,
- integrating a validated but non-release-level model refinement.

### Default Scope

A Standard Closure may include:

- one Session or Reasoning record,
- one reusable research object such as Principle or Evidence,
- one related Open Problem update,
- optionally one CURRENT_STATE update only when the active research direction materially changes.

Normally:

- 2 to 4 changed files,
- one Commit,
- no README or CHANGELOG change,
- no repository structural version or framework release declaration.

### Object Selection

Create a Principle only when:

- the conclusion is reusable,
- it has evidence beyond a single isolated case,
- the human approved it as a general rule.

Create a Decision only when:

- meaningful alternatives existed,
- the human explicitly selected one,
- recording the choice is useful independently of the Principle or Reasoning.

Create Evidence separately only when it has reusable and independently traceable value.

Create a Session record when the research process itself contains decisions or unresolved questions not preserved elsewhere.

Do not create all object types by default.

---

## 8. Release Closure

### Intended Use

Use Release Closure only for:

- repository structure changes,
- governance changes,
- public framework release,
- AER repository version change,
- AETF research-state version change,
- major approved scope change,
- release-level documentation update.

### Permitted Scope

Release Closure may include:

- README,
- CHANGELOG,
- CURRENT_STATE,
- governance or specification documents,
- version records,
- multiple research objects,
- release notes.

### Required Conditions

Release Closure requires:

- `Approval Status: Approved`,
- `Closure Mode: Release`,
- explicit approved scope for each protected file,
- an explicit version decision when a version is changed,
- complete changed-file justification,
- repository-wide consistency validation.

Under Autonomous Closure, the approved semantic summary replaces a separate final human Diff review. Codex must still perform a complete self-review and stop if the actual change materially exceeds the approved summary.

Prefer one release Commit when practical.

Do not create a second Commit solely to write the first Commit hash into documentation.

---

## 9. Files Not Updated by Default

The following files are not updated for ordinary research closure:

- README.md
- CHANGELOG.md
- 00_GOVERNANCE/CURRENT_STATE

### README.md

Update only when repository purpose, public structure, major public framework status, or an approved release requires it.

### CHANGELOG.md

Update only when preparing a release, grouping research Commits into a release, or governance explicitly requires a release note.

### CURRENT_STATE

Update only when the active research objective, active phase, or next authoritative research direction changes.

Do not update CURRENT_STATE merely to record that a Commit succeeded.

---

## 10. Duplicate Documentation Control

Before creating or modifying a file, determine:

1. whether the information is already preserved in another authoritative object,
2. whether the file has an independent research function,
3. whether omission would materially reduce future research usability,
4. whether the change only repeats status or Commit information.

Do not modify a file only to repeat status or Commit information unless the approved Handoff explicitly justifies it.

---

## 11. Minimum Sufficient Record

A research closure is sufficient when a future researcher can determine:

- what question was examined,
- what conclusion was approved,
- what evidence supports it,
- where the conclusion applies,
- where it does not apply,
- what remains unresolved,
- what repository files changed.

The closure need not preserve every conversational turn, discarded hypothesis, intermediate draft, repeated summary, or Commit hash in multiple documents.

---

## 12. Autonomous Stop Conditions

Stop before Commit when:

- the approved semantic summary is ambiguous or internally inconsistent,
- the actual change would strengthen the approved conclusion,
- an unexpected protected-file or version change is required,
- the actual file scope materially exceeds the approved repository boundary,
- an unexplained pre-existing working-tree change exists,
- the branch or expected base Commit differs,
- Merge or Rebase is in progress,
- the remote base changed after Preflight,
- required validation still fails after one in-scope correction attempt,
- repository convention conflicts cannot be resolved without changing research meaning.

Do not silently expand scope, Stash user work, reset, clean, merge, or rebase.

If Commit succeeds but Push fails, preserve the local Commit and report the failure.

---

## 13. Git Workflow

### Autonomous Closure

1. Validate the approved Handoff and semantic scope.
2. Run repository Preflight.
3. Inspect only relevant existing objects.
4. Derive and apply the minimum sufficient change set.
5. Run required validation and `git diff --check`.
6. Compare actual changed files with the approved scope.
7. Stage only explicit validated paths.
8. Create one Commit.
9. Recheck the remote base.
10. Push without force when authorized.
11. Verify local and remote HEAD.
12. Report the result.

### Manual Closure

Use the staged review and permission sequence defined in `00_GOVERNANCE/CHATGPT_CODEX_COMMAND_PROTOCOL.md`.

---

## 14. Completion Reports

An Autonomous Closure report contains:

- Closure Mode,
- approved conclusions reflected,
- files created and modified,
- files intentionally not modified,
- validation result,
- warnings or unresolved issues,
- Commit hash and title,
- Push and remote-verification result,
- next baseline Commit.

A Manual Closure report also states the next required approval.

Do not produce a long procedural narrative unless a stop condition or failure requires explanation.

---

## 15. Policy Success Criterion

This policy succeeds when:

- research conclusions remain traceable,
- ordinary closure requires one human semantic approval,
- zero-byte, wrong-path, and out-of-scope changes are prevented,
- one research Commit closes the approved change,
- repository management remains subordinate to research activity.
