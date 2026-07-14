# Evidence Record

Evidence ID: EV-001

Title: Proposal-Stage Reasoning Model RFP Validation Cases

Status: Approved

Version: 1.0

Created: 2026-07-13

Updated: 2026-07-15

Research Domain:

AX Engineering Thinking Framework

Summary:

서로 다른 다섯 개 공공 IT 제안 사례에 Proposal-Stage Strategy Reasoning Model을 적용하여, 사업유형이 달라져도 유지되는 공통 사고구조와 사업별 Tailoring 요소를 확인한 Evidence Record이다.

Related Research Session:

SESSION-003 Proposal-Stage Strategy Reasoning Model

Related Reasoning:

RS-001 Generalizability of the Proposal-Stage Strategy Reasoning Model

Related Principle:

PR-001 Proposal-Stage Strategy Reasoning Principles

Related Decision:

DEC-001 Adopt the AETF Proposal-Stage Strategy Reasoning Model

Related Research Commit Proposal:

RC-003 AETF Proposal-Stage Strategy Reasoning Model

Related Open Problem:

OP-001 PM Linkage Criteria

Initial Integration Commit:

4761da1

---

# 1. Recovery Note

본 파일은 최초 저장소 통합 과정에서 빈 파일로 Commit되었다.

본 복원본은 새로운 연구결과를 추가하여 작성한 것이 아니다.

다음 승인·보존 문서에 이미 기록된 사례와 관찰을 기반으로
Evidence 객체를 재구성하였다.

- SESSION-003 Proposal-Stage Strategy Reasoning Model
- RS-001 Generalizability of the Proposal-Stage Strategy Reasoning Model
- DEC-001 Adopt the AETF Proposal-Stage Strategy Reasoning Model
- RESEARCH_TIMELINE Sprint-002 Extension
- PR-001 Proposal-Stage Strategy Reasoning Principles

따라서 본 복구는 기존 승인결정의 근거 추적성을 회복하는 작업이며,
AETF 연구결론이나 적용범위를 변경하지 않는다.

---

# 2. Purpose

본 Evidence Record의 목적은 다음 질문을 검증하는 것이다.

1. 서로 다른 공공 IT 제안사업에서 동일한 핵심 사고구조가 유지되는가?
2. 전략결과가 특정 산업이나 사업유형에 관계없이 동일하게 반복되는가?
3. 공통적으로 유지되는 요소와 사업별로 달라지는 요소를 구분할 수 있는가?
4. 정보가 불완전한 상태에서도 초기 전략골격을 생성할 수 있는가?
5. 추가정보에 따라 전체가 아닌 영향영역만 재분석하는 구조가 필요한가?
6. 현재 근거로 어느 범위까지 모델의 범용성을 주장할 수 있는가?

---

# 3. Validation Design

본 연구는 원칙을 먼저 확정한 뒤 사례를 맞추는 방식으로 수행하지 않았다.

검증 흐름은 다음과 같다.

실무경험과 판단사례 확인

→ 초기 사고패턴 추출

→ 잠정 모델 구성

→ 서로 다른 RFP 사례에 반복 적용

→ 유지되는 구조와 변하는 구조 구분

→ 공통 패턴 추출

→ 적용범위와 한계 판단

검증사례는 다음과 같이 사업성격이 서로 다른 다섯 건으로 구성하였다.

1. 기관 단위 AX 전략 컨설팅
2. 실행과제 및 후속 구축준비형 AX 컨설팅
3. 지역정책 및 주민체감형 AX 전략
4. 복합 공공의료 AI ISP
5. 복합 데이터플랫폼 구축

---

# 4. Evidence Classification

본 문서는 다음을 구분한다.

## Fact

RFP·과업내용서·평가기준·제안조건 등 공식자료에서 확인된 사항

## Observation

사례 적용과정에서 반복적으로 확인된 현상

## Inference Boundary

Evidence만으로 확정하지 않고 별도 Reasoning Record에서 판단해야 하는 일반화

본 문서는 사례와 반복관찰을 기록한다.

모델의 범용성에 대한 최종 추론은
RS-001에서 수행한다.

---

# 5. Case Evidence

## 5.1 Case 1 — Financial Supervisory Service AX Consulting

Korean Title:

금융감독원 AX 컨설팅

