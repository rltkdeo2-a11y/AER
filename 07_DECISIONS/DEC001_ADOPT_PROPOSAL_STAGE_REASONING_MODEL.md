# Decision Record

Decision ID: DEC-001

Title: Adopt the AETF Proposal-Stage Strategy Reasoning Model

Status: Approved

Decision Date: 2026-07-13

Effective Date: 2026-07-13

Decision Owner:

Human Co-Researcher

Research Domain:

AX Engineering Thinking Framework

Related Research Session:

SESSION-003 Proposal-Stage Strategy Reasoning Model

Related Evidence:

EV-001 Proposal-Stage Reasoning Model RFP Validation Cases

Related Reasoning:

RS-001 Generalizability of the Proposal-Stage Strategy Reasoning Model

Related Principle:

PR-001 Proposal-Stage Strategy Reasoning Principles

Related Research Commit Proposal:

RC-003 AETF Proposal-Stage Strategy Reasoning Model

Related Open Problem:

OP-001 PM Linkage Criteria

---

# 1. Decision Summary

공공부문 IT·AX·ISP·복합 정보시스템 구축 제안의 사업수주 단계에서
활용할 제안전략 사고모델을 AETF의 공식 연구자산으로 채택한다.

본 모델은 모든 정보가 완전하게 확보된 상태를 전제하지 않는다.

현재 확보된 공식정보를 기반으로 사업의 기본 골격과 전략구조를 생성하고,
각 결론의 확정도와 부족정보를 식별한다.

이후 추가정보가 입력되면 전체 분석을 자동으로 반복하지 않고,
해당 정보가 영향을 주는 영역만 선택적으로 재분석하여
전략·근거·수행 가능성·확정도를 갱신한다.

---

# 2. Decision Context

실제 제안업무에서는 다음 정보가 최초부터 완전하게 주어지지 않는다.

- RFP와 과업내용서
- 수정공고
- 사업설명회 및 공식 질의답변
- 선행 ISP·ISMP
- 제한 열람자료
- 현행 시스템과 데이터 현황
- 회사 실적과 방법론
- 투입인력
- 제품과 기술자산
- 컨소시엄 역할
- 실제 수행조직의 실행 가능성

모든 정보가 확보될 때까지 분석을 시작하지 않으면
초기 목차설계·업무배분·전략회의를 수행하기 어렵다.

반대로 부족정보를 임의 추정으로 확정하면
전략의 신뢰성과 실행 가능성이 낮아진다.

따라서 불완전한 정보에서도 현재 가능한 골격을 생성하고,
부족정보와 가정을 명시적으로 관리하는 구조가 필요하다.

---

# 3. Evidence Considered

본 결정은 다음 다섯 개 RFP 사례의 반복 검증결과를 근거로 한다.

1. 금융감독원 AX 컨설팅
2. 한국자산관리공사 국유재산 AX 컨설팅
3. 고령군 인공지능 전환 전략 수립
4. 국립중앙의료원 공공의료 AI ISP
5. 인천공항 데이터플랫폼 구축사업

각 사례는 다음 측면에서 차이가 있었다.

- 산업과 업무영역
- 컨설팅 또는 구축 여부
- 사업 산출물
- 요구사항의 구조와 수
- 평가배점
- 페이지 제한
- 발표조건
- 기술적 복잡도

그럼에도 다음 핵심 구조는 반복적으로 유지되었다.

공식 입력자료 해석

→ 고객 AS-IS와 TO-BE 도출

→ 요구사항·제약·회사 자산 결합

→ 고객효과 중심 전략 생성

→ 공통효과 또는 인과관계로 통합

→ 평가조건에 따른 자원배분

→ 수행 가능성과 결격 위험 검증

→ 부족정보 식별

→ 추가정보에 따른 선택적 재분석

---

# 4. Approved Decisions

## DEC-001-01. Adopt the Model

AETF의 제안단계 사고구조로
Proposal-Stage Strategy Reasoning Model을 채택한다.

---

## DEC-001-02. Start Before Information Is Complete

모든 정보가 확보될 때까지 분석을 중단하지 않는다.

현재 확보된 공식정보를 기반으로 다음을 우선 생성한다.

- 사업의 본질
- 고객 AS-IS
- 고객 TO-BE
- 전략의 기본 골격
- 전략 간 흐름
- 핵심메시지
- 현재 가정
- 결론의 확정도
- 보강 필요정보

---

## DEC-001-03. Separate Official Information from Assumptions

