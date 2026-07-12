# Research Session Log

Session ID: SESSION-003

Title: Proposal-Stage Strategy Reasoning Model

Date Started: 2026-07-06

Date Closed: 2026-07-13

Status: Closed

Research Domain: AX Engineering Thinking Framework

Related Sprint: Sprint-002 Extension

Related Open Problem: OP-001 PM Linkage Criteria

Approved Research Commit Proposal:

RC-003 AETF Proposal-Stage Strategy Reasoning Model

---

# 1. Session Objective

본 세션의 목적은 공공부문 IT·AX·ISP·정보시스템 구축 제안에서
제안 PM이 다음 판단을 수행하는 사고구조를 도출하는 것이다.

1. RFP를 기반으로 사업의 본질을 해석한다.
2. 사업목적과 요구사항을 고객의 변화 관점으로 재구성한다.
3. 요구사항과 회사 자산을 결합하여 전략을 생성한다.
4. 개별 전략을 하나의 논리적 흐름으로 통합한다.
5. 평가배점·페이지·시간·발표조건에 따라 자원을 배분한다.
6. 불완전한 정보를 전제로 부족정보를 식별한다.
7. 추가정보 입력 시 영향받는 영역만 선택적으로 재분석한다.

---

# 2. Research Background

Sprint-002에서는 다음 사고방향이 확정되었다.

- AETF는 프로젝트별 Tailoring이 가능한 사고 Framework이다.
- RFP는 고객이 공식적으로 표현한 사고의 결과물이다.
- 분석은 명시적 사실에서 시작한다.
- 문서는 선형적 요약이 아니라 사실 간 네트워크로 검증한다.
- 논리적 결손이 발견되는 경우에만 가설을 생성한다.
- 연구는 사례 → 패턴 → Framework의 귀납적 방식으로 수행한다.

본 세션은 Sprint-002의 다음 Open Problem을 구체화하기 위해 시작되었다.

> PM은 어떤 사고 절차를 통해 두 명시적 사실이 논리적으로 연결된다고 판단하는가?

---

# 3. Initial Research Scope

## Included

- AX 프로젝트 생애주기 중 사업수주·제안단계
- RFP 기반 사업이해
- 제안전략 생성
- 전략 간 통합기준
- 평가배점·페이지·시간에 따른 자원배분
- 정보 부족 상태에서의 점진적 재분석

## Excluded

- 전체 프로젝트 수행방법론
- 영업 또는 VRB의 사업참여 최종의사결정
- 가격전략
- 경쟁사 점수예측
- 제안서 페이지 내부의 미세 편집절차
- 모든 예외상황에 대한 세부 규칙
- RAG 또는 AI Agent 구현

---

# 4. Research Method

본 연구는 원칙을 먼저 설계하지 않고 다음 방식으로 수행하였다.

실무경험 인터뷰

↓

반복 판단패턴 추출

↓

초기 사고모델 구성

↓

서로 다른 RFP에 반복 적용

↓

유지되는 원칙과 보정이 필요한 조건 구분

↓

1차 범용성 판단

↓

정보 보강 및 점진적 재분석 구조 추가

연구과정에서 사용자에게 실제 제안 PM 경험을 질문하고,
답변에서 관찰된 반복구조를 모델화하였다.

모델은 이후 다섯 개의 서로 다른 RFP에 적용하여 검증하였다.

---

# 5. Practical Observations from Proposal Work

## 5.1 Time Constraint

제안업무의 목적은 이론적으로 완전한 전략이 아니라,
제한된 시간 안에 경쟁력 있는 제안서를 완성하는 것이다.

따라서 완성도와 시간 사이의 판단이 필요하며,
후반부에는 전략을 동결하고 요구사항 누락과 형식위험을 우선 검수한다.

---

## 5.2 Strategy Development Is Organizational

제안 PM은 RFP 분석 후 목차와 업무를 배분한다.

전략은 개인이 완성하여 전달하는 것이 아니라,
기술담당자·수행인력·핵심 작성자와의 반복 논의를 통해 구체화된다.

전략의 실행 가능성은 수행조직과 합의되어야 하며,
합의된 내용은 제안서와 회의기록에 반영된다.

---

## 5.3 Flow Is a Core Quality Criterion

개별 전략이 각각 좋아도 하나의 흐름을 만들지 못하면
제안 전체의 설득력이 약해진다.

