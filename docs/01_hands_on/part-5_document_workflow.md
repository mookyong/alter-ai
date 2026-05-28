# 5부. 문서 작성 실습: 회의록, 이슈, 리스크, 의사결정 연결하기

이번 장에서는 실제 PL 업무 흐름에 맞춰 다음 문서를 작성하고 서로 연결하는 실습을 진행합니다.

```text
회의록
  ↓
이슈 등록
  ↓
리스크 등록
  ↓
의사결정 기록
  ↓
액션아이템 관리
  ↓
대시보드 반영
```

이번 장의 핵심은 회의에서 나온 내용을 단순히 회의록에만 남기지 않고, 프로젝트 관리 문서로 연결하는 것입니다.

---

## 1. 이번 장의 목표

이번 장을 완료하면 아래 문서들이 서로 연결됩니다.

| 문서 | 역할 |
| --- | --- |
| `08_meetings/weekly/2026-05-27_weekly_meeting.md` | 회의 원문 기록 |
| `07_management/issue_register.md` | 실제 발생한 문제 관리 |
| `07_management/risk_register.md` | 발생 가능 위험 관리 |
| `07_management/decision_log.md` | 의사결정 이력 관리 |
| `07_management/action_items.md` | 후속 조치 관리 |
| `002_PROJECT_DASHBOARD.md` | PL 일일 관리 화면 |

---

## 2. 실습 시나리오

이번 실습에서는 다음 상황을 가정합니다.

```text
고객사에서 제공한 테이블 목록과 실제 DB 스키마가 일부 다르다.
일부 테이블은 PK 기준이 명확하지 않다.
증분 추출 기준 컬럼도 아직 확정되지 않았다.
개발팀은 확정된 테이블부터 우선 개발하기로 했다.
고객사에는 최신 테이블 목록과 증분 기준 컬럼 확인을 요청해야 한다.
```

이 상황에서 우리는 아래 항목을 관리해야 합니다.

| 구분 | 내용 |
| --- | --- |
| 이슈 | 제공 테이블 목록과 실제 DB 스키마 불일치 |
| 리스크 | 매핑 확정 지연으로 개발 일정 지연 가능 |
| 의사결정 | 확정 테이블 기준으로 1차 개발 우선 진행 |
| 액션아이템 | 고객사에 최신 테이블 목록 재요청 |
| 확인사항 | 증분 기준 컬럼 확인 필요 |

---

## 3. 회의록 작성

먼저 Obsidian에서 아래 폴더로 이동합니다.

```text
docs/08_meetings/weekly/
```

새 파일을 만듭니다.

```text
2026-05-27_weekly_meeting.md
```

아래 내용을 작성합니다.

```markdown
# 2026-05-27 주간회의

## 1. 회의 정보

- 일시: 2026-05-27
- 회의 유형: 주간회의
- 참석자:
  - PL
  - 개발팀
  - 고객사 담당자

## 2. 주요 논의 내용

고객사에서 제공한 테이블 목록과 실제 DB 스키마가 일부 불일치하는 것으로 확인되었다.

일부 테이블은 PK 기준이 명확하지 않고, 증분 추출 기준 컬럼도 아직 확정되지 않았다.

개발팀은 전체 범위가 모두 확정될 때까지 대기하기보다는, 확정된 테이블을 기준으로 1차 개발을 우선 진행하는 것이 현실적이라고 판단했다.

## 3. 결정사항

DECISION: 1차 개발은 확정 테이블 기준으로 우선 진행한다.

## 4. 이슈

ISSUE: 고객사 제공 테이블 목록과 실제 DB 스키마가 일부 불일치한다.

## 5. 리스크

RISK: 매핑 확정이 지연될 경우 개발 일정이 지연될 수 있다.

## 6. 액션아이템

TODO: 고객사에 최신 테이블 목록 재요청
CHECK: 실제 DB 스키마와 고객사 제공 목록 비교 필요
QUESTION: 증분 추출 기준 컬럼을 테이블별로 확정할 수 있는지 확인 필요

## 7. 관련 문서

- [[07_management/issue_register]]
- [[07_management/risk_register]]
- [[07_management/decision_log]]
- [[07_management/action_items]]
- [[02_scope/migration_scope]]
- [[04_design/mapping/mapping_policy]]
```

---

## 4. 회의록 작성 규칙

회의록에는 가능한 한 다음 구분을 유지합니다.

