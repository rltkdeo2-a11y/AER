# Codex Research Handoff Application Prompt

Purpose:

Apply a human-approved AER Research Handoff through a minimum, validated repository change process. Use Autonomous Closure by default when the approved Handoff authorizes it; otherwise use the Manual fallback boundary.

---

## 1. Required Inputs

Provide either:

- the full approved Research Handoff, or
- the path to an approved Research Handoff file.

Required Handoff fields:

- Handoff ID
- Approval Status
- Closure Mode
- Git Permission
- Research Question
- Approved Conclusions
- Evidence Basis
- Scope
- Limitations
- Repository Actions
- Unresolved Questions
- Validation Requirements

For `Autonomous Closure`, Repository Actions must also make clear:

- approved repository boundary,
- protected-file permission,
- target branch,
- expected base Commit,
- proposed Commit title,
- whether Push is authorized.

---

## 2. Autonomous Application Prompt

Use the following prompt when `Git Permission: Autonomous Closure`.

```text
현재 AER 저장소에서 다음 문서를 먼저 읽어라.

- AGENTS.md
- 00_GOVERNANCE/RESEARCH_HANDOFF_SPEC.md
- 00_GOVERNANCE/RESEARCH_CLOSURE_POLICY.md
- 00_GOVERNANCE/CHATGPT_CODEX_COMMAND_PROTOCOL.md
- 이번 작업의 승인된 Research Handoff

Research Handoff source:

[승인된 Handoff 본문 또는 파일 경로]

이번 작업은 승인된 Research Handoff와 AER governance 범위 안에서만 수행한다.

# Phase 1 — Autonomous Preflight

파일을 수정하기 전에 다음을 확인한다.

1. Approval Status가 Approved인지 확인한다.
2. Closure Mode가 명시됐는지 확인한다.
3. Git Permission이 Autonomous Closure인지 확인한다.
4. 승인된 결론, Scope, Limitation, Repository Actions 사이에 모순이 없는지 확인한다.
5. 대상 Branch와 Expected Base Commit을 확인한다.
6. scripts/invoke-aer-closure.ps1의 Preflight를 실행한다.
7. 관련 기존 연구객체와 명명·보호파일 규칙을 읽는다.
8. 승인된 의미를 보존하는 최소 변경파일 집합을 내부적으로 결정한다.

중단조건이 없으면 별도 인간 승인 없이 Phase 2로 진행한다.

# Phase 2 — Autonomous Application

1. 승인범위 안의 파일만 생성 또는 수정한다.
2. 기존 파일 전체를 읽고 명시적으로 대체되지 않은 내용을 보존한다.
3. 승인결론보다 강한 표현을 추가하지 않는다.
4. Fact, Observation, Inference, Decision, Assumption, Open Problem을 구분한다.
5. Scope, Limitation, Unresolved Question을 보존한다.
6. 신규 또는 복원 파일에는 실질적 본문을 작성한다.
7. 0바이트 파일이나 placeholder를 생성하지 않는다.
8. 파일명과 내부 Object ID를 일치시킨다.
9. 참조하는 저장소 경로가 존재하는지 확인한다.
10. 보호파일은 Handoff가 명시적으로 허용한 경우에만 수정한다.
11. 관련 상태·색인 문서는 승인된 의미를 보존하기 위해 필요한 최소 범위에서만 동기화한다.
12. 승인범위를 벗어나지 않는 구현 선택은 스스로 결정한다.

# Phase 3 — Validation and Self-Correction

다음을 수행한다.

- 실제 변경파일 목록 확인
- 승인된 Repository Actions와 비교
- scripts/validate-research-close.ps1 실행
- git diff --check
- 파일 크기, UTF-8, 내부 ID, 참조경로, 보호파일, Scope와 Limitation 확인
- 전체 Diff 자체검토

검증이 실패하면 승인범위 안에서 한 번 자체 수정하고 다시 검증한다.

두 번째 검증도 실패하면 Stage 또는 Commit하지 않고 중단결과를 보고한다.

# Phase 4 — Finalize

검증이 통과하면 scripts/invoke-aer-closure.ps1의 Finalize를 실행한다.

스크립트에 다음을 제공한다.

- Closure Mode
- Target Branch
- Expected Base Commit
- 실제 허용 변경파일 목록
- Proposed Commit Title
- 보호파일 허용 여부
- Push 권한

스크립트가 다음을 수행하게 한다.

- 실제 변경범위 재검사
- repository validation 재실행
- git diff --check
- 승인파일만 명시적으로 Stage
- Cached 파일목록 검증
- 단일 Commit
- Push 전 원격기준 재검사
- 비강제 Push
- 로컬·원격 HEAD 확인

No-op이면 빈 Commit을 만들지 않는다.

# Phase 5 — Final Report

다음만 간결하게 보고한다.

Handoff ID:
Closure Mode:
Approved Conclusions Reflected:
Files Created:
Files Modified:
Files Intentionally Not Modified:
Validation Result:
Warnings or Unresolved Issues:
Commit:
Push:
Next Baseline Commit:

정상 경로에서는 Diff, Stage, Commit 또는 Push 승인을 다시 요구하지 마라.
전체 파일 본문이나 내부 Handoff를 반복 출력하지 마라.

# Autonomous Stop Rule

다음 중 하나라도 존재하면 Commit 전에 중단한다.

- 승인상태, Closure Mode 또는 Git Permission 오류
- 승인결론의 실질적 모순
- 승인범위를 넘어선 일반화
- 예상하지 않은 보호파일 또는 버전 변경
- 기존 Object ID 또는 경로 충돌
- 필요한 근거파일 부재
- 설명되지 않은 Working Tree 변경
- Branch, Expected Base Commit 또는 Remote Base 불일치
- Merge 또는 Rebase 진행 중
- 검증 재실패

임의 Stash, reset --hard, clean, merge, rebase, amend 또는 force-push를 수행하지 마라.
```

---

## 3. Manual Fallback Prompt

Use Manual Closure only when the Handoff permission is not Autonomous Closure or when the human explicitly requests staged review.

Manual sequence:

1. inspect the Handoff and repository,
2. report the minimum sufficient change set,
3. wait for Apply approval,
4. apply and validate,
5. present one concise Diff summary,
6. follow the exact Stage, Commit, and Push permission stated in the Handoff.

Default Manual Git Permission:

```text
Apply Only
```

Manual approval at one step does not authorize a later Git step.

---

## 4. Git Safety

Never run:

- `git add .`
- `git commit --amend`
- `git reset --hard`
- `git clean -fd`
- `git rebase`
- `git push --force`
- `git push --force-with-lease`

Autonomous Closure may use one explicit-path Stage, one Commit, and one non-force Push only after validation and scope checks pass.

---

## 5. Expected Outcome

The ordinary AER research-close workflow should require:

- one approved semantic summary,
- one internal approved Handoff,
- one minimum repository edit,
- one automated validation sequence,
- one research Commit,
- one authorized non-force Push,
- one concise result report.

It must not require repeated manual copying or Git approval.
