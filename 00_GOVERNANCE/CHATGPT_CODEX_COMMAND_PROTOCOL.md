# ChatGPT–Codex Research Command Protocol

Protocol ID: AER-CCP-001

Version: 1.0

Status: Approved

Purpose:

Define the minimum commands required to transfer an approved AER research conclusion from ChatGPT to Codex and complete repository application without repeated manual copying or Git approval.

---

## 1. Operating Model

The workflow separates three responsibilities.

### ChatGPT

- conducts research discussion,
- challenges reasoning,
- separates evidence from inference,
- reviews relevant repository context,
- prepares the semantic approval summary,
- generates the approved Research Handoff.

### Codex

- reads the approved Handoff and governance,
- inspects the repository,
- derives the minimum sufficient change set inside the approved boundary,
- applies approved changes,
- validates repository integrity,
- completes authorized Git actions,
- reports the result.

### Human Researcher

- conducts and directs the research discussion,
- approves, corrects, or rejects the semantic summary,
- reviews the final result or any stopped condition.

In normal Autonomous Closure, the human does not separately approve the minimum file set, Diff, Stage, Commit, or Push.

---

## 2. Default Autonomous Commands

### `[AER 논의 종료]`

Meaning:

Start research closure for the current AER discussion.

ChatGPT must review the relevant approved repository state and present only:

- conclusions to record,
- items to defer or omit,
- impact on existing conclusions,
- expected Closure Mode,
- expected repository scope,
- version and protected-file impact,
- statement that approval authorizes execution through Push within that scope,
- stop conditions.

ChatGPT must not yet modify the repository.

### `[승인]`

Meaning:

The human approves the immediately preceding semantic summary.

When the Handoff uses `Git Permission: Autonomous Closure`, this one approval authorizes:

- internal Handoff generation,
- repository Preflight,
- approved file creation or modification,
- validation,
- explicit-path Stage,
- one Commit,
- non-force Push to the approved branch,
- final result reporting.

Approval does not authorize any stronger conclusion, unexpected protected-file change, version change, or repository scope expansion.

### `[수정: ...]`

Meaning:

Correct the semantic approval summary before execution.

ChatGPT must issue one complete replacement summary. Prior approval candidates are not cumulative.

### `[미반영]`

Meaning:

Close the discussion without repository application.

No Handoff, file, or Git action is authorized.

### `[연구계속]`

Meaning:

Cancel the current closure attempt and continue research discussion.

---

## 3. Autonomous Execution Contract

After `[승인]`, ChatGPT or the connected execution path supplies one complete Approved Handoff to Codex.

Codex must then perform the Autonomous path without further human prompts unless a stop condition occurs.

Codex must not request:

- pre-application approval,
- minimum-set approval,
- Diff approval,
- Stage approval,
- Commit approval,
- Push approval.

The Handoff remains the normal transfer unit. It may be transferred internally and need not be shown unless requested.

---

## 4. Autonomous Sequence

```text
ChatGPT research discussion
→ [AER 논의 종료]
→ semantic approval summary
→ [승인]
→ approved Handoff
→ Codex Preflight
→ minimum in-scope application
→ validation and self-review
→ explicit-path Stage
→ one Commit
→ non-force Push
→ remote verification
→ final report
```

A No-op closure creates no Commit and performs no Push.

---

## 5. Manual Fallback Commands

Use the following only when:

- the human explicitly requests stepwise review,
- Autonomous execution is unavailable,
- an Autonomous stop condition requires manual recovery.

### ChatGPT fallback

- `[연구종료 검토]`
- `[결론 승인]`
- `[Handoff 생성]`
- `[Handoff 수정]`

### Codex fallback

- `[사전검토]`
- `[적용 승인]`
- `[Diff 승인]`
- `[Stage 승인]`
- `[Commit 승인]`
- `[Push 승인]`
- `[중단]`

In Manual Closure, approval at one point does not imply approval at a later point.

---

## 6. Default Permission Boundary

For an approved autonomous semantic summary, the generated Handoff should use:

```text
Git Permission: Autonomous Closure
```

For Manual Closure, the default remains:

```text
Git Permission: Apply Only
```

`Autonomous Closure` is valid only when Approval Status, Closure Mode, repository scope, target branch, expected base Commit, validation requirements, and proposed Commit title are sufficiently defined.

---

## 7. Use of `[다음]`

`[다음]` advances a guided research or implementation discussion.

It is not a repository authorization command and must never be interpreted as:

- semantic approval,
- Apply approval,
- Stage approval,
- Commit approval,
- Push approval,
- file deletion approval.

---

## 8. Handoff Transfer Rule

The normal transfer unit between ChatGPT and Codex is one complete Research Handoff.

Do not manually transfer:

- every research conversation message,
- full target-file contents,
- separate duplicate summaries,
- repeated Git command instructions.

Codex derives the actual edits from:

- the approved Handoff,
- relevant repository conventions,
- relevant existing research objects.

---

## 9. Stop and Failure Handling

Codex stops before Commit when:

- Approval Status is not Approved,
- Closure Mode or Git Permission is missing,
- the approved conclusions are materially ambiguous or inconsistent,
- the actual change would exceed the approved semantic or repository scope,
- an unexpected protected-file or version change is required,
- unexplained pre-existing working-tree changes exist,
- branch, base Commit, or remote state differs,
- Merge or Rebase is in progress,
- required validation fails after one in-scope correction attempt.

Codex must not silently Stash, reset, clean, merge, rebase, or broaden scope.

If Commit succeeds but Push fails, preserve the local Commit and report:

- Commit hash,
- current branch,
- Push failure,
- remote state when available.

---

## 10. Final Report

Normal Autonomous Closure returns only:

- Handoff ID,
- Closure Mode,
- conclusions reflected,
- files created and modified,
- files intentionally not modified,
- validation result,
- warnings or unresolved issues,
- Commit hash and title or No-op result,
- Push and remote-verification result,
- next baseline Commit.

Do not output the full Handoff, full file bodies, or procedural narration unless requested or needed to explain a failure.

---

## 11. Success Criterion

The protocol succeeds when an ordinary approved AER conclusion is stored through:

- one semantic approval,
- one internal Handoff,
- one automated validation sequence,
- one research Commit,
- one non-force Push when authorized,

without manual file copying or repeated Git approval.