공식자료에서 확인된 사실과
분석자가 생성한 가정·추론을 구분한다.

정보 부족을 근거 없는 확정으로 대체하지 않는다.

가정이 필요한 경우 다음을 기록한다.

- 가정의 내용
- 가정이 필요한 이유
- 영향을 받는 결론
- 가정이 틀릴 경우의 변경영역

---

## DEC-001-04. Classify Conclusion Status

주요 분석결과는 다음 상태로 구분한다.

### Confirmed

현재 공식정보와 근거만으로 결론을 확정할 수 있음

### Conditional

현재 방향은 타당하지만
추가적인 회사 자산·기술조건·고객정보 확인이 필요함

### Deferred

핵심정보가 부족하거나 충돌하여
현재 결론을 확정할 수 없음

이 상태는 분석자의 주관적 자신감이 아니라
근거와 정보 충분성의 상태를 나타낸다.

---

## DEC-001-05. Classify Additional Information

보강정보는 다음과 같이 분류한다.

### Essential Information

없으면 전략·수행 가능성·참여 가능성을 확정할 수 없는 정보

### High-Value Information

없어도 기본 골격은 만들 수 있으나
차별성·정확도·우선순위를 크게 개선하는 정보

### Supporting Information

표현과 세부설계를 개선하지만
핵심결론을 크게 변경하지 않는 정보

모든 부족정보를 동일한 우선순위로 요청하지 않는다.

---

## DEC-001-06. Explain Information Requests

추가정보를 요청할 때 다음을 함께 제시한다.

- 필요한 정보
- 필요한 이유
- 영향을 받는 전략 또는 산출물
- 미제공 시 유지할 가정
- 미제공 시 결론의 상태

단순한 정보 체크리스트만 제시하지 않는다.

---

## DEC-001-07. Use Selective Reanalysis

추가정보가 입력되면 먼저 영향범위를 판단한다.

### Local Impact

전략 근거·차별성·표현·Key Point 등의 국지적 변경

### Structural Impact

기술전략·아키텍처·구축범위·수행방안의 변경

### Fundamental Impact

사업목적·AS-IS·TO-BE·전체 전략구조의 변경

정보의 영향수준에 따라 필요한 계층만 재분석한다.

전체 재분석을 기본값으로 사용하지 않는다.

---

## DEC-001-08. Generate Strategy from an Intersection

전략은 요구사항만을 요약하여 생성하지 않는다.

다음 요소의 결합지점에서 전략을 생성한다.

- 고객 사업목적
- 핵심 요구사항
- 제약조건
- 회사 및 컨소시엄 자산
- 투입 가능한 인력
- 수행체계
- 기술적 실현 가능성
- 계약적 책임

회사 자산이 제공되지 않은 경우
전략 골격은 생성할 수 있으나
최종 차별화와 수행 가능성은 조건부 또는 보류로 처리한다.

---

## DEC-001-09. Express Customer Effect First

전략 제목과 핵심메시지는
기술명이나 회사역량보다 고객에게 발생할 변화와 효과를 먼저 표현한다.

기술·제품·방법론·회사 자산은
고객효과를 실현하는 수단과 근거로 배치한다.

---

## DEC-001-10. Integrate Strategies into a Coherent Flow

개별 전략은 다음 중 하나 이상의 방식으로 통합한다.

- 공통 고객효과
- 원인과 결과
- 선행조건과 후속결과
- 단계적 확장
- 목표상태에 도달하는 변화순서

독립적으로 좋은 전략이라도
전체 흐름을 해치는 경우 수정·통합·제외할 수 있다.

---

## DEC-001-11. Validate Technical Realizability

구축형 사업에서는 전략이
최소한 다음 기술구조로 전개될 수 있는지 확인한다.

- 목표 아키텍처
- 시스템 구성
- 데이터 구조
- 제품과 솔루션 역할
- 기존 시스템 재사용 또는 전환
- 데이터 이관
- 인터페이스
- 성능과 가용성
- 보안
- 테스트
- 병행운영
- 안정화

상세설계까지 완료할 필요는 없으나,
전략이 실제 구현구조로 연결될 수 있어야 한다.

---

## DEC-001-12. Allocate Proposal Resources Asymmetrically

페이지·작성시간·발표시간은 균등하게 배분하지 않는다.

다음 기준에 따라 배분한다.

- 평가배점
- 요구사항 중요도
- 심사위원 집중도
- 누락 위험
- 페이지 제한
- 발표시간
- 차별화 가능성
- 기존 자료의 재사용 가능성

