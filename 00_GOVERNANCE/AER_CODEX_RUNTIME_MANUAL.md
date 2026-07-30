# AER Codex Runtime Manual

Document ID: AER-CRM-001

Status: Applied locally; SessionStart, UserPromptSubmit, and PreToolUse activation observed; SubagentStart pending

Version: 1.0

Created: 2026-07-28

Updated: 2026-07-28

State Reconciled: 2026-07-30

References:

- `AGENTS.md`
- `BOOTSTRAP.md`
- `00_GOVERNANCE/RESEARCH_HANDOFF_SPEC.md`
- `00_GOVERNANCE/RESEARCH_CLOSURE_POLICY.md`
- `00_GOVERNANCE/CHATGPT_CODEX_COMMAND_PROTOCOL.md`
- `00_GOVERNANCE/CODEX_RESEARCH_APPLY_PROMPT.md`
- `scripts/invoke-aer-runtime.ps1`
- `scripts/validate-research-close.ps1`
- `scripts/invoke-aer-closure.ps1`

Summary:

This manual defines the supported operating path from a new Codex task through AER reasoning, approved repository application, validation, and authorized closure. Commands do not create research approval, change scope, or grant Git permission by themselves.

---

## 1. Scope and Safety Boundary

This manual applies only inside the AER repository.

- The repository is the Single Source of Truth.
- Conversation, local memory, draft notes, and hook output are execution context, not repository authority.
- AER Core remains unchanged. Runtime binding is an execution-integrity control.
- A repository write requires a human-approved Research Handoff with an explicit Closure Mode and Git Permission.
- A command must be run only when its preconditions are satisfied. Do not use commands to bypass approval, protected-file restrictions, validation, or Git safety.

The Codex project must be trusted and the repository hooks must be reviewed and trusted for automatic binding. If either condition is unavailable, use the manual verification fallback in Section 4.

---

## 2. AER Operating Model

At the start of substantive work, establish an Active Reasoning State:

```text
Objective
Official baseline and confirmed conclusions
Facts, assumptions, hypotheses, and unknowns
Open question
Mutable repository scope
Stop or reopening conditions
Progress pointer
```

Classify each material input relative to that state:

- `CONTINUE` — continue the current reasoning without changing confirmed state.
- `REVISE` — revise a conclusion with explicit supporting grounds and impact.
- `REOPEN` — reopen the Problem Definition or conclusion because decisive evidence invalidates it.
- `NEW_SCOPE` — separate a different objective from the current research state.

State Departure occurs when an approved conclusion is silently changed or rediscovered as new, an assumption becomes a fact without support, or current reasoning diverges from official state without a recorded revision. Stop the affected conclusion, reload the authority source, state the conflict, and resume only from the corrected state.

Use AER Core for materially complex judgment. Add B-type independent counterargument reinforcement only for high importance, uncertainty, or self-fixation risk. Use C-type high-precision validation only for audit, dispute, or high-loss judgment. See DEC-005 for the approved boundary.

---

## 3. Automatic Runtime Binding

When `.codex/config.toml` and `.codex/hooks.json` are active, Codex runs the following automatically.

| Event | Runtime action | Result |
|---|---|---|
| New, resumed, cleared, or compacted session | `SessionStart` | Full AER authority packet is added to developer context. |
| Subagent start | `SubagentStart` | The subagent receives the same AER authority packet. |
| Every user prompt | `UserPromptSubmit` | Compact state-classification checkpoint is added. |
| File edit through `apply_patch` | `PreToolUse` | Authority validation failure denies the edit; otherwise edit-scope context is added. |

Activation status as of 2026-07-30:

- actual `SessionStart`, `UserPromptSubmit`, and `PreToolUse` activation has been observed against the repository working version;
- `SubagentStart` output has diagnostic validation, but its actual client-triggered activation remains pending independent observation; and
- implementation existence or diagnostic success must not be reported as complete lifecycle activation.

