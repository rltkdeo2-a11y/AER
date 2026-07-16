# AER Research Handoff

## 1. Handoff Metadata

- **Research Area:** RFP 입력부터 Decision Strategy 도출까지의 AER 최소 추론 골격
- **Primary Topic:** Link 판단 및 Bottleneck Link/조건군 식별
- **Status:** Conclusion Approved
- **Closure Mode:** Release
- **Handoff Date:** 2026-07-16
- **Next Research Topic:** Proposal Production Layer

---

## 2. Research Objective

RFP, 과업내용서, 평가기준, 발주기관 자료 및 제안사 자산을 입력받아 다음을 수행하는 최소 실행 가능한 AER 추론 골격을 설계한다.

1. 사실과 가설을 분리한다.
2. 복수의 문제·전략 가설을 생성한다.
3. 검증되지 않은 가설이 확정사실이나 핵심전략으로 위장되는 것을 막는다.
4. 전략을 실제로 바꿀 수 있는 미확인 조건만 Bottleneck으로 선별한다.
5. 제한된 시간과 정보 안에서 검증·조건부 진행·대체전략·포기 중 하나를 선택한다.
6. 추가정보 발생 시 전체를 재생성하지 않고 영향받은 Link와 전략만 국소 재분석한다.

AER의 목적은 모든 인간 사고를 기록하는 것이 아니라, 효과적인 자연스러운 사고를 보존하면서 조기수렴, 근거 없는 확정, 기억 누락, 중요도 혼동, 재검토 실패를 줄이는 것이다.

---

## 3. Confirmed Core Skeleton

```text
RFP·과업내용서·평가기준·제안사 자산 입력

→ 사실·요구·평가·제약·자산·결손정보 분리

→ AS-IS·변화 필요·TO-BE·고객효과 해석

→ 문제·원인·전략 Candidate 및 경쟁가설 생성

→ Source–Relation–Why–Target 최소 Link 확인

→ 설명 가능성·사업 관련성·명백한 모순 부재·조건 명시 확인

→ Candidate를 Working으로 승격

→ 복수 Working Strategy 구성

→ 각 전략이 의존하는 미확인 전제 또는 조건군 식별

→ 전제 실패 시 실제 변화 확인

→ 현실적 대체수단 확인

→ Bottleneck 여부 판정

→ 필요한 Bottleneck만 검증하거나 대응방식 결정

→ 검증결과를 반영해 Decision Strategy 선택

→ 고객효과–메커니즘–수행방법–제안사 자산–증거 연결

→ 요구사항·평가기준·기술·일정·비용·보안·법규 통합검사

→ 최종 전략 산출

→ 추가정보 발생 시 영향 Link와 전략만 국소 재분석
```

### Runtime Compression

```text
RFP 구조화
→ 사업 변화구조 해석
→ 복수 가설 생성
→ Working Strategy 구성
→ 결정적 불확실성 선별
→ Bottleneck 집중검증
→ 조건부 또는 확정 전략 선택
→ 평가·실행 가능성과 결합
→ 국소 재분석
```

---

## 4. Link Governance

### 4.1 Minimal Link Structure

```text
Source
→ Relation
→ Why
→ Target
```

핵심 질문:

> 왜 이 사실이 해당 해석·전략을 지지하는가?

키워드 유사성이나 주제 연상만으로는 전략 Link로 승격하지 않는다.

### 4.2 Use Authority

```text
Candidate
탐색에 사용 가능

→ Working
조건부 전략대안 구성에 사용 가능

→ Decision
핵심 문제정의·대표전략·비용·일정·실행결정에 사용 가능
```

### 4.3 Validation State

```text
Confirmed
Conditional
Deferred
Invalid
```

사용권한과 검증상태는 별도 축이다.

예:

- `Working + Conditional`: 전략대안에는 사용할 수 있으나 조건 확인 전 핵심전략으로 확정할 수 없음
- `Candidate + Deferred`: 탐색목록에는 유지하되 현재 핵심 검증대상으로 올릴 근거가 부족함

