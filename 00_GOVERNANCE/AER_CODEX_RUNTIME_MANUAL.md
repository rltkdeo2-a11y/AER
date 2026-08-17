# AER Codex Runtime Manual

Document ID: AER-CRM-001

Status: Runtime binding active on observed paths; Git execution and canonical-promotion roles defined

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
- `scripts/invoke-aer-promotion.ps1`
- `scripts/test-aer-repository-operating-model.ps1`

Summary:

This manual defines the supported operating path from a new Codex task through AER reasoning, approved candidate production, validation, and owner-controlled canonical promotion. Commands do not create research approval, change scope, or grant Git permission by themselves.

---

## 1. Scope and Safety Boundary

This manual applies only inside the AER repository.

- The repository is the Single Source of Truth.
- Conversation, local memory, draft notes, and hook output are execution context, not repository authority.
- AER Core remains unchanged. Runtime binding is an execution-integrity control.
- A repository write requires a human-approved Research Handoff with an explicit Closure Mode and Git Permission.
- A command must be run only when its preconditions are satisfied. Do not use commands to bypass approval, protected-file restrictions, validation, or Git safety.
- `origin/main` is the remote SSOT. The local canonical repository is an owner-controlled integration copy, not the SSOT by itself.
- Candidate-production authority and canonical-acceptance authority are separate repository roles. An Agent execution environment may create a validated candidate Commit but may not move or Push canonical `main`.
- Broad recursive `.git` write-deny is prohibited. Each authorized identity must have normally writable Git metadata inside its own repository role boundary.

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
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-runtime.ps1 -HookEvent Verify -RefreshRemote
```

Expected final line when the repository boundary is valid:

```text
AER_RUNTIME_VERIFY_PASS
```

`AER_RUNTIME_VERIFY_HOLD` is a deliberate stop result. It identifies an undeclared role, stale or divergent authority, dirty canonical repository, invalid execution branch, shared object database, disabled permission boundary, or another repository-role violation. Remote unavailability must be reported as unverified; it must not be converted into a claim about credentials or current `origin/main`.

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

For Autonomous Closure, it must additionally state the candidate branch, expected canonical baseline Commit, allowed files, proposed candidate Commit title, protected-file permission, and whether later owner-controlled promotion is authorized.

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

## 8. Git Execution and Canonical Promotion

Run these commands only after an Approved Handoff grants the applicable candidate-closure and owner-promotion authority.

### 8.1 Repository roles

The role is explicit local Git state, not a directory-name inference.

```powershell
# Owner-controlled canonical integration copy
git config --local aer.repositoryRole CANONICAL_OWNER
git config --local aer.pushPolicy OWNER_ONLY
git config --local aer.canonicalRemote origin
git config --local aer.canonicalBranch main

# Agent/Codex execution clone
git config --local aer.repositoryRole EXECUTION
git config --local aer.pushPolicy DENY
git config --local aer.canonicalRemote origin
git config --local aer.canonicalBranch main
git config --local aer.canonicalBaseline <verified-full-origin-main-sha>
git remote set-url --push origin disabled://execution-repository
```

`aer.pushPolicy=DENY` plus the disabled Push URL is an actual local permission boundary. Do not claim that credentials are absent; report only the verified boundary. In `CANONICAL_OWNER`, Push capability is `NOT_TESTED` until the owner explicitly runs a dry-run permission check or the promotion runner performs the authorized normal Push.

### 8.2 Independent execution clone

Prefer a normal full clone from the canonical fetch URL:

```powershell
git clone <canonical-fetch-url> <execution-path>
git -C <execution-path> config --local aer.repositoryRole EXECUTION
git -C <execution-path> config --local aer.pushPolicy DENY
git -C <execution-path> config --local aer.canonicalRemote origin
git -C <execution-path> config --local aer.canonicalBranch main
git -C <execution-path> config --local aer.canonicalBaseline <verified-full-origin-main-sha>
git -C <execution-path> remote set-url --push origin disabled://execution-repository
git -C <execution-path> switch -c candidate/<approved-name> <verified-full-origin-main-sha>
```

When cloning from a local canonical path, add `--no-local` so objects are copied instead of hard-linked:

```powershell
git clone --no-local <canonical-owner-path> <execution-path>
```

Do not use `--shared`, `--reference`, alternates, linked `git worktree`, external `GIT_DIR`, shallow clone, or partial clone for authority isolation. They share, relocate, or omit repository metadata and therefore weaken failure containment or provenance independence.

An explicitly approved candidate may depend on an earlier unpromoted exact candidate. Record that dependency locally and promote in order:

```powershell
git config --local aer.canonicalBaseline <predecessor-candidate-sha>
git config --local aer.allowPendingPredecessor true
git config --local aer.predecessorCandidate <predecessor-candidate-sha>
```

This allows candidate production but keeps promotion on `HOLD` until actual `origin/main` reaches the predecessor SHA.

### 8.3 Candidate preflight and finalize

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-closure.ps1 `
  -Phase Preflight `
  -Mode Release `
  -ExpectedBaseCommit <approved-full-candidate-parent-sha> `
  -Branch candidate/<approved-name>
```

Then finalize only the approved paths:

