# Decision Record

Decision ID: DEC-002

Title: Adopt the RFP Bottleneck Reasoning Kernel

Status: Approved

Decision Date: 2026-07-16

Effective Date: 2026-07-16

Decision Owner:

Human Co-Researcher

Research Domain:

AER Proposal-Stage Strategy Reasoning

Related Research Session:

SESSION-004 RFP Bottleneck Reasoning

Related Evidence:

EV-002 RFP Bottleneck Validation Cases

Related Reasoning:

RS-002 RFP Bottleneck Reasoning Kernel

Related Principle:

PR-001 Proposal-Stage Strategy Reasoning Principles

Related Open Problem:

OP-001 PM Linkage Criteria

Approval Basis:

09_RESEARCH_LOG/AER_RFP_Bottleneck_Handoff_2026-07-16.md

Related Research Commit Proposal:

RC-004 AER RFP Bottleneck Reasoning Kernel

Closure Mode:

Release

---

# 1. Decision Summary

RFP 기반 제안전략에서 Link의 사용 권한과 검증 상태를 분리하고, 전략을 실제로 변경할 수 있는 미확인 전제 또는 조건군만 집중검증하는 RFP Bottleneck Reasoning Kernel을 AER 연구자산으로 채택한다.

본 결정은 DEC-001의 전체 제안단계 모델을 다시 채택하지 않는다. 기존 모델 위에 Link Governance, Bottleneck 판정, 대체수단 검사와 조건부 대응을 추가한다.

상세 판정절차는 RS-002를 따른다.

---

# 2. Adopted Requirements

다음 사항을 채택한다.

1. Link는 `Source → Relation → Why → Target` 최소구조로 검토한다.
2. Candidate, Working, Decision 사용 권한을 구분한다.
3. Confirmed, Conditional, Deferred, Invalid 검증 상태를 구분한다.
4. 사용 권한과 검증 상태를 별도 축으로 관리한다.
5. 전략을 실제로 변경하는 불확실성만 Bottleneck으로 식별한다.
6. 전제 실패 시 실제 변화와 현실적 대체수단을 검사한다.
7. 검증가치와 실행 가능성에 따라 즉시 검증 또는 조건부 대응을 선택한다.
8. 추가 정보가 입력되면 영향을 받는 Link와 전략만 국소 재분석한다.

---

# 3. Required Bottleneck Record

다음 6행 기록형식을 운영 요구사항으로 채택한다.

```text
대상 전략·범위:
미확인 전제 또는 조건군:
전제 실패 시 실제 변화:
현실적 대체수단:
현재 조치:
재검토 조건:
```

각 항목의 상세 판정기준과 사용절차는 RS-002를 참조한다.

---

# 4. Application Scope

현재 승인범위:

- 공공부문 IT·AX·ISP·정보시스템 구축 제안
- 구축형 및 AX 전략·컨설팅형 RFP
- 제안단계의 핵심 가설, 전략 Link와 실행조건 검증
- 제한된 시간에서 검증대상 선택과 조건부 대응

현재 미검증 범위:

- 민간기업 제안 전반
- 운영·유지관리 사업
- 일반 소비재 또는 제품사업
- 연구개발 사업
- 가격전략과 경쟁사 대응
- 실제 제안사 자산을 반영한 최종 경쟁전략
- 모든 산업과 모든 제안유형에 대한 보편적 적용

미검증 범위를 승인된 일반원칙으로 강화하지 않는다.

---

# 5. Open Problem Decision

OP-001 PM Linkage Criteria의 상태는 `Partially Resolved`로 유지한다.

이번 결정으로 진전된 범위:

- 최소 Link 구조와 Why 검사
- 사용 권한과 검증 상태의 분리
- Bottleneck 정의
- 전제 실패 영향
- 현실적 대체수단 검사
- 선택적 검증
- 국소 재분석

잔여 문제는 OP-001에 보존한다.

---

# 6. Deferred Diagnostic Modules

다음 Diagnostic Modules는 기본 Runtime 절차로 채택하지 않는다.

- Bridge 인식론적·기능적 유형
- Direct/Mediated Link 정밀 판정
- Selection/Mechanism/Execution/Claim 진단
- Claim 실패유형
- Combined Bottleneck 연산
- 정량 검증 우선순위
- 상세 Link 메타데이터
- Audit 기록형식

반복 실패, 구조적으로 다른 사업유형 또는 고위험 판단에서 실제 필요성이 확인될 때만 재개한다.

---

# 7. Proposal Production Layer Boundary

다음은 본 결정의 범위에서 제외한다.

- 제안서 목차 자동생성
- 평가배점 기반 페이지 비중 배분
- 단계별 스토리라인 자동생성
- 요구사항과 슬라이드의 자동 배치
- 슬라이드별 메시지·근거·표현 명세
- PPT 파일 생성과 렌더링
- Proposal Blueprint와 Slide Specification의 상세구조

검증된 Decision Strategy를 제안 산출물로 변환하는 과정은 다음 연구주제인 Proposal Production Layer에서 다룬다.

---

# 8. Repository and Version Boundary

- Closure Mode: Release
- AER Repository 구조: 변경 없음
- AER 구조버전: `AER v1.0` 유지
- 연구상태 버전: 변경 없음
- Governance 문서: 변경 없음
- 새로운 Open Problem: 생성하지 않음

Decision Status:

Approved