### 4.4 Governing Principle

> AER는 가설생성을 제한하는 검열체계가 아니라, 가설의 사용권한과 승격조건을 통제하는 추론 거버넌스 체계다.

또한:

> Bridge를 생성할 때는 관대하고, 전략·결론·의사결정으로 승격할 때는 엄격해야 한다.

---

## 5. Bottleneck Link / Condition Set

### 5.1 Confirmed Definition

Bottleneck은 단순히 중요하거나 불확실한 Link가 아니다.

> 그것이 틀렸을 때 현재 전략의 선택, 핵심효과, 기술구조, 일정, 비용, 인력, 차별화 또는 필수요건이 실질적으로 변경되는 미확인 전제 또는 소수 조건군이다.

Bottleneck 여부와 검증 우선순위는 분리한다.

```text
전략을 지배하는가
≠
지금 추가 검증할 가치가 있는가
```

### 5.2 Minimal Execution Sequence

```text
미확인 전제 식별
→ 전제 실패 시 실제 변화 확인
→ 현실적 대체수단 확인
→ Bottleneck 여부 판정
→ 즉시 검증 또는 대응방식 선택
→ 재검토 조건 기록
```

### 5.3 Six-Line Record Format

```text
대상 전략·범위:
미확인 전제 또는 조건군:
전제 실패 시 실제 변화:
현실적 대체수단:
현재 조치:
재검토 조건:
```

### 5.4 Decision Logic

```text
미확인 전제를 거짓으로 가정

→ 전략·효과·기술·비용·일정·차별화 변화 확인

→ 같은 고객목표를 유지할 현실적 대안 확인

핵심가치 유지 가능
→ Bottleneck 제외 또는 영향도 약화

핵심가치 유지 불가
→ Bottleneck 지정

검증 가능하고 결과가 행동을 바꿈
→ 즉시 검증

검증 불가능
→ 조건부 진행 / 제한적 병행 / 보수적 전환 / 전략 포기
```

### 5.5 Evidence Sufficiency

증거의 충분성은 개수가 아니라 다음으로 판단한다.

- **Authority:** 신뢰할 수 있는 출처인가
- **Relevance:** 해당 Link를 실제로 지지하는가
- **Coverage:** 결론의 범위를 충분히 덮는가

---

## 6. Validation Results

### 6.1 Construction-Type RFP

인천공항 데이터플랫폼 구축사업의 제안요청서와 과업내용서, 110개 요구사항에 적용했다.

식별된 핵심 Bottleneck:

```text
1. 데이터 수렴
   범위·업무 의미·표준·품질·통합모델·이관 검증

2. 전환 연속성
   IIS 전환시점·연계·결과 정합성·통합테스트·병행운영·무중단

3. 기술환경 적합성
   제공 인프라·SW·라이선스·성능·보안구조·보안성 검토
```

횡단조건:

```text
업무부서·정보화부서·운영조직·외부사업 간
의사결정 및 승인 처리속도
```

검증 결과:

- 단순 미확인 사항과 실제 전략 Bottleneck을 구분함
- 현실적 대체경로가 있는 특정 제품 문제는 전체 Bottleneck에서 제외함
- IIS 일정과 무중단 전환을 하나의 전환 연속성 조건군으로 통합함
- 요구사항 수가 아니라 실패 시 전략 변화 여부로 우선순위를 판단함

### 6.2 AX Strategy Consulting RFP

금융감독원 「금융감독 AX 전략 수립 컨설팅」 RFP에 적용했다.

식별된 핵심 Bottleneck:

```text
1. Evidence Bottleneck
   내부 업무·데이터·시스템·DX·보안 현실의 확보

2. Convergence Bottleneck
   범용AI·1人 1Agent를 포함한 복수 전략가설을
   실제 우선순위와 조직적 선택으로 수렴

3. Executability Bottleneck
   선택전략을 기술·데이터·보안·일정·비용·책임부서가
   연결된 실행계획으로 변환

4. Measurement Bottleneck
   현재 기준값과 측정데이터를 확보하여 AX 성과를 판정
```

