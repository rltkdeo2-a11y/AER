# ChatGPT–Codex Research Command Protocol

Protocol ID: AER-CCP-001

Version: 1.0

Status: Approved

Purpose:

Define the minimum user commands required to transfer an approved AER research conclusion from ChatGPT to Codex and complete repository application without repeated manual copying.

---

## 1. Operating Model

The workflow separates three responsibilities.

### ChatGPT

- conducts research discussion,
- challenges reasoning,
- separates evidence from inference,
- prepares an approval candidate,
- generates the final Research Handoff.

### Codex

- reads the approved Handoff,
- inspects the repository,
- proposes the minimum change set,
- applies approved changes,
- validates repository integrity,
- performs Git actions only after separate approval.

### Human Researcher

- approves conclusions,
- approves the minimum change set,
- reviews the Diff,
- separately approves Stage, Commit, and Push.

---

## 2. ChatGPT Commands

The following commands are used in the ChatGPT research conversation.

### `[연구종료 검토]`

Meaning:

The research discussion may be ready to close.

ChatGPT must provide only:

- candidate approved conclusions,
- evidence basis,
- scope,
- limitations,
- unresolved questions,
- recommended Closure Mode,
- expected repository-object types.

ChatGPT must not yet produce a final Approved Handoff.

---

### `[결론 승인]`

Meaning:

The human approves the research conclusions presented in the preceding closure review.

ChatGPT must:

- treat only the explicitly presented conclusions as approved,
- preserve limitations and unresolved questions,
- not infer approval for omitted or disputed conclusions.

This command does not authorize repository editing.

---

### `[Handoff 생성]`

Meaning:

Generate one structured Research Handoff for Codex.

Requirements:

- Approval Status must reflect the actual human decision.
- Default Git Permission is `Apply Only`.
- Closure Mode must be explicit.
- The Handoff must contain the minimum sufficient repository actions.
- Protected files must remain protected unless explicitly required.
- The response should contain one complete Handoff block and a short transfer instruction.
- Do not output full target-file contents.

The Handoff is the only research-content block that normally needs to be transferred from ChatGPT to Codex.

---

### `[Handoff 수정]`

Meaning:

Revise the most recently generated Handoff before Codex application.

The human must state the requested correction.

ChatGPT must issue a complete replacement Handoff rather than partial patch instructions.

---

### `[연구계속]`

Meaning:

Cancel the current closure attempt and continue research discussion.

Any unapproved Handoff candidate remains Draft or is discarded.

---

## 3. Codex Commands

The following commands are used in the Codex session after the approved Handoff has been supplied.

### `[사전검토]`

Meaning:

Run Phase 1 only.

Codex must:

- read AGENTS.md and applicable governance,
- validate the Handoff,
- inspect Git status,
- propose the minimum sufficient change set,
- report protected-file impact and duplicate-documentation risk,
- stop without editing.

No file modification or Git action is permitted.

---

### `[적용 승인]`

Meaning:

The human approves the minimum change set proposed during Phase 1.

Codex may:

- perform Phase 2 application,
- run Phase 3 validation,
- provide the Phase 4 change report.

Codex may not:

- Stage,
- Commit,
- Push.

This command is valid only when Git Permission permits repository application.

---

### `[Diff 승인]`

Meaning:

The human has reviewed the VS Code Diff and accepts the current content changes.

This command alone does not authorize Stage unless the Handoff permits `Stage After Review`.

When Git Permission remains `Apply Only`, Codex must report that a permission change or explicit Stage authorization is still required.

---

### `[Stage 승인]`

Meaning:

Stage only the explicitly reviewed files.

Codex must:

- list the exact files before staging,
- use explicit file paths,
- never use `git add .`,
- verify the cached file list afterward,
- not Commit.

---

### `[Commit 승인]`

Meaning:

Create one Commit from the approved staged files.

Codex must:

- run cached validation,
- verify the staged file list,
- use the approved or proposed Commit title,
- create one Commit,
- report its hash,
- not Push.

A separate status Commit must not be created merely to record the first Commit hash.

---

### `[Push 승인]`

Meaning:

Push the current approved branch after Commit.

Codex must:

- confirm the current branch,
- confirm the working tree state,
- push without force,
- verify that local HEAD and remote branch match.

---

### `[중단]`

Meaning:

Stop the current Codex workflow immediately.

Codex must not perform any further file or Git action.

Existing uncommitted changes must remain intact unless the human separately directs their removal.

---

## 4. Command Sequence

### Ordinary Standard Closure

ChatGPT:

```text
[연구종료 검토]
```

Human:

```text
[결론 승인]
```

Human:

```text
[Handoff 생성]
```

Transfer the complete Handoff once to Codex.

Codex:

```text
[사전검토]
```

Human:

```text
[적용 승인]
```

Human reviews the VS Code Diff.

Human:

```text
[Stage 승인]
```

Human:

```text
[Commit 승인]
```

Human:

```text
[Push 승인]
```

---

## 5. Default Permission Boundary

The default Handoff permission is:

`Apply Only`

Therefore the default workflow stops after:

- file application,
- automated validation,
- concise change report,
- human Diff review.

Stage, Commit, and Push always require separate human instructions.

---

## 6. Use of `[다음]`

`[다음]` is not a Git authorization command.

It may be used in a guided setup conversation to request the next explanatory step.

It must never be interpreted as:

- Apply approval,
- Stage approval,
- Commit approval,
- Push approval,
- file deletion approval.

Repository actions require the explicit commands defined in this protocol.

---

## 7. Handoff Transfer Rule

The normal transfer unit between ChatGPT and Codex is one complete Research Handoff.

Do not manually transfer:

- every research conversation message,
- full target-file contents,
- separate copies of Principle, Evidence, Decision, and Session documents,
- repeated Git command instructions.

Codex derives the actual repository edits by inspecting:

- the approved Handoff,
- existing repository conventions,
- existing related research objects.

---

## 8. Error and Conflict Handling

### Handoff Error

Use:

```text
[Handoff 수정]
```

and provide the correction.

Do not manually edit fragments of the Handoff in several places.

### Unexpected Codex Change

Use:

```text
[중단]
```

Review the Diff before any Git action.

### Validation Failure

Codex must report the failure and wait.

Do not proceed to Stage or Commit.

### Existing Unrelated Working-Tree Changes

Codex must stop during Pre-Application Review unless those changes are explicitly identified as an accepted baseline.

---

## 9. Human Review Points

Human approval is required at five decision points.

1. Research conclusion approval
2. Minimum repository change-set approval
3. Diff and Stage approval
4. Commit approval
5. Push approval

Approval at one point does not imply approval at later points.

---

## 10. Success Criterion

The protocol succeeds when an ordinary research conclusion can be stored through:

- one ChatGPT Handoff,
- one Codex minimum-change review,
- one automated validation,
- one human Diff review,
- one research Commit,
- optional Push,

without manually copying full research documents into VS Code.