Type:

Institutional AX strategy consulting

Observed Proposal Structure:

환경 및 현황분석

→ AX 방향과 거버넌스

→ 우선순위 로드맵

→ 실행계획

→ 성과관리

Validated Elements:

- 공식 사업목적에서 분석을 시작할 수 있었다.
- 현재 상태와 목표 상태를 AS-IS와 TO-BE로 구분할 수 있었다.
- 진단, 전략, 로드맵, 실행계획, 성과관리 사이에 인과적 흐름을 구성할 수 있었다.
- 평가배점에 따라 작성자원을 다르게 배분해야 한다는 판단이 유지되었다.
- 전략은 개별 AI 기술보다 조직 차원의 변화효과를 중심으로 표현하는 것이 적합하였다.

Tailoring Elements:

- 기관 단위 AX 추진체계
- 조직 및 업무진단
- 변화관리
- 과제 우선순위
- 단계별 이행로드맵
- 성과관리체계

Limitation:

실제 제안사의 실적·인력·방법론·기술자산이 제공되지 않아
최종 차별화와 수행 가능성은 검증하지 못했다.

Evidence Result:

Core Structure Maintained

---

## 5.2 Case 2 — KAMCO National Property AX Consulting

Korean Title:

한국자산관리공사 국유재산 AX 컨설팅

Type:

Execution-oriented AX consulting

Observed Proposal Structure:

AX 준비도 진단

→ AI 수요 및 과제발굴

→ 플랫폼과 데이터 설계

→ 실행 가능성 검증

→ 후속 구축 패키지

Validated Elements:

- 일반적인 전략수립보다 후속 구축을 위한 실행준비가 중심이 되었다.
- 동일한 Core를 유지하면서 산출물과 검증강도를 실행 중심으로 조정할 수 있었다.
- 200페이지 제한 아래에서 모든 영역을 균등하게 배분하는 방식이 적절하지 않았다.
- 관리·기술 영역도 평가배점과 누락위험이 높으면 보호해야 했다.
- 전략은 과제발굴에서 끝나지 않고 플랫폼·데이터·후속 구축조건으로 연결되어야 했다.

Tailoring Elements:

- AI 과제발굴
- 과제 우선순위
- 데이터 및 플랫폼 기반
- 실행 가능성
- 후속 구축범위
- 예산과 조달을 위한 구체화

Limitation:

회사 및 컨소시엄의 실제 자산이 입력되지 않아
최종 경쟁차별화는 검증하지 못했다.

Evidence Result:

Core Structure Maintained with Execution-Oriented Tailoring

---

## 5.3 Case 3 — Goryeong County AX Strategy Research

Korean Title:

고령군 인공지능 전환 전략 수립 연구용역

Type:

Regional policy and public-service AX planning

Observed Proposal Structure:

지역 및 행정현황 진단

→ 주민체감 서비스 선정

→ 재원전략

→ 데이터와 거버넌스 기반

→ 제도적 실행체계

Validated Elements:

- 넓게 분산된 요구사항을 그대로 병렬 나열하는 방식은 전략으로 충분하지 않았다.
- 여러 정책분야를 공통 고객효과와 실행조건으로 통합할 필요가 있었다.
- 7대 분야를 전수 검토하되 핵심 분야를 선택하여 집중하는 구조가 필요했다.
- 필수 목차상 뒤에 위치한 전략도 제안서 앞부분에서 핵심메시지로 먼저 제시할 수 있었다.
- 지역정책형 사업에서는 기술 외에도 재원·조례·거버넌스·주민체감 효과가 주요 수행조건으로 작동했다.

Tailoring Elements:

- 지역산업과 행정수요
- 주민체감 서비스
- 정책분야 선택과 집중
- 국비 및 공모재원
- 조례와 제도
- 지역 데이터 거버넌스

Limitation:

공공정책형 사례이므로 민간기업 제안에도 동일한 Tailoring이 작동하는지는 검증하지 못했다.

Evidence Result:

Core Structure Maintained with Regional-Policy Tailoring

---

## 5.4 Case 4 — National Medical Center Public Healthcare AI ISP

Korean Title:

국립중앙의료원 공공의료 AI 정보화전략계획 수립

Type:

Complex public healthcare information strategy planning

Observed Proposal Structure:

공공의료 정보체계 재설계

→ AI 서비스 목표모델

→ 의료데이터 생태계

→ 클라우드·DR·보안

→ 거버넌스와 이행로드맵

Validated Elements:

- 의료업무·AI 서비스·데이터·인프라·보안·거버넌스를 하나의 전략흐름으로 통합해야 했다.
- 데이터 요구사항은 단순 기술 세부사항이 아니라 독립적인 전략축으로 다뤄야 했다.
- 목표모델과 기술 아키텍처를 페이지 제약 때문에 과도하게 축소해서는 안 됐다.
- 의료 전문성, 개인정보, 보안, 클라우드, 재해복구 등의 제약조건이 전략의 실현 가능성을 직접 제한했다.
- 단일 회사역량만으로 모든 요구사항을 설명하기 어려워 복합 자산과 컨소시엄 구조가 필요했다.

Tailoring Elements:

- 의료정보시스템
- 공공의료 데이터
- AI 서비스 목표모델
- 개인정보와 의료규제
- 클라우드 및 재해복구
- 의료·데이터·인프라 전문조직

Limitation:

실제 회사와 컨소시엄의 통합 수행역량이 제공되지 않아
최종 자산조합의 적합성은 검증하지 못했다.

Evidence Result:

Core Structure Maintained with Healthcare and ISP Tailoring

---

## 5.5 Case 5 — Incheon Airport Data Platform Implementation

Korean Title:

인천공항 데이터플랫폼 구축사업

Type:

Complex information-system implementation

Observed Proposal Structure:

데이터 통합

→ 데이터 신뢰성과 거버넌스

→ 현업 Self-Service 활용

→ AI 및 분석서비스 확장

→ 안전한 전환과 운영정착

Validated Elements:

- 모델은 컨설팅과 ISP뿐 아니라 구축형 사업에도 적용 가능했다.
- 구축형 사업에서는 전략이 목표 아키텍처와 연결되어야 했다.
- 고객효과만으로는 전략을 확정할 수 없으며 실제 구현구조가 필요했다.
- 데이터 이관·인터페이스·성능·테스트·병행운영·안정화가 전략적 중요성을 가졌다.
- 익명성·발표순서·제출형식 등 형식적 조건도 결격위험으로 관리해야 했다.
- 구축형 사업에서는 기술실현성 검증강도가 컨설팅형보다 높아졌다.

Tailoring Elements:

- 목표 데이터 아키텍처
- 데이터 수집·저장·처리
- 기존 인프라와 제품구성
- 데이터 이관
- 성능과 가용성
- 테스트와 병행운영
- 전환 및 안정화

Limitation:

상세 과업내용서와 제한 열람 ISP 산출물이 완전히 제공되지 않아
세부 아키텍처와 이관계획은 확정하지 못했다.

Evidence Result:

Core Structure Maintained with Implementation Tailoring

---

# 6. Cross-Case Comparison

| Validation Dimension | FSS AX | KAMCO AX | Goryeong AX | NMC AI ISP | Incheon Airport Platform |
|---|---|---|---|---|---|
| Official-information-first analysis | Confirmed | Confirmed | Confirmed | Confirmed | Confirmed |
| AS-IS and TO-BE interpretation | Confirmed | Confirmed | Confirmed | Confirmed | Confirmed |
| Customer-effect-centered strategy | Confirmed | Confirmed | Confirmed | Confirmed | Confirmed |
| Strategy integration by effect or causality | Confirmed | Confirmed | Confirmed | Confirmed | Confirmed |
| Evaluation and page-based allocation | Confirmed | Confirmed | Confirmed | Confirmed | Confirmed |
| Company-asset validation | Deferred | Deferred | Deferred | Deferred | Deferred |
| Technical architecture validation | Supporting | High-Value | Supporting | Essential | Essential |
| Migration and transition validation | Supporting | High-Value | Supporting | High-Value | Essential |
| Disqualification-risk validation | Confirmed | Confirmed | Confirmed | Confirmed | Confirmed |
| Selective reanalysis requirement | Confirmed | Confirmed | Confirmed | Confirmed | Confirmed |

Note:

`Confirmed`는 각 사례에서 해당 사고요소의 필요성과 적용 가능성이 확인되었다는 의미다.

