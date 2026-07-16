# AER Repository Instructions

## 1. Repository Purpose

This repository is the Single Source of Truth for validated AER research assets.

Conversation, temporary notes, draft reasoning, and unapproved outputs are not official repository knowledge.

Only human-approved research conclusions may be integrated into official research objects.

## 2. Instruction Priority

When instructions conflict, apply the following order within this repository:

1. The human user's explicit instruction for the current task
2. AER governance documents
3. The approved research handoff for the current task
4. This AGENTS.md
5. Existing repository conventions

Do not infer approval from the existence of draft content.

## 3. Default Operating Mode

The default mode is analysis and proposal only.

Do not create or modify files unless the user explicitly requests repository application.

Do not Stage, Commit, Push, amend, rebase, reset, force-push, or delete Git history without explicit human approval.

## 4. Scope Control

Before editing:

- inspect the relevant existing files,
- inspect current Git status,
- identify the smallest necessary change set,
- report ambiguity that could materially change the result.

Prefer updating an existing research object over creating a duplicate object.

Do not expand the task into unrelated cleanup, restructuring, or formatting.

## 5. Protected Files

Do not modify the following unless the approved handoff explicitly requires it:

- BOOTSTRAP.md
- README.md
- CHANGELOG.md
- 00_GOVERNANCE/CURRENT_STATE
- 00_GOVERNANCE/SPECIFICATION.md
- 00_GOVERNANCE/OPERATION_RULES.md
- 00_GOVERNANCE/PROJECT_CHARTER.md
- 00_GOVERNANCE/RESEARCH_PHILOSOPHY.md

README and CHANGELOG are release-level documents and are not updated for ordinary research sessions.

Do not change the AER repository version or AETF research-state version without explicit human approval.

## 6. Research Integrity

Keep the following categories distinct:

- Fact
- Observation
- Inference
- Decision
- Assumption
- Open Problem

Do not present an inference as a fact.

Do not convert a single exception into a general principle without repeated evidence and explicit approval.

Preserve approved limitations, uncertainty, and unvalidated scope.

Do not strengthen conclusions beyond the approved handoff.

## 7. Research Handoff

Repository changes must be based on a structured, human-approved research handoff.

The handoff must identify:

- research question,
- approved conclusions,
- supporting evidence,
- scope and limitations,
- target files,
- closure mode,
- unresolved questions.

When the handoff is incomplete or internally inconsistent, stop before editing and report the missing information.

## 8. File Safety

Before creating a file:

- confirm that the target path does not already contain a conflicting object,
- inspect the relevant naming and identifier convention,
- verify the next identifier instead of guessing it.

Before overwriting a file:

- read its existing content,
- preserve content not explicitly superseded,
- never replace a non-empty file with an empty file or placeholder.

For every created or modified Markdown file:

- use UTF-8,
- preserve the repository's existing line-ending convention,
- ensure the file is not empty,
- ensure the internal object ID matches the filename,
- ensure referenced repository paths exist or are explicitly marked as external working artifacts.

Do not create zero-byte research objects.

## 9. Minimal Research Closure

Follow the closure mode specified in the approved handoff.

Absent an explicit closure mode, do not modify the repository.

Ordinary research closure should use the smallest sufficient set of research objects.

Do not update multiple documents merely to repeat the same status, scope, or conclusion.

Git history is the authoritative record of Commit hashes. Do not create a second Commit only to record the hash of the first Commit in documentation.

## 10. Required Validation

After file edits and before proposing Stage or Commit, run or verify:

- `git status --short`
- `git diff --check`
- changed-file list
- non-zero file size for every new or materially restored file
- filename and internal-ID consistency
- reference-path existence
- absence of unintended protected-file changes
- preservation of approved scope and limitations

Do not Stage files until the human has reviewed the change summary.

## 11. Change Report

After applying an approved handoff, report:

1. files created,
2. files modified,
3. files intentionally not modified,
4. validations performed,
5. warnings or unresolved issues,
6. proposed Commit title.

Keep the report concise.

Do not claim success when a required validation has not been performed.

## 12. Git Safety

Never run the following without explicit human instruction:

- `git add .`
- `git commit --amend`
- `git reset --hard`
- `git clean -fd`
- `git rebase`
- `git push --force`
- `git push --force-with-lease`

When Stage is approved, add only explicitly approved files.

When Commit is approved, Commit once unless a genuine independent correction is required.

Push requires separate explicit approval.