The packet validates required authority files, current-state references, repository identity, branch, HEAD, working-tree state, and a SHA-256 authority digest. It does not grant permission to edit, Stage, Commit, or Push.

---

## 4. Start or Recover a Codex Task

### 4.1 Automatic path

1. Open the AER repository as a trusted Codex project.
2. Review and trust the new repository hook definition once in the Codex hook manager.
3. Start a new task, resume a task, or continue after compaction.
4. Confirm that the AER runtime binding packet is present before substantive reasoning or edits.

### 4.2 Manual verification fallback

Use this command when hooks are unavailable, disabled, untrusted, or suspected to have failed.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-runtime.ps1 -HookEvent Verify
```

Expected final line:

```text
AER_RUNTIME_VERIFY_PASS
```

If verification fails, do not form or apply a repository conclusion. Repair the authority-reference or repository-state issue first, then rerun verification.

### 4.3 Runtime event diagnostics

These commands test the event outputs without starting a new Codex session.

```powershell
'{"session_id":"manual-test","cwd":"C:\\path\\to\\AER","hook_event_name":"SessionStart","source":"startup"}' | powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-runtime.ps1 -HookEvent SessionStart

'{"session_id":"manual-test","cwd":"C:\\path\\to\\AER","hook_event_name":"UserPromptSubmit","prompt":"continue"}' | powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-runtime.ps1 -HookEvent UserPromptSubmit

'{"session_id":"manual-test","cwd":"C:\\path\\to\\AER","hook_event_name":"PreToolUse","tool_name":"apply_patch","tool_input":{"command":"test"}}' | powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-runtime.ps1 -HookEvent PreToolUse
```

Replace `C:\path\to\AER` with the actual repository path. These diagnostics do not modify the repository.

---

## 5. Research Discussion Commands

Use these commands in the research conversation. They are semantic workflow commands, not shell commands.

| Command | Meaning | Result |
|---|---|---|
| `[AER 논의 종료]` | Request closure review for the current research discussion. | A semantic summary and proposed scope are prepared; no file is changed yet. |
| `[승인]` | Approve the immediately preceding semantic summary. | Applies only the Handoff authority stated in that summary. |
| `[수정: 내용]` | Correct the proposed semantic summary. | A complete replacement summary is required before approval. |
| `[미반영]` | Close the discussion without repository application. | No Handoff, file, or Git action. |
| `[연구계속]` | Continue research instead of closing it. | Cancels the current closure attempt. |

Manual fallback commands are used only when the approved Handoff is not autonomous or when staged human review is requested.

| Command | Meaning |
|---|---|
| `[연구종료 검토]` | Begin a manual closure review. |
| `[결론 승인]` | Approve the research conclusion in manual flow. |
| `[Handoff 생성]` | Request a structured Handoff. |
| `[Handoff 수정]` | Correct a Handoff before application. |
| `[사전검토]` | Ask Codex to inspect scope and repository state. |
| `[적용 승인]` | Authorize the approved file application step. |
| `[Diff 승인]` | Authorize manual Diff review completion. |
| `[Stage 승인]` | Authorize explicit-path staging. |
| `[Commit 승인]` | Authorize the specified Commit. |
| `[Push 승인]` | Authorize the specified non-force Push. |
| `[중단]` | Stop the manual closure flow. |

`[다음]` is not approval for any repository or Git action.

---

## 6. Handoff Requirements

Before repository application, the Handoff must state:

```text
Handoff ID
Approval Status
Closure Mode
Git Permission
Research Question
Approved Conclusions
Evidence Basis
Scope and Limitations
Repository Actions
Unresolved Questions
Validation Requirements
```

For Autonomous Closure, it must additionally state the target branch, expected base Commit, allowed files, proposed Commit title, protected-file permission, and Push authorization.

Do not edit the repository when approval status, Closure Mode, Git Permission, scope, or limitations are missing or inconsistent.

---

## 7. Inspect and Validate Before Application

Use read-only checks before modifying files.

```powershell
git status --short
git branch --show-current
git rev-parse HEAD
git diff --check
```

Run the existing runtime regression pilot when changes could affect AER execution binding or state departure.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/aer-runtime-pilot.ps1 -Mode All -BaselineCommit HEAD
```

