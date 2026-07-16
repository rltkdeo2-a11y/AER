# Reasoning Record

Reasoning ID: RS-002

Title: RFP Bottleneck Reasoning Kernel

Status: Approved

Created: 2026-07-16

Updated: 2026-07-16

Research Domain:

AER Proposal-Stage Strategy Reasoning

Related Research Session:

SESSION-004 RFP Bottleneck Reasoning

Related Evidence:

EV-002 RFP Bottleneck Validation Cases

Related Principle:

PR-001 Proposal-Stage Strategy Reasoning Principles

Related Decision:

DEC-002 Adopt the RFP Bottleneck Reasoning Kernel

Related Open Problem:

OP-001 PM Linkage Criteria

Approval Basis:

09_RESEARCH_LOG/AER_RFP_Bottleneck_Handoff_2026-07-16.md

Related Research Commit Proposal:

RC-004 AER RFP Bottleneck Reasoning Kernel

---

# 1. Purpose

본 Reasoning Record는 RFP 기반 제안전략에서 Link를 생성·검증·승격하고, 전략을 실제로 변경할 수 있는 불확실성만 Bottleneck으로 식별하는 상세 추론절차를 정의한다.

목적은 가설 생성을 억제하는 것이 아니라 사용 권한과 승격조건을 통제하는 것이다.

---

# 2. Core Kernel

```text
RFP·과업내용서·평가기준·제안사 자산 입력

→ 사실·요구·평가·제약·자산·결손정보 분리

→ AS-IS·변화필요·TO-BE·고객효과 해석

→ 문제·원인·핵심 가설·전략 Candidate 생성

→ Source·Relation·Why·Target 최소 Link 확인

→ Candidate를 Working으로 승격

→ 복수 Working Strategy 구성

→ 전략이 의존하는 미확인 전제 또는 조건군 식별

→ 전제 실패 시 실제 변화 확인

→ 현실적 대체수단 확인

→ Bottleneck 여부 판정

→ 검증 또는 조건부 대응 선택

→ Decision Strategy 선택

→ 요구사항·평가기준·실행 가능성 통합검사

→ 추가 정보 발생 시 영향 Link와 전략만 국소 재분석
```

Runtime에서는 다음과 같이 압축한다.

```text
RFP 구조화
→ 핵심 가설과 복수 전략 생성
→ Working Strategy 구성
→ 전략을 바꾸는 불확실성 식별
→ Bottleneck 검증 또는 조건부 대응
→ Decision Strategy 선택
→ 국소 재분석
```

---

# 3. Link Governance

## 3.1 Minimal Link Structure

```text
Source
→ Relation
→ Why
→ Target
```

핵심 질문:

> 이 Source가 해당 Target의 해석·전략·결론을 실제로 지지하는가?

주제 유사성이나 단순 동시출현만으로 Link를 승격하지 않는다.

## 3.2 Use Authority

### Candidate

탐색과 핵심 가설 생성에는 사용할 수 있으나 전략결정에는 직접 사용하지 않는다.

### Working

조건부 전략과 비교대안 구성에 사용할 수 있다. 핵심전략으로 확정하기 전 추가 검증이 필요할 수 있다.

### Decision

핵심 문제정의, 대안선택, 차별화, 실행계획과 평가결론에 사용할 수 있다.

가설 생성은 관대하게 수행하되 승격은 엄격하게 통제한다.

## 3.3 Validation State

### Confirmed

현재 공식정보와 근거가 Link를 직접 지지하며 승인범위 안에서 사용할 수 있다.

### Conditional

방향은 타당하지만 전제, 기술조건, 고객정보 또는 제안사 자산의 확인이 필요하다.

### Deferred

판단에 필요한 정보가 부족하고 현재 핵심 검증대상으로 선택할 근거도 충분하지 않다.

### Invalid

근거가 Link를 지지하지 않거나 명백한 논리적·공식적 모순이 존재한다.

사용 권한과 검증 상태는 별도 축이다.

- `Working + Conditional`: 조건부 전략에는 사용할 수 있으나 핵심전략으로 확정할 수 없다.
- `Candidate + Deferred`: 탐색목록에는 유지할 수 있으나 현재 검증자원을 투입하지 않는다.

---

# 4. Bottleneck Definition

Bottleneck은 단순히 중요하거나 불확실한 Link가 아니다.

> 해당 전제를 유지할 때와 실패한 것으로 판단할 때 현재 전략의 선택, 핵심효과, 기술구조, 일정, 비용, 인력, 차별화 또는 필수요건이 실질적으로 변경되는 미확인 전제 또는 소수의 조건군이다.

Bottleneck 여부와 검증 우선순위는 분리한다.

```text
전략을 실제로 지배하는가?
→ 지금 추가 검증할 가치와 실행 가능성이 있는가?
```

---

# 5. Detailed Bottleneck Reasoning

## 5.1 Identify the Assumption

Working Strategy가 사실로 간주하고 있지만 아직 확인되지 않은 전제 또는 상호의존적인 조건군을 식별한다.

단순 미확인 정보 전체를 나열하지 않는다. 전략이 실제로 의존하는 항목만 대상으로 한다.

## 5.2 Test Failure Impact

미확인 전제를 거짓으로 가정하고 다음 변화를 검사한다.

- 전략 선택
- 고객효과 또는 핵심성과
- 기술구조
- 비용
- 일정
- 수행인력 또는 책임구조
- 경쟁 차별화
- 필수요건 충족

실질적 변화가 없다면 Bottleneck이 아니다.

## 5.3 Inspect Realistic Alternatives

같은 고객목표를 유지할 수 있는 현실적 대체수단을 검사한다.

대체수단은 다음 조건을 충족해야 한다.