```powershell
$allowed = @(
  'path/to/approved-file-1',
  'path/to/approved-file-2'
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-closure.ps1 `
  -Phase Finalize `
  -Mode Release `
  -ExpectedBaseCommit <approved-full-candidate-parent-sha> `
  -Branch candidate/<approved-name> `
  -AllowedFiles $allowed `
  -CommitMessage '<approved-candidate-commit-title>' `
  -ValidationScript 'scripts/validate-research-close.ps1'
```

The closure runner requires `REPOSITORY_ROLE=EXECUTION`, a full independent object database, a non-`main` candidate branch, and the explicit canonical Push deny boundary. Its former `-Push` path is rejected.

### 8.4 Exact-object transport

Freeze the candidate SHA, create the validation manifest required by the promotion contract, and transport the exact object. A bundle is preferred when the owner environment cannot fetch the execution repository directly.

```powershell
$candidate = git rev-parse HEAD
git bundle create <candidate-bundle-path> candidate/<approved-name> ^<approved-full-candidate-parent-sha>
git bundle verify <candidate-bundle-path>
```

The bundle or fetch source transports Git objects. Do not copy files and create a new Commit.

### 8.5 Owner-controlled promotion

The validation manifest must identify the exact candidate, expected base, parent, title, exact changed-file set, and PASS results for bundle or source verification, `git diff --check`, repository validation, Runtime verification, authority validation, and `git fsck --full`. Validator warnings are permitted only when the manifest records a `PASS_WITH_WARNINGS` policy and contains no FAIL result.

Run owner preflight before changing `main`:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-promotion.ps1 `
  -Phase Preflight `
  -CandidateSource <bundle-or-fetch-source> `
  -CandidateCommit <validated-full-candidate-sha> `
  -ExpectedBaseCommit <validated-full-parent-sha> `
  -ExpectedTitle '<validated-candidate-title>' `
  -ExpectedFiles $allowed `
  -ValidationManifest <validation-manifest-path> `
  -Branch main `
  -Remote origin
```

After owner review, use the same arguments with `-Phase Promote -Push`. The runner imports the exact object, rechecks actual `origin/main`, uses only `git merge --ff-only`, performs a normal non-force Push, and verifies the postconditions. If local fast-forward succeeds but Push fails, it reports `LOCAL ONLY` and preserves the local state; it does not Reset or rewrite history.

### 8.6 Canonical `.git` ACL repair

The canonical repository owner must have normal write access to Git metadata. Do not use `/reset`. First run as the account that owns `.git`, back up the ACL outside the repository, and remove only the confirmed explicit Deny principals.

The 2026-08-17 incident inspection found owner `DESKTOP-ON595UG\admin` and explicit recursive Deny ACEs for these two SIDs:

```text
S-1-5-21-3910502522-3632848469-1333837873-3048639951
S-1-5-21-1367308410-1437228978-2538376216-3260784637
```

Owner-executable procedure:

```powershell
$repo = 'C:\Users\admin\Documents\GIT\AER'
$gitDir = Join-Path $repo '.git'
$acl = Get-Acl -LiteralPath $gitDir
$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
if ($currentIdentity -ne $acl.Owner) { throw "Run as repository owner $($acl.Owner), not $currentIdentity" }

$backup = '<owner-controlled-backup-path>\AER-dotgit-acl-before.txt'
icacls $gitDir /save $backup /T /C
if ($LASTEXITCODE -ne 0) { throw 'ACL backup failed' }

$denySids = @(
  'S-1-5-21-3910502522-3632848469-1333837873-3048639951',
  'S-1-5-21-1367308410-1437228978-2538376216-3260784637'
)
foreach ($denySid in $denySids) {
  icacls $gitDir /remove:d "*$denySid"
  if ($LASTEXITCODE -ne 0) { throw "Failed to remove Deny ACE for $denySid" }
}

Get-Acl -LiteralPath $gitDir
Get-Acl -LiteralPath (Join-Path $gitDir 'index')
Get-Acl -LiteralPath (Join-Path $gitDir 'objects')
Get-Acl -LiteralPath (Join-Path $gitDir 'refs')

git -C $repo config --local aer.repositoryRole CANONICAL_OWNER
git -C $repo config --local aer.pushPolicy OWNER_ONLY
git -C $repo config --local aer.canonicalRemote origin
git -C $repo config --local aer.canonicalBranch main
```

Stop if the owner identity, backup, SID attribution, or resulting ACL cannot be verified. Do not remove unrelated ACEs, disable inheritance broadly, or replace the complete ACL.

### 8.7 Remote protection

Recommended minimum protection for `origin/main` is force-Push disabled, branch deletion disabled, linear history required where compatible, and required validation checks where available. A repository document or local Git setting does not prove that a GitHub ruleset exists. Verify remote protection through an authenticated owner interface or connector and record `UNVERIFIED` when that boundary cannot be queried.

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
- repository role is undeclared or invalid,
- Agent/Codex is asked to edit a `CANONICAL_OWNER` repository,
- an `EXECUTION` repository uses a linked worktree, external `GIT_DIR`, alternates, shared, shallow, or partial object storage,
- the execution canonical Push deny boundary is absent or not actually configured,
- actual `origin/main` cannot be verified for canonical promotion,
- a broad recursive `.git` Deny ACE remains on the canonical owner repository,
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
Candidate Commit and Exact-Object Transport Result
Owner Promotion Result
Push and Actual Remote Verification Result
Next Baseline Commit
```

No result may claim that a Commit, Push, or lifecycle-hook activation succeeded unless it was actually confirmed.
