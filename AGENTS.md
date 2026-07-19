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

## 3. Operating Modes

The default mode is analysis and proposal only.

Do not create or modify files unless the user explicitly requests repository application.

Two repository-application modes are supported.

### Manual Closure

Use the staged approval flow defined by the governance documents.

### Autonomous Closure

When all of the following are present:

- `Approval Status: Approved`,
- `Git Permission: Autonomous Closure`,
- an explicit Closure Mode,
- an approved semantic summary,
- an approved repository scope,

that single human approval authorizes the approved scope through:

- file creation or modification,
- validation,
- explicit-path Stage,
- one Commit,
- non-force Push to the approved branch,
- final result reporting.

Do not request separate Diff, Stage, Commit, or Push approval during a normal Autonomous Closure.

Autonomous Closure does not authorize work outside the approved scope.

## 4. Scope Control

Before editing:

- inspect the relevant existing files,
- inspect current Git status,
- identify the smallest necessary change set,
- report ambiguity that could materially change the result.

Prefer updating an existing research object over creating a duplicate object.

Do not expand the task into unrelated cleanup, restructuring, or formatting.

In Autonomous Closure, resolve ordinary implementation choices independently when they remain inside the approved semantic and repository scope.

Stop only when a material ambiguity would change the approved conclusion, protected-file scope, version, or repository boundary.

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

`Autonomous Closure` does not override protected-file restrictions. The approved handoff must explicitly permit each protected-file change.

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
- repository actions or an approved minimum-set derivation boundary,
- closure mode,
- Git permission,
- unresolved questions.

When the handoff is incomplete or internally inconsistent, stop before editing and report the missing information.

For `Autonomous Closure`, the handoff is an execution contract. It may remain an internal transfer artifact unless archival is explicitly requested.

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

Follow the Closure Mode and Git Permission specified in the approved handoff.

Absent an explicit Closure Mode, do not modify the repository.

Ordinary research closure should use the smallest sufficient set of research objects.

Do not update multiple documents merely to repeat the same status, scope, or conclusion.

Git history is the authoritative record of Commit hashes. Do not create a second Commit only to record the hash of the first Commit in documentation.

## 10. Required Validation

After file edits and before Commit, run or verify:

- `git status --short`,
- changed-file list,
- approved-scope comparison,
- `git diff --check`,
- repository closure validation,
- non-zero file size for every new or materially restored file,
- filename and internal-ID consistency,
- reference-path existence,
- absence of unintended protected-file changes,
- preservation of approved scope and limitations.

In Manual Closure, do not Stage files until the required human review has occurred.

In Autonomous Closure, Stage only the validated files inside the approved scope and continue without additional human approval.

## 11. Change Report

After applying an approved handoff, report concisely:

1. files created,
2. files modified,
3. files intentionally not modified,
4. validations performed,
5. warnings or unresolved issues,
6. Commit result,
7. Push result when authorized.

Do not claim success when a required validation or Git action has not been confirmed.

## 12. Git Safety

Never run the following:

- `git add .`,
- `git commit --amend`,
- `git reset --hard`,
- `git clean -fd`,
- `git rebase`,
- `git push --force`,
- `git push --force-with-lease`.

When Stage is authorized, add only explicitly approved and validated files.

Create one Commit unless a genuinely independent correction is required.

Manual Closure requires the permissions defined in its handoff.

Autonomous Closure permits one non-force Push to the approved remote branch after all validation passes and the remote base remains unchanged.