- 현재 사업범위 안에서 실행 가능함
- 동일하거나 수용 가능한 고객효과를 유지함
- 기술·비용·일정·인력 제약을 위반하지 않음
- 단순한 추상적 가능성이 아니라 적용 가능한 경로임

현실적 대체수단이 있으면 Bottleneck에서 제외하거나 영향도를 낮춘다.

대체수단이 없고 전략가치가 유지될 수 없으면 Bottleneck으로 지정한다.

## 5.4 Select Current Action

```text
검증 가능하고 결과가 전략을 변경함
→ 즉시 검증

즉시 검증은 어렵지만 현실적 대체수단이 존재함
→ 조건부 진행 또는 제한적 병행

즉시 검증이 어렵고 안전한 대체수단이 없음
→ 보수적 전략으로 전환하거나 전략 보류
```

## 5.5 Record Reconsideration Trigger

다음 중 판단을 다시 열어야 하는 사건을 명시한다.

- 새로운 공식자료
- 발주기관 질의답변 또는 수정공고
- 기술검증 결과
- 제안사 자산 또는 수행인력 확인
- 비용·일정·보안·법규 조건 변경
- 실제 적용에서의 반복 실패

---

# 6. Six-Line Record Format

Bottleneck 검토에는 다음 최소 형식을 사용한다.

```text
대상 전략·범위:
미확인 전제 또는 조건군:
전제 실패 시 실제 변화:
현실적 대체수단:
현재 조치:
재검토 조건:
```

## 6.1 Target Strategy and Scope

전제가 영향을 주는 전략, 구성요소 또는 적용범위를 한정한다.

## 6.2 Unconfirmed Assumption or Condition Set

전략이 의존하지만 아직 확인되지 않은 전제나 상호연결된 조건을 기록한다.

## 6.3 Actual Change if the Assumption Fails

전략, 효과, 기술, 비용, 일정, 인력, 차별화 또는 필수요건 중 실제로 달라지는 것을 기록한다.

## 6.4 Realistic Alternative

동일한 고객목표를 유지할 수 있는 실행 가능한 대체경로를 기록한다. 없으면 없다고 명시한다.

## 6.5 Current Action

즉시 검증, 조건부 진행, 제한적 병행, 보수적 전환 또는 전략 보류 중 현재 결정을 기록한다.

## 6.6 Reconsideration Condition

어떤 정보나 사건이 발생할 때 판단을 다시 검토할지 기록한다.

---

# 7. Minimal Sufficient Recording

모든 중간 사고를 기록하지 않는다.

다음 정보만 최소한으로 보존한다.

```text
결정적 사실
핵심 가설
결론을 뒤집을 수 있는 미확인 전제 또는 조건군
전제 실패 시 실제 변화
현실적 대체수단
현재 결정 또는 조치
재검토 조건
```

기록은 판단을 복원할 수 있을 만큼 충분해야 하지만 Runtime 실행을 방해할 만큼 상세해서는 안 된다.

---

# 8. Local Reanalysis

추가 정보가 입력되면 전체 분석을 자동으로 반복하지 않는다.

```text
새 정보의 Source 확인
→ 직접 영향을 받는 Link 식별
→ 해당 Link에 의존하는 Working 또는 Decision Strategy 식별
→ Bottleneck 기록과 현재 조치 갱신
→ 영향을 받은 전략만 재분석
→ 유지된 결론과 변경된 결론 분리
```

사업목적이나 공식범위처럼 상위 Source가 변경된 경우에만 전체 전략구조 재검토를 허용한다.

---

# 9. Validation Stop Rule

서로 다른 구축형 RFP와 AX 전략·컨설팅형 RFP에서 Core Kernel의 작동성이 확인되었으므로 동일 유형 자료를 반복적으로 추가 검증하지 않는다.

다음 조건이 발생할 때만 검증을 재개한다.

```text
실제 적용에서 Bottleneck을 잘못 식별함
중요한 Bottleneck이 반복적으로 누락됨
현재 Kernel로 설명할 수 없는 구조적으로 다른 사업유형이 등장함
동일한 실패유형이 반복됨
Deferred Diagnostic Module의 필요성이 실제 사례에서 확인됨
```

---

# 10. Architecture Boundary

```text
Core Kernel
일상적으로 실행하는 최소 추론

Diagnostic Modules
판단이 막히거나 고위험인 경우에만 호출

Audit Layer
법적·계약적·분쟁성 또는 고위험 의사결정에서만 사용
```

설계는 충분히 깊게 유지하되 Runtime은 최소화한다.

Deferred Diagnostic Modules를 기본 Runtime 절차로 승격하지 않는다.

Deferred topics include:

- Bridge 인식론적·기능적 유형
- Direct/Mediated Link 정밀 판정
- Selection/Mechanism/Execution/Claim 진단
- Claim 실패유형
- Combined Bottleneck 연산
- 정량 검증 우선순위
- 상세 Link 메타데이터
- Audit 기록형식

각 Module은 반복 실패나 고위험 판단에서 실제 필요성이 확인될 때만 재개한다.

---

# 11. Scope and Limitations

본 Kernel은 다음 범위에서 1차 검증되었다.

- 공공부문 IT·AX·ISP·정보시스템 구축 제안
- 구축형 및 AX 전략·컨설팅형 RFP
- 제안단계의 전략 생성, 검증대상 선택과 조건부 대응

다음을 보장하지 않는다.

- 모든 산업과 제안유형에 대한 보편성
- 수주 성공 또는 평가점수
- 가격전략과 경쟁사 대응
- 실제 기술구현의 완전성
- Proposal Production Layer
- PPT 또는 슬라이드 자동생성

Reasoning Status:

Approved