횡단조건:

```text
진행 중인 DX 사업과의 의존관계
3개월·보안환경·투입인력이라는 수행제약
```

검증 결과:

- 구축형 사업에 과적합된 골격이 아님을 확인함
- 전략 컨설팅에서는 기술보다 근거 확보, 조기수렴 통제, 조직적 선택, 실행계획 전환이 Bottleneck이 됨을 확인함
- 조직이 가설을 수정할 수 있는 개방성과 우선순위를 확정할 의사결정 능력도 Bottleneck이 될 수 있음을 확인함

---

## 7. Higher-Order Design Constraints

### 7.1 Skeleton First

- 최소 실행 가능한 추론 골격부터 완성한다.
- 골격을 바꾸지 않는 세부 분류·메타데이터·예외규칙은 후속으로 미룬다.
- 대표 사례와 구조를 바꿀 수 있는 반례만으로 골격을 검증한다.

### 7.2 Minimal Sufficient Recording

모든 사고를 기록하지 않는다. 다음 정보만 외부화한다.

```text
결정적 사실
핵심 가설
결론을 뒤집는 조건
현실적인 대체수단
현재 결정
재검토 Trigger
```

### 7.3 Deep Design, Minimal Runtime

> 설계는 충분히 깊게 하되, 실행은 최소화한다.

상세 기준은 상시 절차가 아니라 필요할 때 호출하는 진단모듈로 둔다.

### 7.4 Architecture

```text
Core Kernel
일상적 최소 추론

Diagnostic Modules
판단이 막히거나 고위험일 때만 호출

Audit Layer
세부 재구성이 필요한 경우에만 사용
```

### 7.5 Anti-Proceduralism

새 절차나 분류는 다음 중 하나를 실질적으로 개선할 때만 채택한다.

- 정확도
- 재사용성
- 속도

추가 절차가 줄이는 오류보다 인간 인지비용·시간·LLM 추론부하가 더 크면 기본절차로 채택하지 않는다.

---

## 8. Validation Stop Rule

대표성이 다른 구축형 RFP와 AX 전략형 RFP에서 최소 골격의 작동성이 확인됐고, 대부분의 RFP는 형식상 유사하므로 예외 탐색을 위한 반복 검증은 종료한다.

추가 검증은 다음 상황에서만 재개한다.

```text
실제 적용에서 Bottleneck을 잘못 식별함

중요한 Bottleneck이 반복적으로 누락됨

현재 골격으로 설명되지 않는 구조적으로 다른 사업이 등장함

동일 유형의 오판이 반복됨

보류한 진단모듈의 필요성이 실제 사례에서 확인됨
```

---

## 9. Deferred Diagnostic Modules

다음 항목은 폐기된 것이 아니라 필요성이 발생할 때만 재개하는 연구주제다.

| Deferred Topic | Restart Condition |
|---|---|
| Bridge 인식론적 유형 | 서로 다른 가설 유형이 반복적으로 잘못 취급될 때 |
| Bridge 기능적 유형 | 관계의 기능 차이를 구분하지 않아 전략오류가 발생할 때 |
| Direct / Mediated Link 정밀 판정 | Link의 추론비약 여부를 기본 Why 검사로 판정할 수 없을 때 |
| Selection / Mechanism / Execution / Claim 진단 | 영향영역 혼동으로 검증 우선순위가 왜곡될 때 |
| Claim 실패수준 | 주장의 약화와 전략교체를 구분하기 어려울 때 |
| Combined Bottleneck 연산자 | 단일 Link 제거시험으로 실제 전략붕괴를 설명할 수 없을 때 |
| 정량 검증 우선순위 | 검증대상이 너무 많아 정성적 우선순위가 작동하지 않을 때 |
| 상세 Link 메타데이터 | 국소 재분석에서 기존 추론을 반복적으로 복원하지 못할 때 |
| Audit 기록형식 | 계약·분쟁·고위험 의사결정에서 상세 추적성이 필요할 때 |

