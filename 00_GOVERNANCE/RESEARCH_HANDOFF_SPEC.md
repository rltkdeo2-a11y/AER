# AER Research Handoff Specification

Specification ID: AER-RH-001

Version: 1.0

Status: Approved

Purpose:

Define the transfer contract through which a human-approved research conclusion is passed to Codex for controlled repository application.

---

## 1. Role of the Handoff

A Research Handoff connects two separate activities.

### Research Discussion

- explore questions,
- generate and challenge hypotheses,
- distinguish evidence from inference,
- determine approved conclusions.

### Repository Application

- inspect existing repository objects,
- create or update the minimum necessary files,
- validate the changes,
- complete only the authorized Git workflow,
- report the result.

The Handoff transfers approved conclusions.

It does not transfer private reasoning, conversational noise, discarded alternatives, or unapproved speculation.

---

## 2. Authority

A Handoff authorizes repository editing only when all of the following are present:

- `Approval Status: Approved`,
- an explicit Closure Mode,
- approved conclusions,
- scope and limitations,
- repository actions or a clear approved boundary for deriving the minimum action set,
- explicit Git permission.

### Manual Default

Default Git Permission for Manual Closure:

```text
Apply Only
```

Meaning:

Codex may edit approved files and run validation, but may not Stage, Commit, or Push.

### Autonomous Authority

```text
Git Permission: Autonomous Closure
```

means that the human approved the immediately preceding semantic summary and authorizes, within the approved scope:

- file creation or modification,
- validation,
- explicit-path Stage,
- one Commit,
- non-force Push to the approved branch,
- final result reporting.

No separate Diff, Stage, Commit, or Push approval is required in the normal Autonomous path.

---

## 3. Required Fields

Every Research Handoff must contain the following fields.

### Handoff ID

Format:

`RH-YYYYMMDD-NNN`

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
- Autonomous Closure

Manual permissions are cumulative only when explicitly stated.

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

The files to create, modify, inspect, or intentionally leave unchanged, or the approved boundary for deriving the minimum action set.

For Autonomous Closure, Repository Actions must additionally state:

- expected base Commit,
- target branch,
- proposed Commit title,
- whether Push is authorized,
- protected files explicitly permitted,
- allowed file paths or a bounded path pattern.

### Unresolved Questions

Questions that remain open after the current research.

### Validation Requirements

Checks that must pass before Commit.

---

## 4. Closure Modes

### Lightweight

Use for minor clarification, small correction, evidence or status restoration, or non-structural updates.

Default maximum:

- one or two modified research files,
- no README or CHANGELOG update,
- no version change.

### Standard

Use for a reusable reasoning result, new or revised Principle, material Evidence, Open Problem update, or research-session conclusion.

Default maximum:

- one Session or Reasoning record,
- one reusable knowledge object,
- one Open Problem or state update.

README and CHANGELOG remain unchanged unless explicitly justified.

### Release

Use only for repository structure, governance, framework-level release, public status, explicit version, or release-level documentation change.

Release may include protected governance and public files only when explicitly approved.

---

## 5. Repository Action Types

### Create

Create a new research object after verifying identifier, path, convention, and substantive content.

### Modify

Update an existing object while preserving content not explicitly superseded.

### No Change

Explicitly protect a file from modification.

### Inspect Only

Read a file as context without modifying it.

### Derive Minimum Set

Codex determines the smallest sufficient change set inside the approved semantic and repository boundary.

In Manual Closure, Codex reports the proposed set before editing.

In Autonomous Closure, Codex may proceed without another approval when the derived set remains inside the approved boundary. It must stop if the derived set requires an unexpected protected file, version change, or material scope expansion.

---

## 6. Stop Conditions

Codex must stop before editing or Commit, as applicable, when:

- Approval Status is not Approved,
- Closure Mode is missing,
- Git permission is missing or inconsistent,
- approved conclusions are ambiguous or internally inconsistent,
- the target identifier conflicts with an existing object,
- a requested path conflicts with repository convention,
- an unexpected protected-file or version change is required,
- the Handoff would strengthen conclusions beyond evidence,
- required evidence or source objects cannot be found,
- an empty or placeholder research object would result,
- unexplained pre-existing working-tree changes exist,
- branch, expected base Commit, or remote state differs,
- Merge or Rebase is in progress,
- required validation fails after one in-scope correction attempt.

Codex reports the problem rather than silently resolving a material ambiguity or broadening scope.

---

## 7. Application Procedure

### Manual Procedure

1. Read AGENTS.md and the Handoff.
2. Inspect Git status and relevant objects.
3. Verify identifiers, paths, scope, and limitations.
4. Report the minimum change set.
5. Wait for the required approval.
6. Apply approved changes.
7. Run validation.
8. Present a concise change report.
9. Follow the stated Stage, Commit, and Push permission.

### Autonomous Procedure

1. Read AGENTS.md, governance, and the Handoff.
2. Run Preflight against branch, expected base Commit, remote, and clean working tree.
3. Inspect relevant existing objects.
4. Derive and apply the minimum sufficient change set inside the approved boundary.
5. Run required validation and self-review.
6. Correct one in-scope validation failure and rerun validation.
7. Stage only validated approved paths.
8. Create one Commit.
9. Recheck remote base and Push without force when authorized.
10. Verify local and remote HEAD.
11. Report the final result.

---

## 8. Validation Requirements

Minimum validation:

- `git status --short`,
- actual changed-file list,
- approved-scope comparison,
- `git diff --check`,
- non-zero size for every new or materially restored file,
- filename and internal-ID consistency,
- referenced repository-path existence,
- no unintended protected-file change,
- no unauthorized version change,
- preservation of approved scope and limitations.

A validation failure must be disclosed.

Codex must not claim completion when a required check, Commit, Push, or remote verification has not been confirmed.

---

## 9. Handoff Lifecycle

A Handoff may move through:

```text
Draft → Approved → Applied → Committed → Pushed
```

`Applied` means files were modified and validated.

`Committed` means a local Commit was created.

`Pushed` means the approved remote branch was verified at that Commit.

A No-op approved Handoff may close without entering Committed or Pushed state.

---

## 10. Repository Status of the Handoff

The Handoff is a transfer contract, not automatically an official research object.

The Handoff itself is not added to the official repository unless archival is explicitly requested.

Official research knowledge resides in the research objects created or modified from the approved Handoff. Git history records the application Commit.

---

## 11. Required Codex Report

After Autonomous application, report:

1. Handoff ID
2. Closure Mode
3. approved conclusions reflected
4. files created
5. files modified
6. files intentionally not modified
7. validations performed
8. warnings or unresolved issues
9. Commit hash and title or No-op result
10. Push and remote-verification result
11. next baseline Commit

Manual reports also state the current Git permission boundary and next required approval.

---

## 12. Core Principle

A Research Handoff must be sufficient to prevent unsupported interpretation but small enough that repository management does not exceed the value of the research itself.

The default Autonomous objective is:

- minimum sufficient documentation,
- minimum necessary file changes,
- one human semantic approval,
- one research Commit,
- one authorized non-force Push,
- no duplicate status Commit.