Run closure validation after edits. Replace the expected paths with the approved file set.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/validate-research-close.ps1 -Mode Standard -ExpectedFiles @(
  'path/to/approved-file-1',
  'path/to/approved-file-2'
)
```

For a Release closure, use `-Mode Release`. Add `-AllowProtectedFiles` only when the approved Handoff explicitly permits each protected-file change.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/validate-research-close.ps1 -Mode Release -ExpectedFiles @(
  'path/to/approved-file-1'
)
```

The placeholder paths above are examples and must be replaced by the approved scope.

---

## 8. Autonomous Closure Commands

Run these commands only after an Approved Handoff grants `Git Permission: Autonomous Closure`.

### 8.1 Preflight

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-closure.ps1 `
  -Phase Preflight `
  -Mode Release `
  -ExpectedBaseCommit <approved-full-commit-sha> `
  -Branch main `
  -Remote origin
```

Use the Handoff's actual Closure Mode, branch, remote, and full expected base Commit. Preflight stops if the working tree, branch, local base, remote base, or Git operation state is inconsistent.

### 8.2 Finalize without Push

```powershell
$allowed = @(
  'path/to/approved-file-1',
  'path/to/approved-file-2'
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-closure.ps1 `
  -Phase Finalize `
  -Mode Release `
  -ExpectedBaseCommit <approved-full-commit-sha> `
  -Branch main `
  -Remote origin `
  -AllowedFiles $allowed `
  -CommitMessage '<approved-commit-title>' `
  -ValidationScript 'scripts/validate-research-close.ps1'
```

### 8.3 Finalize and Push

Add `-Push` only when the Handoff explicitly authorizes non-force Push.

```powershell
$allowed = @(
  'path/to/approved-file-1',
  'path/to/approved-file-2'
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-closure.ps1 `
  -Phase Finalize `
  -Mode Release `
  -ExpectedBaseCommit <approved-full-commit-sha> `
  -Branch main `
  -Remote origin `
  -AllowedFiles $allowed `
  -CommitMessage '<approved-commit-title>' `
  -ValidationScript 'scripts/validate-research-close.ps1' `
  -Push
```

The closure script stages only the actual validated changed files, creates one Commit, checks the remote base again, and performs only a non-force Push.

---

## 9. Manual Closure Commands

If the Handoff uses `Apply Only`, apply and validate the approved files, then stop before Stage, Commit, or Push.

```powershell
git status --short
git diff --check
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/validate-research-close.ps1 -Mode <approved-mode> -ExpectedFiles @(
  'path/to/approved-file-1'
)
```

Do not run `git add`, `git commit`, or `git push` until the specific subsequent manual approval is given.

---

## 10. Stop Conditions and Recovery

Stop before editing or closure when any of the following is true:

- authority verification fails,
- the official state conflicts with the current conclusion,
- a required Handoff field is missing,
- the change needs an unexpected protected file or version change,
- the actual changed files exceed approved scope,
- an unexplained working-tree change exists,
- the expected base, branch, or remote base differs,
- validation fails after one in-scope correction,
- semantic departure or assumption-to-fact promotion requires model review.

Recovery path:

1. Preserve user work; do not Stash, reset, clean, merge, or rebase.
2. Identify the authority source or scope conflict.
3. Restore the Active Reasoning State from the repository.
4. Request a corrected or expanded Handoff when needed.
5. Rerun the smallest relevant verification command.

---

## 11. Completion Report

Every completed repository application reports:

```text
Closure Mode
Approved Conclusions Reflected
Files Created
Files Modified
Files Intentionally Not Modified
Validation Result
Warnings or Unresolved Issues
Commit Result
Push Result
Next Baseline Commit
```

No result may claim that a Commit, Push, or lifecycle-hook activation succeeded unless it was actually confirmed.