범용적이고 중복되는 내용은 압축할 수 있으나,
고배점·필수·기술적 핵심요소는 보호한다.

---

## DEC-001-13. Prioritize Requirement and Disqualification Risks

최종검수에서는 다음을 표현 완성도보다 먼저 확인한다.

- 필수요구사항 누락
- 참가자격 문제
- 제출서류 누락
- 익명성 위반
- 페이지 제한 초과
- 증빙 누락
- 발표조건 위반
- 제안서 작성지침 위반
- 실행 불가능한 확약
- 보안 및 계약조건 위반

결격성 위험을 제거한 이후
문장·오탈자·디자인을 보완한다.

---

## DEC-001-14. Freeze Strategy Before Submission

제안 초반과 중반에는 전략을 수정할 수 있다.

최종 단계에서는 전략을 원칙적으로 동결한다.

다음과 같은 치명적 문제에 한하여
후반부 구조변경을 허용한다.

- 필수요구사항 누락
- 참가 또는 평가자격 문제
- 기술적 실행불가능
- 계약적 책임수용 불가능
- 공식 수정공고
- 중대한 가정 오류
- 핵심 논리모순

그 외에는 전체 재설계보다 국지적 수정을 우선한다.

---

## DEC-001-15. Do Not Encode Every Exception

새로운 사례에서 문제가 발견되었다고
즉시 별도 규칙을 추가하지 않는다.

다음 순서로 판단한다.

1. 기존 상위 원칙으로 처리할 수 있는가?
2. 해당 사업만의 특수조건인가?
3. 다른 사례에서도 반복되는가?
4. 모델의 구조적 결함인가?
5. 기존 원칙의 수정이 필요한가?

반복적으로 검증된 구조적 한계일 경우에만
새로운 Research Commit을 통해 모델을 보정한다.

---

## DEC-001-16. Keep the Model at Framework Level

본 모델은 다음을 정의한다.

- 무엇을 확인하는가
- 무엇을 연결하는가
- 무엇을 검증하는가
- 어떤 기준으로 판단을 갱신하는가

다음은 본 모델의 핵심범위에 포함하지 않는다.

- 페이지별 세부 작성순서
- 문장별 수정절차
- 도식과 디자인 규칙
- 모든 회의의 운영절차
- 모든 예외상황의 처리방법
- 자동화 구현방식
- 제안 수행 전체 매뉴얼

필요한 경우 별도 Method 또는 Tool 객체로 연구한다.

---

# 5. Approved Application Scope

본 결정에 따라 현재 공식적으로 채택하는 적용범위는 다음과 같다.

## Included

- 공공부문 AX 전략 제안
- 공공부문 ISP·ISMP 제안
- AI 및 데이터 플랫폼 컨설팅 제안
- 복합 정보시스템 구축 제안
- 사업수주 단계의 사업이해
- 전략 골격 생성
- 전략 간 통합
- 평가조건 기반 자원배분
- 정보 충분성 관리
- 추가정보에 따른 선택적 재분석

## Excluded

- 실제 프로젝트 수행단계 전체
- 영업 및 VRB의 참여 최종결정
- 가격전략
- 경쟁사 전략예측
- 수주확률 예측
- 운영·유지관리형 사업
- 단순 장비 및 솔루션 납품
- 연구개발 사업
- 민간기업 제안
- 제안서 미세 작성방법론
- LLM 또는 Agent 자동화 구현

Excluded 항목은 금지대상이 아니라
현재 검증되지 않은 연구범위다.

---

# 6. Alternatives Rejected

## 6.1 Wait for Complete Information

모든 정보가 확보된 이후에만 분석을 시작하는 방식은 기각한다.

Reason:

실제 제안업무의 초기 목차설계·업무배분·전략회의를 지원할 수 없다.

---

## 6.2 Fill Information Gaps with Unmarked Assumptions

부족정보를 명시하지 않고
분석자의 추정으로 완성하는 방식은 기각한다.

Reason:

공식정보와 가설이 혼합되고,
전략의 신뢰성과 수행 가능성을 검증하기 어렵다.

---

## 6.3 Reanalyze Everything after Every Update

추가정보가 입력될 때마다
전체 분석을 처음부터 반복하는 방식은 기각한다.

Reason:

안정된 결론까지 불필요하게 변경되고,
변경원인과 영향범위를 추적하기 어렵다.

---

## 6.4 Encode All Exceptions in Advance