| 구분 | 설명 |
| --- | --- |
| 주요 논의 내용 | 회의에서 논의된 배경과 맥락 |
| 결정사항 | 실제 결정된 내용 |
| 이슈 | 이미 발생한 문제 |
| 리스크 | 앞으로 발생할 수 있는 위험 |
| 액션아이템 | 누가 무엇을 언제까지 해야 하는지 |
| 관련 문서 | 이 회의와 연결된 공식 문서 |

중요한 점은 `ISSUE`, `RISK`, `DECISION`, `TODO`, `CHECK`, `QUESTION` 같은 태그를 명시적으로 쓰는 것입니다.

이렇게 해야 VSCode의 Todo Tree와 OpenCode Agent가 내용을 쉽게 추출할 수 있습니다.

---

## 5. 이슈 등록하기

이제 회의록에서 나온 이슈를 공식 이슈 목록에 등록합니다.

파일을 엽니다.

```text
docs/07_management/issue_register.md
```

아래 내용을 추가합니다.

```markdown
# Issue Register

## 이슈 목록

| ID | 상태 | 우선순위 | 이슈 | 영향 | 담당자 | 기한 | 관련 문서 |
|---|---|---|---|---|---|---|---|
| ISS-001 | Open | High | 고객사 제공 테이블 목록과 실제 DB 스키마 일부 불일치 | 매핑 확정 및 개발 착수 지연 가능 | PL | 미정 | [[08_meetings/weekly/2026-05-27_weekly_meeting]] |

## ISS-001 고객사 제공 테이블 목록과 실제 DB 스키마 일부 불일치

### 현상

고객사에서 제공한 테이블 목록과 실제 DB 스키마가 일부 불일치하는 것으로 확인되었다.

### 영향

- 마이그레이션 대상 범위 확정 지연
- 테이블 매핑표 작성 지연
- 개발 착수 대상 불명확
- 검증 대상 목록 불일치 가능

### 원인

현재 기준으로는 고객사 제공 목록의 작성 시점과 실제 DB 스키마 기준일이 다를 가능성이 있다.

### 대응 방안

- 고객사에 최신 테이블 목록 재요청
- 실제 DB 스키마 기준으로 테이블 목록 재추출
- 불일치 항목을 별도 목록으로 관리
- 확정 테이블과 미확정 테이블을 분리하여 개발 진행

### 관련 문서

- [[08_meetings/weekly/2026-05-27_weekly_meeting]]
- [[02_scope/migration_scope]]
- [[04_design/mapping/mapping_policy]]
- [[07_management/action_items]]
```

---

## 6. 이슈 등록 기준

`issue_register.md`에는 이미 발생한 문제를 기록합니다.

예를 들어 다음은 이슈입니다.

```text
테이블 목록이 실제 DB와 다르다.
PK 기준이 누락되어 있다.
컬럼 타입이 설계서와 다르다.
검증 SQL 실행 결과가 불일치한다.
배치 수행 중 오류가 발생했다.
```

반면 다음은 리스크입니다.

```text
테이블 목록 확정이 늦어질 수 있다.
검증 일정이 지연될 수 있다.
대용량 테이블 이관 시간이 부족할 수 있다.
고객사 승인 지연 가능성이 있다.
```

구분 기준은 다음과 같습니다.

| 구분 | 판단 기준 |
| --- | --- |
| 이슈 | 이미 발생함 |
| 리스크 | 아직 발생하지 않았지만 가능성이 있음 |

---

## 7. 리스크 등록하기

이제 회의록에서 나온 리스크를 등록합니다.

파일을 엽니다.

```text
docs/07_management/risk_register.md
```

아래 내용을 추가합니다.

