# BOOTSTRAP

Repository: AX Engineering Research (AER)

Current Version: v1.0

Status: Frozen

---

This repository is the Single Source of Truth (SSOT).

`origin/main` is the remote SSOT. A local canonical repository is an owner-controlled integration copy; an execution repository is a candidate-production copy.

Follow the governance documents before performing reasoning.

Priority Order

1. PROJECT_CHARTER

2. RESEARCH_PHILOSOPHY

3. OPERATION_RULES

4. SPECIFICATION

---

Research Rules

- Separate Fact, Inference and Opinion.

- Repository assets are authoritative.

- Conversation is temporary.

- Repository updates require approved Research Commits.

- Human approval is required before repository modification.

---

Repository Role Bootstrap

Run before substantive reasoning or editing:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/invoke-aer-runtime.ps1 -HookEvent Verify -RefreshRemote
```

Required output includes:

- `REPOSITORY_ROLE = CANONICAL_OWNER | EXECUTION`
- current branch and HEAD
- actual `origin/main` when reachable, otherwise an explicit unverified result
- ahead/behind when the compared objects are locally available
- canonical baseline SHA
- candidate branch and candidate Commit state for `EXECUTION`
- independent-object-database result
- explicit Push permission-boundary result
- stale, divergent, dirty-canonical, or shared-object HOLD reasons

The local role is declared only in repository-local Git configuration:

```powershell
git config --local aer.repositoryRole CANONICAL_OWNER
# or
git config --local aer.repositoryRole EXECUTION
```

Role Rules

- `CANONICAL_OWNER` is used only for owner-controlled import, verification, fast-forward promotion, and normal Push of an exact validated Commit.
- Agent/Codex does not edit or create candidate Commits in `CANONICAL_OWNER`.
- `EXECUTION` is a full independent clone with writable Git metadata and an explicit local Push deny boundary for the canonical remote.
- An undeclared role, stale baseline, divergent authority, linked worktree, external `GIT_DIR`, alternates, shared, shallow, or partial clone is `HOLD`.
- Broad recursive `.git` write-deny is prohibited. Authority is separated by repository role and permission boundary, not by disabling Git.

Candidate and Promotion Units

```text
canonical baseline Commit
→ execution branch
→ exact candidate Commit SHA
→ validators and runtime evidence
→ verified bundle or fetchable exact object
→ owner import and verification
→ ff-only main promotion
→ normal Push to protected origin/main
→ post-promotion authority verification
```

The validation unit and promotion unit are the exact candidate Commit SHA. File copy and recommit, Merge Commit, Rebase, Cherry-pick, force Push, and Reset are not standard promotion mechanisms.

---

Research Workflow

Question

↓

Reasoning

↓

Knowledge Extraction

↓

Research Commit Proposal

↓

Human Approval

↓

Repository Update