회사 자산에 대한 `Deferred`는 실제 회사정보가 충분히 제공되지 않아
최종 차별화와 수행 가능성을 확정하지 않았다는 의미다.

---

# 7. Repeated Cross-Case Observations

다섯 사례에서 다음 관찰이 반복되었다.

## Observation 1

분석은 숨은 의도에 대한 추측보다
RFP·과업내용서·평가기준·작성지침 등 공식정보에서 시작해야 했다.

## Observation 2

사업목적과 요구사항을 단순 요약하는 것보다
고객의 AS-IS와 TO-BE로 변환할 때 전략방향이 명확해졌다.

## Observation 3

전략은 요구사항만으로 완성되지 않았다.

고객목적·요구사항·제약·회사 자산·수행조건의 교차점이 필요했다.

## Observation 4

전략 제목은 제품·기술·회사역량보다
고객에게 발생할 변화와 효과를 먼저 표현하는 것이 적합했다.

## Observation 5

개별 전략을 병렬 나열하는 것보다
공통효과·인과관계·선행조건·단계적 확장으로 통합할 때
전체 제안의 흐름이 강화되었다.

## Observation 6

페이지·작성시간·발표시간은 균등하게 배분할 수 없었다.

평가배점·누락위험·기술중요도·심사집중도에 따라
작성자원을 비대칭적으로 배분해야 했다.

## Observation 7

구축형 사업으로 갈수록
목표 아키텍처·제품구성·이관·성능·테스트·안정화에 대한
실현성 검증이 강화되어야 했다.

## Observation 8

모든 정보가 최초부터 완전하게 제공되지 않았다.

현재 정보로 기본 골격을 만든 뒤
부족정보와 가정을 명시적으로 관리할 필요가 있었다.

## Observation 9

추가정보가 입력되더라도
안정된 결론까지 전체 재분석할 필요는 없었다.

정보의 영향범위에 따라 Local, Structural, Fundamental Impact를 구분하고
영향받는 영역을 우선 재분석하는 방식이 적합했다.

## Observation 10

최종검수에서는 표현의 완성도보다
필수요구사항 누락·참가자격·익명성·제출조건·실행불가능 등
결격성 위험을 먼저 확인해야 했다.

---

# 8. Evidence Supporting the Core Model

다섯 사례에서 공통적으로 유지된 Core는 다음과 같다.

공식 입력자료 확보

→ 사업목적·현황·요구사항·제약조건 해석

→ 고객 AS-IS와 TO-BE 도출

→ 회사 및 컨소시엄 자산과 수행조건 결합

→ 고객효과 중심 전략 생성

→ 공통효과 또는 인과관계로 전략 통합

→ 평가조건에 따른 작성자원 배분

→ 수행 가능성·기술실현성·결격위험 검증

→ 정보 충분성 판정

→ 부족정보 요청

→ 추가정보 입력 시 영향영역 선택 재분석

→ 전략과 결론상태 갱신

사업별로 변경된 것은 Core 자체보다 다음 Tailoring 요소였다.

- 산출물
- 산업 전문성
- 규제와 제도
- 목표 아키텍처
- 데이터 이관
- 수행조직
- 재원과 조달
- 평가배점
- 페이지와 발표조건
- 기술검증의 강도

---

# 9. Evidence Supporting Information States

사례분석 과정에서 모든 결론을 동일한 확정도로 표현할 수 없었다.

따라서 다음 상태구분의 필요성이 확인되었다.

## Confirmed

공식정보와 현재 근거만으로 확정 가능한 결론

## Conditional

방향은 타당하지만 회사 자산·기술조건·고객정보 등
추가확인이 필요한 결론

## Deferred

핵심정보가 부족하거나 충돌하여
현재 확정할 수 없는 결론

특히 실제 회사 자산이 제공되지 않은 다섯 사례에서는
전략방향과 구조는 도출할 수 있었지만
최종 차별화와 수행 가능성은 Conditional 또는 Deferred로 남았다.

---

# 10. Evidence Supporting Additional-Information Classes

추가정보의 영향도도 동일하지 않았다.

## Essential

없으면 전략·참여 가능성·수행 가능성을 확정할 수 없는 정보

Examples:

- 필수 참가자격
- 핵심 기술조건
- 상세 시스템 현황
- 데이터 규모와 이관조건
- 필수인력
- 보안 및 계약조건

## High-Value

없어도 기본 골격은 생성할 수 있지만
차별성·정확도·우선순위를 크게 개선하는 정보

Examples:

- 회사 유사실적
- 핵심 전문가
- 선행 ISP
- 고객의 세부 현황
- 실제 제품과 방법론
- 컨소시엄 역할

## Supporting

표현과 세부설계를 개선하지만
핵심결론을 크게 변경하지 않는 정보

Examples:

- 추가 통계
- 참고사례
- 보조 도식
- 표현을 강화하는 세부자료

---

# 11. Negative and Limiting Evidence

본 검증에서 확인하지 못한 사항도 기록한다.

1. 실제 회사 자산을 적용한 최종 차별화는 검증하지 못했다.
2. 실제 제안서 제출과 평가결과까지 연결하지 못했다.
3. 모델과 수주성과 사이의 인과관계는 검증하지 못했다.
4. 다른 제안 PM이 동일 모델로 같은 결과를 생성하는지 검증하지 못했다.
5. 운영·유지관리 사업은 검증하지 못했다.
6. 단순 장비 또는 솔루션 납품은 검증하지 못했다.
7. 연구개발 사업은 검증하지 못했다.
8. 민간기업 제안은 검증하지 못했다.
9. 가격전략과 경쟁사 대응은 검증하지 못했다.
10. 모든 사례에서 공식자료가 완전하게 제공된 것은 아니었다.

따라서 본 Evidence는 모든 제안사업에 대한 완전한 범용성을 지지하지 않는다.

---

# 12. Evidence Assessment

## Confirmed by Evidence

- 서로 다른 공공 IT 제안에서도 동일한 Core Reasoning Structure를 적용할 수 있었다.
- 사업유형에 따라 다른 전략결과가 생성되었다.
- 사업별 차이는 Core 변경보다 Tailoring으로 처리할 수 있었다.
- 불완전한 정보에서도 초기 전략골격을 만들 수 있었다.
- 정보 부족과 논리적 결손을 구분할 필요가 있었다.
- 구축형 사업에서는 기술실현성 검증이 강화되어야 했다.
- 추가정보에 따른 선택적 재분석이 필요했다.

## Not Confirmed by Evidence

- 모든 산업에 대한 범용성
- 실제 회사 자산 기반 최종 경쟁우위
- 수주확률 또는 평가점수 향상
- 다른 사용자에게의 완전한 재현성
- 자동화 시스템만으로 동일 품질 생성
- 가격 및 경쟁사 전략

Evidence Strength:

First-Level Cross-Case Validation

---

# 13. Relationship to OP-001

본 Evidence는 OP-001의 다음 영역을 지원한다.

- Purpose Alignment
- Requirement Alignment
- Evaluation Alignment
- Causal Alignment
- Asset Alignment
- Feasibility Alignment
- Evidence Alignment
- Information Gap과 Logical Gap의 구분
- Confirmed, Conditional, Deferred, Invalid Link 상태

다음 영역은 여전히 해결되지 않았다.

- 연결 강도의 비교
- 최소 근거수준
- 중간가설 생성기준
- 공식정보 충돌의 우선순위
- 공공 IT 외 영역의 적용성

따라서 OP-001 상태는 `Partially Resolved`를 유지한다.

---

# 14. Evidence Conclusion

다섯 개 사례는 서로 다른 산업·산출물·평가조건·기술복잡도를 가졌지만,
다음 핵심 사고구조는 반복적으로 유지되었다.

공식정보 우선

→ 고객변화 해석

→ 요구사항·제약·자산 결합

→ 고객효과 중심 전략 생성

→ 전략의 인과적 통합

→ 평가조건 기반 자원배분

→ 실행 가능성과 결격위험 검증

→ 부족정보 관리

→ 선택적 재분석

본 Evidence는 다음 범위의 추론을 지원한다.

> Proposal-Stage Strategy Reasoning Model은
> 공공부문 IT·AX·ISP·복합 정보시스템 구축 제안의
> 사업이해와 전략 골격 생성에서 1차적으로 반복 적용 가능하다.

최종 범용성 판단과 적용한계는 RS-001에 따른다.

Evidence Status:

Approved