---

## 10. Confirmed Output Logic

AER가 최종적으로 생성하는 전략은 다음 논리구조를 가진다.

```text
고객의 핵심 문제

→ 문제를 발생시키는 결정적 원인

→ 목표상태와 고객효과

→ 효과를 발생시키는 전략 메커니즘

→ 실행과제 및 우선순위

→ 필요한 기술·데이터·조직·운영조건

→ 제안사 자산의 적용방식

→ 근거와 검증결과

→ 남은 조건과 대체전략

→ 재검토 조건
```

제안 메시지 압축 순서:

```text
고객효과
→ 구현원리
→ 수행방법
→ 제안사 자산
→ 증거
```

제안사 자산에서 출발하여 고객 문제를 끼워 맞추는 방식은 허용하지 않는다.

---

## 11. Current Completion Boundary

### Included in This Release

- RFP 입력자료 구조화
- 사업 변화구조 해석
- Candidate Link 및 경쟁가설 생성
- Candidate → Working → Decision 사용권한 관리
- Link 최소 Why 검사
- 복수 Working Strategy 유지
- Bottleneck Link/조건군 식별
- 대체경로 검사
- 선택적 집중검증
- 조건부 의사결정과 Fallback
- 요구사항·평가·수행가능성 통합검사
- 추가정보에 따른 국소 재분석
- 반복검증 스탑룰

### Not Included in This Release

- 제안서 목차 자동생성
- 평가배점 기반 페이지 비중 배분
- 장별 스토리라인 자동생성
- 요구사항–슬라이드 배치
- 슬라이드별 메시지·근거·도식 명세
- PPT 파일 자동생성 및 렌더링

---

## 12. Next Research Topic: Proposal Production Layer

다음 연구는 검증된 Decision Strategy를 실제 제안 산출물로 변환하는 계층이다.

```text
Decision Strategy
무엇을 제안할 것인가

→ Proposal Blueprint / Architecture
어떤 논리순서와 비중으로 설득할 것인가

→ Slide Specification
각 페이지가 무엇을 주장하고 어떻게 보여줄 것인가

→ PPT Draft
실제 수정 가능한 슬라이드 초안
```

### Expected End-to-End Direction

```text
RFP·과업내용서·평가기준

→ AER Reasoning Kernel

→ 문제정의·전략·Bottleneck·조건·근거

→ Proposal Blueprint

→ 목차·페이지 배분·스토리라인

→ 슬라이드별 메시지·근거·도식 명세

→ PPT 초안

→ 인간 검토·수정
```

### Required Intermediate Representation

PPT로 직접 점프하지 않고 다음 중간구조를 정의해야 한다.

```text
Slide ID
슬라이드 목적
대응 요구사항
대응 평가항목
핵심 메시지
근거
표현할 전략 Link
시각화 방식
조건 또는 유의사항
앞뒤 슬라이드 연결
```

### Recommended Restart Point

다음 연구는 아래 질문에서 시작한다.

> Decision Strategy와 검증된 Link를 입력받아, 요구사항 커버리지·평가배점·전략적 설득순서를 동시에 반영한 Proposal Architecture를 어떤 최소 구조로 표현할 것인가?

---

## 13. Final Handoff Statement

이번 연구에서 AER는 다음 세 기능이 결합된 최소 추론모델로 확정됐다.

```text
넓게 사고하는 가설생성 체계

+

검증되지 않은 가설의 승격을 막는 통제체계

+

제한된 시간에 검증할 대상을 선별하는
Bottleneck 기반 자원배분 체계
```

최종 정의:

> AER는 RFP에서 복수의 전략 가능성을 생성하고, 그중 결론을 좌우하는 미확인 조건을 식별·처리하여, 조건과 근거가 통제된 실행 가능한 제안전략으로 수렴시키는 재사용 가능한 텍스트 추론모델이다.