```markdown
# Risk Register

## 리스크 목록

| ID | 상태 | 영향도 | 가능성 | 리스크 | 대응 방안 | 담당자 | 관련 문서 |
|---|---|---:|---:|---|---|---|---|
| RSK-001 | Open | High | Medium | 매핑 확정 지연으로 개발 일정 지연 가능 | 확정/미확정 테이블 분리 및 우선순위 기반 개발 | PL | [[08_meetings/weekly/2026-05-27_weekly_meeting]] |

## RSK-001 매핑 확정 지연으로 개발 일정 지연 가능

### 리스크 설명

테이블 목록, PK 기준, 증분 기준 컬럼이 확정되지 않을 경우 매핑 설계와 개발 착수가 지연될 수 있다.

### 발생 가능 원인

- 고객사 제공 목록의 최신성 부족
- 원천 DB 스키마와 문서 간 불일치
- 증분 기준 컬럼에 대한 업무 합의 지연
- 테이블별 소유 부서 또는 담당자 불명확

### 영향

- WBS 일정 지연
- 개발자 대기 시간 증가
- 검증 일정 압축
- 리허설 일정 차질
- 고객사 보고 시 일정 리스크 증가

### 대응 방안

- 확정 테이블과 미확정 테이블을 분리한다.
- 확정 테이블 기준으로 1차 개발을 우선 진행한다.
- 미확정 테이블은 별도 이슈 목록으로 관리한다.
- 고객사 확인 필요사항을 주간회의 고정 안건으로 등록한다.

### 관련 문서

- [[08_meetings/weekly/2026-05-27_weekly_meeting]]
- [[07_management/issue_register]]
- [[01_plan/wbs/wbs_summary]]
- [[04_design/mapping/mapping_policy]]
```

---

## 8. 의사결정 등록하기

회의에서 결정된 사항은 `decision_log.md`에 남깁니다.

파일을 엽니다.

```text
docs/07_management/decision_log.md
```

아래 내용을 추가합니다.

```markdown
# Decision Log

## 의사결정 목록

| ID | 일자 | 상태 | 결정사항 | 영향 범위 | 관련 문서 |
|---|---|---|---|---|---|
| DEC-001 | 2026-05-27 | Approved | 1차 개발은 확정 테이블 기준으로 우선 진행 | 개발 범위, WBS, 매핑 설계 | [[08_meetings/weekly/2026-05-27_weekly_meeting]] |

## DEC-001 1차 개발은 확정 테이블 기준으로 우선 진행

### 배경

고객사 제공 테이블 목록과 실제 DB 스키마가 일부 불일치하고, 일부 테이블의 PK 및 증분 기준 컬럼이 확정되지 않았다.

전체 대상이 모두 확정될 때까지 개발을 대기하면 일정 지연 가능성이 크다.

### 선택지

| 선택지 | 설명 | 장점 | 단점 |
|---|---|---|---|
| 전체 범위 확정 후 개발 | 모든 테이블 목록과 기준 확정 후 개발 시작 | 재작업 가능성 낮음 | 일정 지연 가능성 큼 |
| 확정 테이블 우선 개발 | 확정된 테이블부터 1차 개발 진행 | 일정 지연 최소화 | 일부 재작업 가능 |
| 핵심 업무 테이블만 우선 개발 | 중요 테이블만 선별하여 개발 | 리스크 집중 관리 가능 | 범위 재조정 필요 |

### 결정 내용

1차 개발은 확정 테이블 기준으로 우선 진행한다.

미확정 테이블은 별도 이슈로 관리하고, 고객사 확인 후 후속 개발 범위에 반영한다.

### 영향 범위

- WBS
- 테이블 매핑표
- 개발 우선순위
- 검증 대상 목록
- 고객사 확인 필요사항

### 후속 작업

- [ ] 확정 테이블 목록 분리
- [ ] 미확정 테이블 목록 작성
- [ ] 고객사 확인 요청
- [ ] WBS 개발 순서 반영
- [ ] 매핑 설계 문서 반영

### 관련 문서

- [[08_meetings/weekly/2026-05-27_weekly_meeting]]
- [[07_management/issue_register]]
- [[07_management/risk_register]]
- [[01_plan/wbs/wbs_summary]]
- [[04_design/mapping/mapping_policy]]
```

---

## 9. 액션아이템 등록하기

회의에서 나온 후속 조치는 `action_items.md`에 정리합니다.

파일을 엽니다.

```text
docs/07_management/action_items.md
```

아래 내용을 추가합니다.