전략은 다음 중 하나의 방식으로 통합한다.

- 공통 고객효과
- 원인과 결과의 인과관계
- 단계적 확장구조

전략 간 연결성이 낮고 독립적으로 남는 전략은
전략적 가치가 낮다고 판단하였다.

---

## 5.4 Customer Effect Comes Before Company Differentiation

전략 제목은 회사의 기술이나 역량을 먼저 선언하는 것이 아니라,
고객에게 발생할 변화나 효과를 중심으로 표현한다.

회사 자산은 전략을 가능하게 하는 수단과 근거로 결합한다.

다음 구조가 반복적으로 확인되었다.

고객변화

+

실행수단

+

회사 자산 및 증거

---

## 5.5 Resource Allocation

제안의 물리적 공간과 작성시간은 균등 배분하지 않는다.

다음 요인을 함께 고려한다.

- 평가배점
- 심사위원 집중도
- 페이지 제한
- 발표시간
- 요구사항 누락 위험
- 기존 자료 재사용 가능성

관리·지원 영역은 기존 프레임워크를 재사용할 수 있으나,
배점이 높거나 사업 특성상 중요한 항목은 보호한다.

---

## 5.6 Completion and Freeze

전략 변경은 제안 초반과 중반에는 가능하지만,
최종 주간에는 원칙적으로 동결한다.

후반부에 구조 변경을 허용하는 경우는
참여자격·필수요구사항·실행불가능과 같은 치명적 문제로 제한한다.

그 외에는 표현과 근거를 보완하는 국지적 수정이 우선된다.

---

# 6. RFP Validation Cases

## Case 1: Financial Supervisory Service AX Consulting

Type:

Institutional AX strategy consulting

Validated Structure:

Environment and current-state analysis

→ AX direction and governance

→ Prioritized roadmap

→ Execution plan

→ Performance management

Primary Validation:

- Official purpose-based interpretation
- AS-IS and TO-BE generation
- Causal strategy sequence
- Evaluation-weight-based resource allocation

Limitation:

Actual company assets were not provided.

---

## Case 2: KAMCO National Property AX Consulting

Type:

Execution-oriented AX consulting

Validated Structure:

Readiness diagnosis

→ AI demand and task discovery

→ Platform and data design

→ Feasibility validation

→ Follow-up implementation package

Primary Validation:

- Transition from strategy consulting to implementation preparation
- Page allocation under a 200-page constraint
- Protection of high-weight management and technical areas

Limitation:

Final competitive differentiation could not be validated.

---

## Case 3: Goryeong County AX Strategy Research

Type:

Regional policy and public-service AX planning

Validated Structure:

Regional and administrative diagnosis

→ Selection of citizen-impact services

→ Funding strategy

→ Data and governance foundation

→ Institutional execution system

Primary Validation:

- Integration of broad and dispersed requirements
- Selection and concentration across seven policy fields
- Early declaration of a core strategy located later in the required table of contents

Limitation:

Applicability to non-public proposals remained unverified.

---

## Case 4: National Medical Center Public Healthcare AI ISP

Type:

Complex public healthcare information strategy planning

Validated Structure:

Integrated public healthcare system redesign

→ AI service target model

→ Healthcare data ecosystem

→ Cloud, DR and security

→ Governance and implementation roadmap

Primary Validation:

- Independent strategic importance of data requirements
- Integration of medical, data, infrastructure and governance assets
- Protection of technical architecture under page constraints

Limitation:

Actual integrated company capability was not tested.

---

## Case 5: Incheon Airport Data Platform Implementation

Type:

Complex information-system implementation

Validated Structure:

Data integration

→ Data trust and governance

→ Self-service utilization

→ AI and analytics expansion

→ Safe transition and operational settlement

Primary Validation:

- Applicability beyond consulting and ISP
- Need to connect strategy to target architecture
- Need to include migration, performance, testing and parallel operation
- Need to respect restricted presentation order and anonymity requirements

Limitation:

The detailed task specification and restricted ISP outputs were not fully available.

---

# 7. Repeated Patterns Identified

다섯 사례에서 다음 패턴이 반복적으로 유지되었다.

