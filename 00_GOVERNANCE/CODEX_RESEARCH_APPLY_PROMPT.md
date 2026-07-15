# Codex Research Handoff Application Prompt

Purpose:

Apply a human-approved AER Research Handoff to the repository through a minimum, validated, and human-controlled change process.

---

## 1. Required Inputs

Before using this prompt, provide either:

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

Default Git Permission:

Apply Only

---

## 2. Standard Application Prompt

Use the following prompt in a new Codex session.

```text
현재 AER 저장소에서 다음 문서를 먼저 읽어라.

- AGENTS.md
- 00_GOVERNANCE/RESEARCH_HANDOFF_SPEC.md
- 00_GOVERNANCE/RESEARCH_CLOSURE_POLICY.md
- 이번 작업의 승인된 Research Handoff

Research Handoff source:

[승인된 Handoff 본문 또는 파일 경로]

이번 작업은 승인된 Research Handoff와 AGENTS.md의 범위 안에서만 수행한다.

# Phase 1 — Pre-Application Review

이 단계에서는 파일을 수정하지 마라.

다음을 확인하라.

1. Approval Status가 Approved인지 확인한다.
2. Closure Mode를 확인한다.
3. Git Permission을 확인한다.
4. 현재 Git status를 확인한다.
5. 설명되지 않은 기존 변경이 있는지 확인한다.
6. 관련 기존 연구객체와 명명규칙을 읽는다.
7. 대상 Object ID와 파일경로가 기존 객체와 충돌하는지 확인한다.
8. 요청된 Closure Mode보다 가벼운 방식으로 충분한지 검토한다.
9. 승인결론, 근거, Scope, Limitation 사이에 모순이 있는지 확인한다.
10. 최소 변경파일 집합을 제안한다.

다음 형식으로만 보고하라.

Handoff ID:

Approval Status:

Requested Closure Mode:

Minimum Sufficient Closure Mode:

Git Permission:

Current Git Status:

Proposed Files to Create:

Proposed Files to Modify:

Files to Inspect Only:

Protected Files Affected:

Duplicate Documentation Risk:

Stop Condition:

Recommendation:

Phase 1에서는 파일 생성·수정·삭제, Stage, Commit, Push를 수행하지 마라.

# Phase 2 — Application

인간이 Phase 1의 최소 변경안을 승인한 경우에만 수행한다.

1. 승인된 파일만 생성 또는 수정한다.
2. 기존 파일을 수정하기 전에 전체 내용을 읽는다.
3. 명시적으로 대체되지 않은 기존 내용을 보존한다.
4. 승인결론보다 강한 표현을 추가하지 않는다.
5. Fact, Observation, Inference, Decision, Assumption, Open Problem을 구분한다.
6. Scope, Limitation, Unresolved Question을 보존한다.
7. 신규 또는 복원 파일에는 실질적인 본문을 작성한다.
8. 0바이트 파일이나 placeholder를 생성하지 않는다.
9. 파일명과 내부 Object ID를 일치시킨다.
10. 참조하는 저장소 경로가 존재하는지 확인한다.
11. README, CHANGELOG, CURRENT_STATE는 Handoff가 명시적으로 허용한 경우에만 수정한다.
12. Git Stage, Commit, Push는 수행하지 않는다.

# Phase 3 — Validation

적용한 실제 변경파일을 배열로 구성한다.

PowerShell 예시:

$Expected = @(
  "상대경로1",
  "상대경로2"
)

실행정책으로 차단되는 경우 현재 PowerShell 프로세스에만 임시 허용할 수 있다.

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

다음 검증을 실행한다.

.\scripts\validate-research-close.ps1 `
  -Mode <Lightweight|Standard|Release> `
  -ExpectedFiles $Expected

추가로 다음을 확인한다.

- git status --short
- git diff --check
- 변경파일 목록
- 신규 또는 복원 파일의 크기가 0보다 큰지
- 파일명과 내부 ID 일치
- 참조경로 존재 여부
- 보호파일의 비승인 변경 여부
- 승인된 Scope와 Limitation 유지 여부

검증결과가 FAILED이면:

- Stage 또는 Commit을 제안하지 않는다.
- 실패원인을 보고한다.
- 승인 없이 수정범위를 확대하지 않는다.

# Phase 4 — Change Report

다음 형식으로 간결하게 보고한다.

Handoff ID:

Closure Mode:

Files Created:

Files Modified:

Files Intentionally Not Modified:

Validation Result:

Warnings:

Unresolved Issues:

Proposed Commit Title:

Current Git Permission:

Next Required Approval:

전체 파일 본문을 답변에 반복 출력하지 마라.

사용자가 VS Code Diff에서 변경내용을 검토할 수 있게 한다.

# Git Permission Boundary

Analysis Only:

- 저장소 검사와 변경안 제안만 가능
- 파일 수정 금지

Apply Only:

- 승인파일 적용과 검증까지 가능
- Stage, Commit, Push 금지

Stage After Review:

- 인간이 Diff를 승인한 뒤 명시된 파일만 Stage 가능

Commit After Review:

- 인간의 별도 승인 후 단일 Commit 가능

Push After Review:

- Commit 완료 후 인간의 별도 승인으로만 Push 가능

다음 명령은 명시적 개별 승인 없이는 실행하지 마라.

- git add .
- git commit --amend
- git reset --hard
- git clean -fd
- git rebase
- git push --force
- git push --force-with-lease

# Stop Rule

다음 중 하나라도 존재하면 파일 수정 전에 중단한다.

- Approval Status가 Approved가 아님
- Closure Mode 누락
- Git Permission 불명확
- 승인결론 간 모순
- 기존 Object ID와 충돌
- 근거 없는 Principle 생성 요청
- 보호파일 변경의 정당성 부족
- 승인범위를 넘어선 일반화
- 필요한 근거파일을 찾을 수 없음
- 현재 작업 디렉터리에 설명되지 않은 기존 변경이 존재함
- 신규 또는 복원 파일의 실질적 본문을 구성할 근거가 부족함
```

---

## 3. Recommended Workflow

### Step 1

ChatGPT 연구논의를 종료하고 승인된 Research Handoff를 생성한다.

### Step 2

Handoff를 Codex에 직접 제공하거나 작업용 파일 경로를 지정한다.

### Step 3

Standard Application Prompt의 Phase 1만 실행한다.

### Step 4

인간이 최소 변경파일 집합을 검토하고 승인한다.

### Step 5

Codex가 Phase 2와 Phase 3을 실행한다.

### Step 6

인간이 VS Code Diff를 한 번 검토한다.

### Step 7

Git Permission 범위에 따라 Stage, Commit, Push를 각각 승인한다.

---

## 4. Default Safety Position

Default permission:

Apply Only

Permitted:

- repository inspection,
- approved file editing,
- validation,
- concise change reporting.

Not permitted:

- Stage,
- Commit,
- Push.

---

## 5. Expected Outcome

The ordinary AER research-close workflow should require:

- one approved Handoff,
- one Codex pre-application review,
- one minimum repository edit,
- one automated validation,
- one human diff review,
- one research Commit,
- optional Push approval.

It must not require repeated manual copying of full research documents.