모든 사업유형과 예외상황을
사전에 규칙화하는 방식은 기각한다.

Reason:

Framework가 과도하게 비대해지고
실제 적용성이 낮아진다.

---

## 6.5 Lead with Company Differentiation

고객효과보다 회사 기술·실적·제품을 먼저 제시하는 방식을
기본 전략표현으로 채택하지 않는다.

Reason:

사업목적과 고객변화보다 공급자 중심의 설명이 앞설 수 있다.

---

## 6.6 Treat Every Strategy as Independent

개별 전략을 통합하지 않고
각각의 좋은 아이디어로 유지하는 방식은 기각한다.

Reason:

제안 전체의 논리적 흐름과 핵심메시지가 약화된다.

---

# 7. Consequences of the Decision

## 7.1 Positive Consequences

- 불완전한 정보에서도 분석을 시작할 수 있다.
- 초기 전략골격이 후속 논의의 기준점이 된다.
- 공식정보와 추정을 구분할 수 있다.
- 부족정보의 수집우선순위를 정할 수 있다.
- 추가정보에 따른 변경영역을 통제할 수 있다.
- 전략의 변경이력을 추적할 수 있다.
- 예외처리의 무한 확장을 억제할 수 있다.
- 컨설팅형과 구축형 사업을 동일 Core에서 Tailoring할 수 있다.

## 7.2 Negative or Limiting Consequences

- 초기 분석결과는 최종 전략이 아닐 수 있다.
- 정보 충분성 판정에 분석자의 판단이 개입된다.
- 회사 자산이 없으면 최종 차별화를 확정할 수 없다.
- 선택적 재분석의 영향범위 판단이 틀릴 수 있다.
- 공공 IT 외 사업에는 별도 검증이 필요하다.
- 모델의 존재만으로 수주성과가 보장되지 않는다.

---

# 8. Decision Boundaries

본 결정은 다음을 의미하지 않는다.

- AER 거버넌스 구조의 변경
- AETF 전체 구조의 완성
- 모든 제안유형에 대한 범용성 확정
- 수주 성공과 모델 간 인과관계 입증
- 다른 제안자에게 동일 품질로 전이 가능함의 입증
- 자동화 시스템 구현 승인
- 별도 소프트웨어 개발 승인

본 결정은 AETF 내 제안단계 사고원칙의 공식 채택만을 의미한다.

---

# 9. Conditions for Reconsideration

다음 조건 중 하나가 발생하면 본 결정을 재검토할 수 있다.

1. 새로운 사업유형에서 Core Reasoning Structure가 작동하지 않음
2. 동일한 실패가 복수 사례에서 반복됨
3. 기존 Principle 간 충돌이 발견됨
4. 실제 적용에서 전략품질을 저하시키는 구조적 문제가 확인됨
5. 정보 충분성 상태가 실무적으로 구분되지 않음
6. 선택적 재분석으로 중대한 영향영역을 반복적으로 누락함
7. 새로운 Evidence와 Reasoning이 기존 결론을 반박함
8. 인간 공동연구자가 적용범위 변경을 승인함

재검토는 새로운 Research Commit Proposal을 통해 수행한다.

---

# 10. Version and Repository Impact

Model Decision Version:

1.0

AER Repository Structural Version Impact:

None

AER Governance Impact:

None

AETF Research Asset Impact:

New Principle and Decision Adopted

Required Repository Objects:

- PR-001 Proposal-Stage Strategy Reasoning Principles
- EV-001 Proposal-Stage Reasoning Model RFP Validation Cases
- RS-001 Generalizability of the Proposal-Stage Strategy Reasoning Model
- DEC-001 Adopt the AETF Proposal-Stage Strategy Reasoning Model
- SESSION-003 Proposal-Stage Strategy Reasoning Model
- OP-001 Update

---

# 11. Decision Statement

다음 내용을 공식 결정으로 확정한다.

> 공공부문 IT·AX·ISP·복합 정보시스템 구축 제안의 사업수주 단계에서,
> 현재 확보된 공식정보를 기반으로 사업의 기본 골격과 전략을 생성하고,
> 각 결론의 확정도와 부족정보를 관리하며,
> 추가정보 입력 시 영향받는 영역만 선택적으로 재분석하는
> 상태 기반 제안전략 사고모델을 AETF의 공식 연구자산으로 채택한다.

본 모델의 현재 범용성은
공공 IT 제안의 사업이해와 전략 골격 생성 범위로 제한한다.

Decision Status:

Approved