```markdown
# Action Items

## 액션아이템 목록

| ID | 상태 | 우선순위 | 액션아이템 | 담당자 | 기한 | 관련 이슈 | 관련 회의 |
|---|---|---|---|---|---|---|---|
| ACT-001 | Open | High | 고객사에 최신 테이블 목록 재요청 | PL | 미정 | [[07_management/issue_register#ISS-001 고객사 제공 테이블 목록과 실제 DB 스키마 일부 불일치]] | [[08_meetings/weekly/2026-05-27_weekly_meeting]] |
| ACT-002 | Open | High | 실제 DB 스키마와 고객사 제공 목록 비교 | 개발팀 | 미정 | [[07_management/issue_register#ISS-001 고객사 제공 테이블 목록과 실제 DB 스키마 일부 불일치]] | [[08_meetings/weekly/2026-05-27_weekly_meeting]] |
| ACT-003 | Open | Medium | 증분 추출 기준 컬럼 확정 가능 여부 확인 | PL | 미정 | [[07_management/issue_register#ISS-001 고객사 제공 테이블 목록과 실제 DB 스키마 일부 불일치]] | [[08_meetings/weekly/2026-05-27_weekly_meeting]] |

## ACT-001 고객사에 최신 테이블 목록 재요청

### 작업 내용

고객사에 최신 기준의 테이블 목록 제공을 요청한다.

### 산출물

- 최신 테이블 목록
- 기준일자
- 제외 대상 여부
- 업무 담당자 정보

### 관련 문서

- [[07_management/issue_register]]
- [[02_scope/migration_scope]]
```

---

## 10. 대시보드 반영하기

PL이 매일 보는 `002_PROJECT_DASHBOARD.md`에도 핵심 내용을 반영합니다.

파일을 엽니다.

```text
docs/002_PROJECT_DASHBOARD.md
```

아래 내용을 추가하거나 수정합니다.

```markdown
# Project Dashboard

## 현재 상태

- 전체 상태: 🟡 주의
- 기준일: 2026-05-27
- 현재 단계: 분석/설계 준비
- 다음 마일스톤: 마이그레이션 대상 범위 확정
- 주요 리스크: 매핑 확정 지연으로 개발 일정 지연 가능
- 주요 의사결정 필요사항: 증분 기준 컬럼 확정 방식

## 이번 주 주요 작업

- [ ] 고객사 최신 테이블 목록 확보
- [ ] 실제 DB 스키마와 제공 목록 비교
- [ ] 확정/미확정 테이블 분리
- [ ] 매핑 설계 우선순위 반영

## 주요 이슈

- [[07_management/issue_register#ISS-001 고객사 제공 테이블 목록과 실제 DB 스키마 일부 불일치]]

## 주요 리스크

- [[07_management/risk_register#RSK-001 매핑 확정 지연으로 개발 일정 지연 가능]]

## 주요 의사결정

- [[07_management/decision_log#DEC-001 1차 개발은 확정 테이블 기준으로 우선 진행]]

## 주요 링크

- [[001_DOCUMENT_INDEX]]
- [[01_plan/wbs/wbs_summary]]
- [[02_scope/migration_scope]]
- [[04_design/mapping/mapping_policy]]
- [[07_management/issue_register]]
- [[07_management/risk_register]]
- [[07_management/decision_log]]
- [[07_management/action_items]]
- [[08_meetings/weekly/2026-05-27_weekly_meeting]]
```

---

## 11. 문서 간 연결 구조 확인

이제 Obsidian에서 다음 문서를 열어봅니다.

```text
07_management/decision_log.md
```

Backlinks 패널에서 아래 문서가 보이는지 확인합니다.

```text
2026-05-27_weekly_meeting.md
002_PROJECT_DASHBOARD.md
```

다음 문서도 확인합니다.

```text
07_management/issue_register.md
```

Backlinks에서 회의록과 대시보드가 연결되어 있으면 정상입니다.

이 구조가 중요한 이유는 다음 질문에 답할 수 있기 때문입니다.

```text
이 이슈는 어느 회의에서 발생했는가?
이 리스크는 어떤 결정과 연결되는가?
이 결정은 어떤 설계 문서에 반영되어야 하는가?
현재 대시보드에 주요 이슈가 반영되어 있는가?
```

---

## 12. VSCode Todo Tree 확인

VSCode에서 Todo Tree를 엽니다.

아래 태그들이 잡히는지 확인합니다.

```text
DECISION
ISSUE
RISK
TODO
CHECK
QUESTION
```

특히 회의록 파일에서 다음 항목이 보여야 합니다.

```text
DECISION: 1차 개발은 확정 테이블 기준으로 우선 진행한다.
ISSUE: 고객사 제공 테이블 목록과 실제 DB 스키마가 일부 불일치한다.
RISK: 매핑 확정이 지연될 경우 개발 일정이 지연될 수 있다.
TODO: 고객사에 최신 테이블 목록 재요청
CHECK: 실제 DB 스키마와 고객사 제공 목록 비교 필요
QUESTION: 증분 추출 기준 컬럼을 테이블별로 확정할 수 있는지 확인 필요
```