1. 공식 입력자료를 우선한다.
2. 사업목적을 고객의 AS-IS와 TO-BE 변화로 변환한다.
3. 요구사항·제약·회사 자산의 결합지점에서 전략을 생성한다.
4. 전략 제목은 고객효과를 중심으로 표현한다.
5. 개별 전략은 공통효과 또는 인과관계로 통합한다.
6. 평가배점·페이지·시간·발표조건에 따라 자원을 비대칭 배분한다.
7. 수행 가능성과 계약적 책임을 전략과 연결한다.
8. 요구사항 누락 및 결격성 위험을 우선 검수한다.
9. 구축형 사업은 목표 아키텍처와 구현구조의 성립 가능성을 확인한다.
10. 정보 부족 시 결론의 확정도를 구분한다.
11. 부족정보를 식별하고 추가정보 입력 시 영향영역만 재분석한다.
12. 개별 예외상황을 모두 사전에 규칙화하지 않는다.

---

# 8. Model Evolution During the Session

## Initial Form

초기 모델은 다음 구조였다.

사업목적·핵심요구사항

×

회사 자산

=

제안전략

---

## First Expansion

제안서 작성환경을 반영하여 다음 요소가 추가되었다.

- 평가배점
- 페이지 제한
- 발표시간
- 요구사항 누락
- 전략 동결
- 수행 책임

---

## Second Expansion

복잡 구축형 RFP를 통해 다음 조건이 추가되었다.

- 선행 ISP 및 공식 제한자료
- 목표 아키텍처
- 데이터 이관
- 성능과 테스트
- 병행운영과 안정화
- 익명성 및 제출형식 위험

---

## Final Approved Form

공식 입력자료

↓

사업목적·현황·요구사항·제약 해석

↓

고객 AS-IS와 TO-BE 도출

↓

회사 및 컨소시엄 자산과 수행조건 결합

↓

효과 중심 전략 생성

↓

공통효과 또는 인과관계로 통합

↓

평가·페이지·시간·발표조건에 따른 배치

↓

수행 가능성·기술적 실현성·결격 위험 검증

↓

정보 충분성 판정

↓

부족정보 요청

↓

추가정보 입력 시 영향영역 선택 재분석

↓

결과와 확정도 갱신

---

# 9. Information Sufficiency Model

분석결과는 다음 세 상태로 구분한다.

## Confirmed

현재 확보된 공식정보와 근거만으로 결론을 확정할 수 있음

## Conditional

방향은 타당하지만 회사 자산·기술조건·고객정보 등의 확인이 필요함

## Deferred

핵심정보가 없어 결론을 확정할 수 없음

추가정보는 다음 세 범주로 구분한다.

## Essential

없으면 전략 또는 수행 가능성을 확정할 수 없음

## High-Value

없어도 기본 골격은 만들 수 있으나
차별성과 정확도를 크게 개선함

## Supporting

표현과 세부설계를 개선하지만
핵심결론을 크게 바꾸지 않음

---

# 10. Selective Reanalysis Rule

추가정보가 입력되면 전체 분석을 자동으로 다시 수행하지 않는다.

해당 정보가 영향을 주는 계층부터 재분석한다.

Examples:

회사 실적 추가

→ 전략 근거와 차별성 재분석

선행 ISP 추가

→ 목표 아키텍처와 기술전략 재분석

평가배점 변경

→ 페이지·시간·발표 자원배분 재분석

인력·컨소시엄 정보 추가

→ 수행 가능성과 역할구조 재분석

사업목적 또는 공식범위 변경

→ AS-IS·TO-BE와 전체 전략 재분석

---

# 11. Decisions Approved in This Session

다음 사항을 승인하였다.

1. 공공 IT 제안단계에 적용 가능한 전략 사고모델을 AETF 연구자산으로 채택한다.
2. 모든 정보가 확보되기 전에도 현재 공식정보로 기본 골격을 생성한다.
3. 분석결과의 확정도를 Confirmed, Conditional, Deferred로 구분한다.
4. 보강정보를 Essential, High-Value, Supporting으로 분류한다.
5. 추가정보 입력 시 전체가 아니라 영향받는 영역만 선택적으로 재분석한다.
6. 전략은 고객효과를 중심으로 표현한다.
7. 전략은 공통효과 또는 인과관계로 통합한다.
8. 구축형 사업에서는 목표 아키텍처와 기술적 실현성을 확인한다.
9. 요구사항 누락과 결격성 위험을 최종검수의 우선순위로 둔다.
10. 개별 예외규칙의 무한 확장을 금지한다.
11. 본 모델을 완전한 제안방법론이나 세부 작성매뉴얼로 확대하지 않는다.

