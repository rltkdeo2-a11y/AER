# Evidence Record

Evidence ID: EV-002

Title: RFP Bottleneck Validation Cases

Status: Approved

Version: 1.0

Created: 2026-07-16

Updated: 2026-07-16

Research Domain:

AER Proposal-Stage Strategy Reasoning

Related Research Session:

SESSION-004 RFP Bottleneck Reasoning

Related Evidence:

EV-001 Proposal-Stage Reasoning Model RFP Validation Cases

Related Reasoning:

RS-002 RFP Bottleneck Reasoning Kernel

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

본 Evidence Record는 서로 다른 RFP 유형에서 다음 판단구조가 실제로 작동하는지 검증한다.

1. 단순한 미확인 사항과 전략을 실제로 변경하는 Bottleneck을 구분할 수 있는가?
2. 전제 실패 시 전략·효과·기술·일정·비용·인력·차별화 또는 필수요건의 실제 변화를 식별할 수 있는가?
3. 현실적 대체수단의 존재 여부를 통해 Bottleneck의 영향도를 조정할 수 있는가?
4. 제한된 시간에 검증할 대상을 선택하고 나머지를 조건부로 관리할 수 있는가?

기존 RFP 사례의 일반 설명은 EV-001을 참조한다. 본 기록은 Bottleneck 판정에 직접 필요한 증거만 추가한다.

---

# 2. Validation Frame

각 사례에서 다음 질문을 적용하였다.

```text
대상 전략이 의존하는 미확인 전제 또는 조건군은 무엇인가?
그 전제가 실패하면 실제로 무엇이 달라지는가?
같은 고객목표를 유지하는 현실적 대체수단이 있는가?
현재 즉시 검증할 가치와 가능성이 있는가?
검증하지 못할 경우 어떤 조건부 대응이 필요한가?
```

Bottleneck 여부와 검증 우선순위는 분리하여 판단하였다.

- Bottleneck 여부: 전제 실패가 현재 전략을 실질적으로 변경하는가?
- 검증 우선순위: 지금 추가 검증할 가치와 실행 가능성이 있는가?

---

# 3. Construction-Type Validation

Validation Case:

인천공항 데이터플랫폼 구축

기존 사례 배경과 요구사항 분석은 EV-001을 참조한다.

## 3.1 Validated Bottlenecks

### Data Convergence

- 데이터 범위, 업무 수요, 표준, 품질, 연계와 통합모델에 관한 전제가 실패하면 목표 아키텍처와 수행범위가 변경된다.
- 단순 데이터 목록의 미확인보다 데이터 수렴구조와 책임경계가 전략을 더 직접적으로 지배하였다.

### Transition Continuity

- 전환시점, 연계, 결과 정합성, 통합테스트, 병행운영과 무중단 조건은 일정과 운영 안정화 전략을 변경한다.
- 일부 기능의 대체제품은 존재할 수 있지만 전환 연속성 전체를 대체하지 못하므로 핵심 조건군으로 유지되었다.

### Technical-Environment Fit

- 제품, 인프라, 라이선스, 성능과 보안구조의 적합성은 기술구조와 비용을 변경한다.
- 특정 제품에 현실적 대체경로가 있으면 해당 제품 자체는 전체 전략의 Bottleneck에서 제외하거나 영향도를 낮출 수 있었다.

## 3.2 Evidence Result

- 요구사항 수가 아니라 전제 실패 시 실제 전략 변화로 검증 우선순위를 판단할 수 있었다.
- 현실적 대체수단 검사를 통해 특정 제품의 불확실성과 전체 전략 Bottleneck을 구분할 수 있었다.
- 상호의존적인 전환 조건은 개별 항목이 아니라 소수 조건군으로 묶는 것이 적절했다.

---

# 4. AX Strategy and Consulting Validation

Validation Case:

금융감독 AX 전략 수립 컨설팅

기존 제안단계 모델의 일반 검증내용은 EV-001을 참조한다.

## 4.1 Validated Bottlenecks

### Evidence Bottleneck

내부 업무, 데이터, 시스템, 기존 디지털 전환과 보안 현황이 확인되지 않으면 우선과제와 실행범위의 근거가 변경된다.

### Convergence Bottleneck

복수의 핵심 가설을 실제 우선순위와 조직적 선택으로 수렴하지 못하면 전략의 초점과 자원배분이 확정되지 않는다.

### Executability Bottleneck

선택한 전략을 기술, 데이터, 보안, 일정, 비용, 인력과 책임구조로 연결하지 못하면 실행계획으로 전환할 수 없다.

### Measurement Bottleneck

현재 기준값과 측정데이터가 없으면 목표효과와 성과측정 방식이 조건부 상태에 머문다.

## 4.2 Evidence Result

- 전략·컨설팅형 RFP에서도 동일한 상위 Bottleneck 판정원리가 작동하였다.
- 구축형 사업과 달리 근거 확보, 조기수렴 통제, 조직적 선택, 실행계획 전환과 측정 가능성이 주요 Bottleneck이 되었다.
- 조직이 핵심 가설을 수정할 수 있는 개방성과 우선순위를 확정할 의사결정 능력도 조건군으로 작동할 수 있었다.

---

# 5. Cross-Case Findings

두 유형에서 다음 패턴이 공통으로 확인되었다.

1. 중요하거나 불확실하다는 이유만으로 Bottleneck이 되지는 않는다.
2. 전제 실패가 현재 전략을 실질적으로 변경해야 Bottleneck으로 판정할 수 있다.
3. 동일한 고객목표를 유지하는 현실적 대체수단이 있으면 Bottleneck을 제외하거나 영향도를 낮출 수 있다.
4. 상호의존적인 전제는 개별 항목보다 소수 조건군으로 관리하는 편이 유효하다.
5. 모든 Bottleneck을 즉시 검증할 필요는 없으며 검증가치와 실행 가능성을 별도로 판단해야 한다.
6. 검증하지 못한 Bottleneck은 조건부 진행, 제한적 병행, 보수적 전환 또는 전략 보류로 관리할 수 있다.

---

# 6. Evidence Sufficiency

본 Evidence의 충분성은 다음 기준으로 제한한다.

- Authority: 공식 RFP와 과업 관련 자료를 우선 근거로 사용하였다.
- Relevance: Bottleneck 판정과 직접 관련된 사례 관찰만 기록하였다.
- Coverage: 구축형과 AX 전략·컨설팅형이라는 서로 다른 두 유형에서 상위 판정구조를 확인하였다.

이 Evidence는 모든 산업과 모든 제안유형에 대한 보편성을 증명하지 않는다.

---

# 7. Scope and Limitations

Validated Scope:

- 공공부문 IT·AX·ISP·정보시스템 구축 제안
- RFP와 관련 공식자료에 기반한 제안전략 도출
- 구축형 및 AX 전략·컨설팅형 사업의 1차 교차검증
- Bottleneck 기반 검증대상 선택과 조건부 대응

Not Yet Validated:

- 민간기업 제안 전반
- 운영·유지관리 사업
- 일반 소비재 또는 제품사업
- 연구개발 사업
- 가격전략과 경쟁사 대응
- 실제 제안사 자산을 반영한 최종 경쟁전략
- 모든 산업과 모든 제안유형에 대한 보편적 적용
- 복합 Bottleneck의 정량 연산

Evidence Status:

Approved