---

## 13. Git 변경사항 확인

WSL 터미널 또는 VSCode 터미널에서 실행합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
git status
```

변경된 파일은 대략 다음과 같습니다.

```text
docs/08_meetings/weekly/2026-05-27_weekly_meeting.md
docs/07_management/issue_register.md
docs/07_management/risk_register.md
docs/07_management/decision_log.md
docs/07_management/action_items.md
docs/002_PROJECT_DASHBOARD.md
```

변경 내용을 확인합니다.

```bash
git diff
```

신규 파일이 많다면 먼저 add 후 staged diff를 봅니다.

```bash
git add docs/
git diff --cached
```

문제가 없으면 커밋합니다.

```bash
git commit -m "docs: connect meeting notes with issue risk decision logs"
```

---

## 14. 실습 결과 확인

이번 장이 끝나면 아래 상태가 되어야 합니다.

| 항목 | 확인 방법 | 기대 결과 |
| --- | --- | --- |
| 회의록 | Obsidian | 회의 내용, 이슈, 리스크, 결정사항 작성 |
| 이슈 등록 | `issue_register.md` | `ISS-001` 등록 |
| 리스크 등록 | `risk_register.md` | `RSK-001` 등록 |
| 의사결정 등록 | `decision_log.md` | `DEC-001` 등록 |
| 액션아이템 등록 | `action_items.md` | `ACT-001` 이상 등록 |
| 대시보드 반영 | `002_PROJECT_DASHBOARD.md` | 주요 이슈/리스크/결정 연결 |
| Todo Tree | VSCode | 태그 목록 표시 |
| Git | `git log --oneline` | 커밋 생성 |

---

## 15. 좋은 작성 습관

PL 문서관리는 꾸준함이 중요합니다.

아래 습관을 추천합니다.

| 습관 | 이유 |
| --- | --- |
| 회의록은 당일 작성 | 맥락을 잃지 않기 위해 |
| 이슈/리스크는 회의록과 분리 등록 | 추적 가능하게 만들기 위해 |
| 결정사항은 반드시 decision_log에 기록 | 나중에 “왜 그렇게 했는지” 설명하기 위해 |
| 액션아이템은 담당자와 기한 포함 | 실행력을 높이기 위해 |
| 대시보드는 매일 갱신 | PL 상태판으로 사용하기 위해 |
| Git commit은 작게 자주 수행 | 변경 이력 추적을 쉽게 하기 위해 |

---

## 16. 이슈·리스크·의사결정 구분 기준

실무에서 자주 헷갈리는 기준입니다.

| 구분 | 기준 | 예시 |
| --- | --- | --- |
| 이슈 | 이미 발생함 | 테이블 목록이 실제 DB와 다름 |
| 리스크 | 발생 가능성이 있는 위험 | 매핑 확정 지연으로 일정 지연 가능 |
| 의사결정 | 선택지 중 하나를 결정 | 확정 테이블부터 개발 진행 |
| 액션아이템 | 누군가 해야 할 일 | 고객사에 최신 목록 요청 |
| 확인사항 | 답이 필요한 질문 | 증분 기준 컬럼 확정 가능 여부 |

---

## 17. 이번 장 핵심 정리

이번 장의 핵심은 다음입니다.

```text
회의록에만 내용을 남기지 않는다.
이슈는 issue_register에 등록한다.
리스크는 risk_register에 등록한다.
결정사항은 decision_log에 등록한다.
후속 조치는 action_items에 등록한다.
대시보드는 주요 현황을 연결한다.
Obsidian은 문서 연결을 보여준다.
VSCode Todo Tree는 태그를 추적한다.
Git은 변경 이력을 남긴다.
```

문서 연결 흐름은 다음과 같습니다.

```text
회의록
  → 이슈
  → 리스크
  → 의사결정
  → 액션아이템
  → 대시보드
```

이 구조가 잡히면 이후 OpenCode Agent가 회의록을 읽고 이슈, 리스크, 의사결정, 액션아이템 초안을 생성하기 쉬워집니다.

다음 장에서는 **6부. OpenCode 적용: PL 업무용 Agent 구성하기**를 진행합니다.
