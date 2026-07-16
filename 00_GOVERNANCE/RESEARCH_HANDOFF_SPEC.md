# AER Research Handoff Specification

Specification ID: AER-RH-001

Version: 1.0

Status: Approved

Purpose:

Define the transfer contract through which a human-approved research conclusion is passed to Codex for controlled repository application.

---

## 1. Role of the Handoff

A Research Handoff connects two separate activities.

Research Discussion:

- explore questions,
- generate and challenge hypotheses,
- distinguish evidence from inference,
- determine approved conclusions.

Repository Application:

- inspect existing repository objects,
- create or update the minimum necessary files,
- validate the changes,
- present a diff for human review.

The Handoff transfers approved conclusions.

It does not transfer private reasoning, conversational noise, discarded alternatives, or unapproved speculation.

---

## 2. Authority

A Handoff authorizes repository editing only when all of the following are present:

- `Approval Status: Approved`
- an explicit Closure Mode,
- approved conclusions,
- scope and limitations,
- repository actions or a clear instruction to derive the minimum action set,
- explicit Git permission.

The existence of a Handoff does not authorize Stage, Commit, or Push unless those permissions are separately stated.

Default Git Permission:

Apply Only

Meaning:

Codex may edit approved files and run validation, but may not Stage, Commit, or Push.

---

## 3. Required Fields

Every Research Handoff must contain the following fields.

### Handoff ID

Format:

`RH-YYYYMMDD-NNN`

Example:

`RH-20260715-001`

### Approval Status

Allowed values:

- Draft
- Approved
- Rejected
- Superseded

Codex may apply only an Approved Handoff.

### Closure Mode

Allowed values:

- Lightweight
- Standard
- Release

### Git Permission

Allowed values:

- Analysis Only
- Apply Only
- Stage After Review
- Commit After Review
- Push After Review

Permissions are cumulative only when explicitly stated.

### Research Question

The question examined during the research discussion.

### Approved Conclusions

Only conclusions explicitly approved by the human researcher.

### Evidence Basis

The cases, documents, observations, or existing research objects supporting the conclusions.

### Scope

The domain in which the conclusions may currently be applied.

### Limitations

Unvalidated areas, uncertainty, dependencies, and claims that must not be strengthened.

### Repository Actions

The files to create, modify, or intentionally leave unchanged.

### Unresolved Questions

Questions that remain open after the current research.

### Validation Requirements

Checks that must pass before the changes may be proposed for Stage or Commit.

---

## 4. Closure Modes

### Lightweight

Use for:

- research-log additions,
- minor clarification,
- small corrections,
- evidence or status restoration,
- non-structural updates.

Default maximum:

- one or two modified research files,
- no README update,
- no CHANGELOG update,
- no version change.

### Standard

Use for:

- a reusable reasoning result,
- a new or revised principle,
- material evidence,
- an Open Problem update,
- a research-session conclusion.

Default maximum:

- one session or reasoning record,
- one reusable knowledge object,
- one Open Problem or state update.

README and CHANGELOG remain unchanged unless explicitly justified.

### Release

Use only for:

- repository structural change,
- governance change,
- framework-level release,
- public status change,
- explicit version change.

Release mode may include:

- README,
- CHANGELOG,
- CURRENT_STATE,
- specification or governance documents,
- version updates.

Release mode requires explicit human approval.

---

## 5. Repository Action Types

Allowed action types:

### Create

Create a new research object after verifying:

- the identifier is unused,
- the path follows repository convention,
- the file will contain substantive non-empty content.

### Modify

Update an existing object while preserving content not explicitly superseded.

### No Change

Explicitly protect a file from modification.

### Inspect Only

Read a file as context without modifying it.

### Derive Minimum Set

Codex determines the smallest sufficient change set from the approved conclusions and reports it before editing.

---

## 6. Stop Conditions

Codex must stop before editing when:

- Approval Status is not Approved,
- Closure Mode is missing,
- approved conclusions are ambiguous or internally inconsistent,
- the target identifier conflicts with an existing object,
- the requested path conflicts with repository convention,
- a protected file is requested without sufficient justification,
- the Handoff attempts to strengthen conclusions beyond the evidence,
- required evidence or source objects cannot be found,
- the requested action would create an empty or placeholder research object,
- Git permission is unclear.

Codex must report the problem rather than silently resolving a material ambiguity.

---

## 7. Application Procedure

Codex must perform the following sequence.

1. Read AGENTS.md.
2. Read the Handoff.
3. Inspect Git status.
4. Inspect relevant existing research objects.
5. Verify identifiers and paths.
6. Determine the minimum change set.
7. Report any material ambiguity.
8. Apply only approved changes.
9. Run required validation.
10. Present a concise change report and diff summary.
11. Wait for human approval before Stage, Commit, or Push.

---

## 8. Validation Requirements

Minimum validation:

- `git status --short`
- changed-file list
- `git diff --check`
- non-zero size for every new or materially restored file
- filename and internal-ID consistency
- referenced repository-path existence
- no unintended protected-file changes
- no unauthorized version change
- preservation of approved scope and limitations

A validation failure must be disclosed.

Codex must not claim completion when a required check has not passed.

---

## 9. Handoff Lifecycle

A Handoff may move through the following states:

Draft

→ Approved

→ Applied

→ Committed

→ Pushed

`Applied` means repository files have been modified and validated.

It does not mean the changes have been Committed.

`Committed` does not mean the changes have been Pushed.

The stages must not be conflated.

---

## 10. Repository Status of the Handoff

The Handoff is a transfer contract, not automatically an official research object.

The Handoff itself is not added to the official repository unless the human explicitly requests archival.

Official research knowledge resides in the research objects created or modified from the approved Handoff.

Git history records the application Commit.

---

## 11. Required Codex Report

After application, Codex must report:

1. Handoff ID
2. Closure Mode
3. files created
4. files modified
5. files intentionally not modified
6. validations performed
7. warnings or unresolved issues
8. proposed Commit title
9. current Git permission boundary

The report must remain concise.

---

## 12. Core Principle

A Research Handoff must be sufficient to prevent unsupported interpretation but small enough that repository management does not exceed the value of the research itself.

The default objective is:

- minimum sufficient documentation,
- minimum necessary file changes,
- one human diff review,
- one research Commit,
- no duplicate status Commit.
