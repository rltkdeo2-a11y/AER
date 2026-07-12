# Open Problem Record

Open Problem ID: OP-001

Title: PM Linkage Criteria

Status: Partially Resolved

Priority: High

Created: 2026-07-06

Updated: 2026-07-13

Research Domain:

AX Engineering Thinking Framework

Related Sprint:

Sprint-002

Related Research Session:

SESSION-003 Proposal-Stage Strategy Reasoning Model

Related Evidence:

EV-001 Proposal-Stage Reasoning Model RFP Validation Cases

Related Reasoning:

RS-001 Generalizability of the Proposal-Stage Strategy Reasoning Model

Related Principle:

PR-001 Proposal-Stage Strategy Reasoning Principles

Related Decision:

DEC-001 Adopt the AETF Proposal-Stage Strategy Reasoning Model

---

# 1. Problem Statement

PM은 어떤 사고 절차를 통해
두 명시적 사실이 논리적으로 연결된다고 판단하는가?

예를 들어 다음 사실이 존재할 수 있다.

- 사업목적
- 사업범위
- 세부 요구사항
- 평가기준
- 제약조건
- 회사 자산
- 기술구조
- 수행조직
- 일정과 예산

PM은 이 사실들을 단순히 병렬적으로 나열하지 않는다.

각 사실 사이에 다음 관계가 성립하는지 판단한다.

- 동일한 목적을 향하는가?
- 원인과 결과인가?
- 선행조건과 후속결과인가?
- 요구사항과 수행수단인가?
- 평가기준과 대응내용인가?
- 전략과 실행근거인가?
- 공식정보와 가설이 충돌하지 않는가?

본 Open Problem은 이러한 연결판단의 일반적 기준을 연구한다.

---

# 2. Original Research Context

Sprint-002에서는 다음 사항이 확인되었다.

- RFP는 고객이 공식적으로 표현한 사고의 결과물이다.
- 분석은 명시적 사실에서 시작한다.
- 문서는 선형적으로만 읽지 않고 네트워크로 검증한다.
- 사업목적·사업범위·세부요구사항·평가기준을 교차 검증한다.
- 논리적 결손이 발견되는 경우에만 가설을 생성한다.

그러나 당시에는 다음 질문이 해결되지 않았다.

> 어떤 조건을 충족할 때 두 사실이 논리적으로 연결되었다고 판단할 수 있는가?

---

# 3. Research Progress from SESSION-003

SESSION-003에서는 공공 IT·AX·ISP·복합 정보시스템 구축 제안
RFP 다섯 건을 분석하였다.

분석결과, 제안단계에서 사실 간 연결은 다음 기준으로 검증할 수 있음이 관찰되었다.

## 3.1 Purpose Alignment

두 사실이 동일한 사업목적 또는 고객변화를 향하는가?

Example:

사업목적:

데이터 기반 행정 활성화

요구사항:

전사 데이터 통합, 품질관리, Self BI 구축

Interpretation:

세 요구사항이 데이터 접근성과 신뢰성, 활용성을 높여
동일한 고객변화에 기여하므로 연결 가능하다.

---

## 3.2 Requirement Alignment

한 사실이 다른 사실의 요구조건·수단·결과로 기능하는가?

Example:

Requirement:

AI 기반 분석서비스 구축

Required Condition:

표준화되고 검증된 데이터

Interpretation:

데이터 표준화와 품질관리는
AI 분석서비스의 선행조건으로 연결된다.

---

## 3.3 Evaluation Alignment

두 사실의 연결이 평가기준상 중요하게 다뤄지는가?

Example:

RFP Requirement:

데이터 이관계획

Evaluation Criterion:

기존 DW 특성을 고려한 데이터 수집 및 이관계획의 적정성

Interpretation:

요구사항과 평가기준이 직접 대응하므로
제안서에서 독립적인 근거와 수행방안이 필요하다.

---

## 3.4 Causal Alignment

한 사실이 다른 사실의 원인·선행조건·결과가 되는가?

Example:

분산 데이터 통합

→ 데이터 표준 및 품질 확보

→ 현업 분석 활용

→ AI 서비스 확장

Interpretation:

각 단계가 후속 단계의 선행조건으로 작동하면
인과적 전략흐름으로 연결할 수 있다.

---

## 3.5 Asset Alignment

회사 또는 컨소시엄 자산이
요구사항의 실제 수행수단으로 연결되는가?

Example:

Requirement:

다기관 의료데이터 표준화

Company Asset:

의료 DW·CDW 구축실적과 데이터 표준화 인력

Interpretation:

자산이 요구사항 수행에 직접 사용될 수 있고,
실적으로 입증 가능할 때 연결이 성립한다.

회사 자산이 제공되지 않은 경우
전략방향은 도출할 수 있으나
차별성과 수행 가능성은 확정하지 않는다.

---

## 3.6 Feasibility Alignment

연결된 주장이 기술·인력·일정·조직·예산·계약조건상 실행 가능한가?

Example:

Strategy:

실시간 데이터 기반 선제적 분석서비스 제공

Required Validation:

- 실시간 수집대상
- 원천시스템 부하
- 처리 아키텍처
- 성능목표
- 운영인력
- 일정 내 구현 가능성

Interpretation:

고객효과가 타당해도 이를 실현할 기술구조가 없으면
전략적 연결은 성립하지 않는다.

---

## 3.7 Evidence Alignment

연결을 공식정보·실적·방법론·산출물로 입증할 수 있는가?

Example:

Claim:

제안사는 데이터 품질을 지속적으로 관리할 수 있다.

Required Evidence:

- 품질관리 도구
- 유사사업 실적
- 품질지표
- 점검절차
- 전문인력

Interpretation:

입증자료가 없으면 연결은 가설 또는 조건부 판단으로 유지한다.

---

# 4. Current Linkage Test

SESSION-003 결과를 바탕으로 현재 사용할 수 있는 연결판단 질문은 다음과 같다.

## Step 1. Identify the Facts

연결하려는 두 요소가 무엇인지 명확히 구분한다.

Example:

Fact A:

사업목적

Fact B:

세부 요구사항

---

## Step 2. Identify the Relationship Type

두 사실의 관계가 다음 중 무엇인지 판단한다.

- 목적과 수단
- 문제와 해결
- 원인과 결과
- 선행조건과 후속결과
- 요구사항과 평가기준
- 요구사항과 회사 자산
- 전략과 기술구조
- 전략과 수행책임
- 공식정보와 보강정보

---

## Step 3. Apply the Alignment Criteria

다음 기준 중 어떤 기준을 충족하는지 확인한다.

- Purpose Alignment
- Requirement Alignment
- Evaluation Alignment
- Causal Alignment
- Asset Alignment
- Feasibility Alignment
- Evidence Alignment

모든 연결이 모든 기준을 충족할 필요는 없다.

다만 연결의 성격에 필요한 핵심 기준은 충족해야 한다.

Example:

사업목적과 전략의 연결

Required:

- Purpose Alignment
- Causal Alignment
- Feasibility Alignment

요구사항과 회사 실적의 연결

Required:

- Requirement Alignment
- Asset Alignment
- Evidence Alignment

---

## Step 4. Identify the Linkage Status

연결판단은 다음 상태로 구분한다.

### Confirmed Link

- 공식정보와 근거가 존재한다.
- 필요한 연결기준이 충족된다.
- 다른 공식정보와 충돌하지 않는다.
- 실행 가능성이 확인된다.

### Conditional Link

- 방향과 논리는 타당하다.
- 일부 자산·기술·고객정보가 미확인이다.
- 추가정보에 따라 수단이나 우선순위가 변경될 수 있다.

### Deferred Link

- 핵심정보가 없다.
- 공식정보가 상충한다.
- 실행 가능성을 판단할 수 없다.
- 연결을 확정하면 추정 의존도가 과도하다.

### Invalid Link

- 동일 목적을 향하지 않는다.
- 인과관계가 성립하지 않는다.
- 요구사항과 수단이 불일치한다.
- 기술적 또는 계약적으로 실행할 수 없다.
- 근거가 연결주장을 지지하지 않는다.

---

## Step 5. Determine the Required Action

### Confirmed Link

현재 모델과 전략에 반영한다.

### Conditional Link

가정과 부족정보를 표시하고
조건부 전략 또는 근거로 유지한다.

### Deferred Link

전략 확정을 보류하고
필요정보를 요청한다.

### Invalid Link

연결을 제거하거나
사업해석·전략·수행방안을 수정한다.

---

# 5. Information Gap versus Logical Gap

연결이 약한 경우 다음 두 상태를 구분해야 한다.

## 5.1 Information Gap

논리적으로 연결될 가능성은 있으나
판단에 필요한 정보가 부족한 상태

Example:

회사가 의료데이터 표준화 역량을 보유했는지 알 수 없음

Action:

회사 실적·인력·방법론을 추가 요청한다.

---

## 5.2 Logical Gap

필요한 정보가 존재해도
두 사실 사이의 관계 자체가 성립하지 않는 상태

Example:

공항 데이터플랫폼 사업에서
공항운영 데이터와 무관한 일반 챗봇 실적만으로
실시간 운영분석 역량을 주장함

Action:

연결을 제거하거나
다른 근거와 수행수단을 찾아야 한다.

---

# 6. Current Answer to OP-001

현재 연구결과에 따르면 PM은 다음 절차로
명시적 사실 간 연결을 판단한다.

1. 연결하려는 사실을 구분한다.
2. 두 사실 사이에 기대되는 관계유형을 정의한다.
3. 목적·요구사항·평가·인과·자산·실현성·근거의 정합성을 검증한다.
4. 연결을 Confirmed, Conditional, Deferred, Invalid로 판정한다.
5. 연결이 약한 원인이 정보 부족인지 논리적 결손인지 구분한다.
6. 정보 부족이면 추가정보를 요청한다.
7. 논리적 결손이면 전략 또는 사업해석을 수정한다.
8. 추가정보가 입력되면 영향을 받는 연결만 재검증한다.

이 절차는 제안단계의 사실 연결판단에 대한
현재까지의 실무적 답을 제공한다.

---

# 7. Remaining Open Questions

다음 사항은 아직 해결되지 않았다.

## 7.1 Linkage Strength

연결 강도를 어떤 기준으로 비교할 것인가?

Example:

- 직접 연결
- 간접 연결
- 다단계 연결
- 약한 연관
- 단순 병렬관계

현재는 질적 판단만 존재한다.

---

## 7.2 Minimum Evidence Threshold

어느 수준의 근거가 있어야
Conditional Link를 Confirmed Link로 변경할 수 있는가?

현재 사업유형별 기준이 다를 수 있다.

---

## 7.3 Intermediate Hypothesis

두 공식사실이 직접 연결되지 않을 때
어떤 조건에서 중간가설을 생성할 수 있는가?

Example:

사업목적

→ 중간가설

→ 세부전략

중간가설의 생성과 검증기준이 필요하다.

---

## 7.4 Conflict Resolution

두 공식정보가 충돌할 때
어떤 기준으로 우선순위를 정할 것인가?

Potential Factors:

- 법적 효력
- 문서의 최신성
- 평가기준
- 공식 질의답변
- 수정공고
- 발주기관 승인자료

---

## 7.5 Cross-Domain Transfer

현재 연결판단 기준이 다음 영역에서도 동일하게 작동하는가?

- 운영·유지관리
- 연구개발
- 단순 솔루션 납품
- 민간 제안
- 사전영업

---

# 8. Research Status Assessment

Resolved Elements:

- 연결판단의 주요 기준
- 사실 간 관계유형
- 정보 부족과 논리적 결손의 구분
- 연결상태의 질적 분류
- 연결상태별 후속조치
- 추가정보 입력 시 선택적 재검증

Unresolved Elements:

- 연결 강도의 척도
- 최소 근거수준
- 중간가설 생성기준
- 공식정보 충돌 시 우선순위
- 공공 IT 외 영역의 적용성

Resolution Assessment:

Partially Resolved

---

# 9. Next Research Trigger

다음 조건이 발생하면 OP-001 연구를 재개한다.

1. 동일한 사실에 대해 연결판단이 반복적으로 달라짐
2. Conditional과 Confirmed의 구분이 실무에서 작동하지 않음
3. 중간가설 없이는 전략흐름을 설명할 수 없는 사례가 발생함
4. 공식정보 간 충돌이 전략결정을 방해함
5. 공공 IT 외 사업에 모델을 적용함
6. 연결판단을 자동화하거나 도구화하려는 연구를 시작함

현재는 별도 연구를 즉시 시작하지 않는다.

다음 연구주제는 인간 공동연구자가 선택한다.

---

# 10. Open Problem Statement

현재 OP-001은 다음과 같이 유지한다.

> PM이 명시적 사실 간 논리적 연결을 판단하는 기본 절차와
> 정합성 기준은 도출되었다.
>
> 다만 연결의 강도, 최소 근거수준, 중간가설 생성,
> 공식정보 충돌의 우선순위는 아직 해결되지 않았다.

Open Problem Status:

Partially Resolved