---

# 12. Rejected or Deferred Approaches

## Rejected

- 처음부터 완전한 정보를 요구한 뒤 분석을 시작하는 방식
- 모든 RFP 유형별 예외처리를 사전에 규칙화하는 방식
- 회사 차별성을 고객효과보다 먼저 제시하는 방식
- 개별 전략을 통합하지 않고 병렬로 유지하는 방식
- 추가정보가 입력될 때 전체 분석을 항상 처음부터 반복하는 방식
- 제안서 미세 편집절차를 Framework의 핵심으로 포함하는 방식

## Deferred

- 정보 충분성의 정량척도
- 실제 회사 자산을 입력한 경쟁전략 검증
- 운영·유지관리 사업 적용
- 단순 장비·솔루션 납품사업 적용
- 민간기업 제안 적용
- 가격전략과 경쟁사 대응
- LLM 또는 Agent 기반 자동화 구현

---

# 13. Generalizability Assessment

## First-Level Validated Domain

- 공공부문 AX 전략
- 공공부문 ISP·ISMP
- AI 및 데이터 플랫폼 컨설팅
- 복합 정보시스템 구축 제안
- 사업수주 단계의 사업이해 및 전략 골격 생성

## Unvalidated Domain

- 운영·유지관리 사업
- 단순 장비 또는 솔루션 납품
- 연구개발 사업
- 민간기업 제안
- 가격전략
- 경쟁사 예측
- 실제 자산을 반영한 최종 차별화 전략

Conclusion:

현재 모델은 공공 IT·AX·ISP·정보시스템 구축 제안단계에서
1차 범용성을 가진 것으로 판단한다.

모든 제안사업에 대한 완전한 범용성은 주장하지 않는다.

---

# 14. Relationship to OP-001

본 연구는 OP-001에 대해 다음 수준의 답을 제공하였다.

PM은 명시적 사실을 다음 방식으로 연결한다.

1. 사업목적과 요구사항이 동일한 고객변화를 향하는지 확인한다.
2. 요구사항과 평가기준이 일치하는지 교차 검증한다.
3. 전략과 회사 자산·수행조건이 실제로 연결되는지 검증한다.
4. 개별 전략이 공통효과 또는 인과관계를 형성하는지 확인한다.
5. 연결이 성립하지 않으면 논리적 결손으로 식별한다.
6. 정보 부족인지 구조적 모순인지 구분한다.
7. 정보 부족이면 추가정보를 요청하고 판단을 보류한다.
8. 구조적 모순이면 전략 또는 사업해석을 수정한다.

그러나 다음 사항은 아직 완전히 해결되지 않았다.

- 연결 강도의 판정기준
- 정보 충분성의 정량적 척도
- 두 사실이 직접 연결되는지 중간가설이 필요한지 판단하는 기준
- 상충하는 공식정보 간 우선순위

따라서 OP-001은 부분 해결 상태로 유지한다.

---

# 15. Repository Impact

본 세션 결과는 다음 연구객체로 분리하여 저장한다.

- Principle
- Evidence
- Reasoning
- Decision
- Research Log
- Open Problem Update

본 연구는 다음을 변경하지 않는다.

- AER Governance
- AER Specification
- AER Operation Rules
- AER Project Charter
- AER Research Philosophy
- AER Repository Structure

AER 구조버전 변경은 필요하지 않다.

---

# 16. Next Research Direction

다음 연구주제는 본 세션에서 확정하지 않는다.

후보는 다음과 같다.

- OP-001의 연결 판단기준 심화
- 정보 충분성 판정척도
- 회사 자산 입력구조
- 전략 변경 영향도 관리
- AETF Level 0과 본 모델의 관계
- 실제 제안사 자산을 적용한 재검증

Next Task Status:

Pending Human Direction

---

# 17. Session Closure

본 세션은 공공 IT 제안단계의 전략 생성 및 점진적 재분석 구조를
도출하고, 다섯 개 RFP를 통해 1차 범용성을 검증하였다.

본 결과는 승인된 RC-003에 따라 공식 연구객체로 분리하여 저장한다.

세부 예외처리와 미세 작성절차는 Framework 범위에서 제외한다.

Session Status:

Closed