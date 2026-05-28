# 7부. Subagent 실습: 회의록 요약, 문서 점검, 주간보고 생성하기

이번 장에서는 6부에서 만든 OpenCode Agent 구조를 실제로 사용해봅니다.

이번 장의 핵심은 다음입니다.

```text
PL이 모든 작업을 직접 정리하지 않는다.
회의록 요약은 meeting-summarizer에게 맡긴다.
문서 구조 점검은 docs-curator에게 맡긴다.
주간보고 초안은 report-writer에게 맡긴다.
PL은 결과를 검토하고 공식 문서 반영 여부를 판단한다.
```

---

## 1. 이번 장의 목표

이번 장을 완료하면 다음 작업을 직접 수행할 수 있습니다.

| 실습 | 사용하는 Agent | 결과 |
| --- | --- | --- |
| 회의록 요약 | `meeting-summarizer` | 이슈, 리스크, 결정사항, 액션아이템 추출 |
| 문서 구조 점검 | `docs-curator` | 누락 문서, 인덱스 불일치, 링크 보완사항 확인 |
| 이슈/리스크 분석 | `issue-risk-analyst` | 이슈와 리스크 구분, 영향도/가능성 정리 |
| 주간보고 초안 | `report-writer` | 주간보고 Markdown 초안 생성 |
| PL 종합 정리 | `pl-orchestrator` | 여러 결과를 PL 관점으로 통합 |

---

## 2. 실습 전 준비 상태 확인

WSL 터미널에서 프로젝트 루트로 이동합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
```

Git 상태를 확인합니다.

```bash
git status
```

OpenCode를 실행합니다.

```bash
opencode
```

이번 장에서는 OpenCode 안에서 다음 Agent들을 호출합니다.

```text
@meeting-summarizer
@docs-curator
@issue-risk-analyst
@report-writer
@pl-orchestrator
```

---

## 3. 실습에 사용할 회의록 확인

5부에서 작성한 회의록을 사용합니다.

파일 위치:

```text
docs/08_meetings/weekly/2026-05-27_weekly_meeting.md
```

내용이 없다면 아래 샘플을 사용합니다.

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

## 4. `meeting-summarizer`로 회의록 요약하기

OpenCode에서 다음과 같이 입력합니다.

```text
@meeting-summarizer docs/08_meetings/weekly/2026-05-27_weekly_meeting.md를 기준으로 회의 요약, 결정사항, 이슈, 리스크, 액션아이템을 추출해줘.
```

기대 출력 형식은 다음과 같습니다.

```markdown
## 1. 회의 요약

고객사 제공 테이블 목록과 실제 DB 스키마 간 불일치가 확인되었고, 일부 테이블의 PK 및 증분 기준 컬럼이 미확정 상태다. 전체 범위 확정을 기다리기보다 확정 테이블 기준으로 1차 개발을 우선 진행하기로 했다.

## 2. 주요 결정사항

| 결정사항 | 관련 문서 | 후속 작업 |
|---|---|---|
| 1차 개발은 확정 테이블 기준으로 우선 진행 | decision_log, wbs_summary, mapping_policy | 확정/미확정 테이블 분리 |

## 3. 신규 이슈

| 이슈 | 영향 | 우선순위 | 반영 대상 |
|---|---|---|---|
| 고객사 제공 테이블 목록과 실제 DB 스키마 일부 불일치 | 범위 확정, 매핑 설계, 개발 착수 지연 가능 | High | issue_register |

## 4. 신규 리스크

| 리스크 | 영향도 | 가능성 | 대응 방안 | 반영 대상 |
|---|---|---:|---|---|
| 매핑 확정 지연으로 개발 일정 지연 가능 | High | Medium | 확정/미확정 테이블 분리, 우선순위 기반 개발 | risk_register |

## 5. Action Items

| 작업 | 담당자 | 기한 | 관련 문서 |
|---|---|---|---|
| 고객사에 최신 테이블 목록 재요청 | PL | 미정 | action_items |
| 실제 DB 스키마와 고객사 제공 목록 비교 | 개발팀 | 미정 | action_items |
| 증분 기준 컬럼 확정 가능 여부 확인 | PL | 미정 | action_items |
```

---

## 5. `issue-risk-analyst`로 이슈와 리스크 분석하기

OpenCode에서 다음과 같이 입력합니다.

```text
@issue-risk-analyst docs/08_meetings/weekly/2026-05-27_weekly_meeting.md와 docs/07_management/issue_register.md, docs/07_management/risk_register.md를 기준으로 추가로 관리해야 할 이슈와 리스크를 제안해줘.
```

기대 출력 예시는 다음과 같습니다.

```markdown
| 구분 | 항목 | 영향도 | 가능성 | 대응 방안 | 반영 대상 문서 |
|---|---|---:|---:|---|---|
| 이슈 | 고객사 제공 테이블 목록과 실제 DB 스키마 불일치 | High | 발생 | 최신 목록 재요청 및 실제 DB 기준 재추출 | issue_register |
| 이슈 | 일부 테이블 PK 기준 미확정 | High | 발생 | 테이블별 PK 후보 컬럼 목록 작성 및 고객사 확인 | issue_register |
| 리스크 | 증분 기준 컬럼 확정 지연 | High | Medium | 테이블별 후보 컬럼을 개발팀이 선제 정리 | risk_register |
| 리스크 | 매핑 확정 지연으로 개발 일정 지연 | High | Medium | 확정/미확정 테이블 분리 및 우선순위 개발 | risk_register |
| 리스크 | 검증 기준 수립 지연 | Medium | Medium | row count, sum, null count 기준 우선 정의 | risk_register |
```

---

## 6. `docs-curator`로 문서 구조 점검하기

OpenCode에서 다음과 같이 입력합니다.

```text
@docs-curator docs/001_DOCUMENT_INDEX.md와 실제 docs 폴더 구조를 비교해서 누락 가능 문서, 인덱스 미등록 문서, 링크 보완 필요 문서를 정리해줘.
```

기대 출력 예시는 다음과 같습니다.

```markdown
## 1. 문서 구조 요약

현재 docs 폴더는 admin, plan, scope, architecture, design, execution, validation, management, meetings, reports 구조로 구성되어 있다.

## 2. 누락 가능 문서

| 영역 | 누락 문서 | 필요 이유 | 우선순위 |
|---|---|---|---|
| scope | migration_object_status.md | 전환 대상별 상태 추적 필요 | High |
| design/mapping | mapping_policy.md | 테이블/컬럼 매핑 기준 정의 필요 | High |
| execution | cutover_plan.md | 본전환 계획 수립 필요 | Medium |
| validation | reconciliation_rule.md | 대사 기준 명확화 필요 | High |

## 3. 인덱스 반영 필요 항목

| 문서 | 현재 상태 | 조치 |
|---|---|---|
| docs/07_management/action_items.md | 존재하나 Index 미등록 | 001_DOCUMENT_INDEX.md에 추가 |
| docs/08_meetings/weekly/2026-05-27_weekly_meeting.md | 존재하나 Index 미등록 | 회의록 섹션에 추가 |
```

---

## 7. `report-writer`로 주간보고 초안 작성하기

OpenCode에서 다음과 같이 입력합니다.

```text
@report-writer docs/002_PROJECT_DASHBOARD.md, docs/07_management/issue_register.md, docs/07_management/risk_register.md, docs/07_management/decision_log.md, docs/07_management/action_items.md, docs/08_meetings/weekly/를 기준으로 이번 주 주간보고 초안을 작성해줘.
```

또는 command를 사용할 수 있습니다.

```text
/weekly-report
```

기대 출력 예시는 다음과 같습니다.

```markdown
# 2026-W22 주간보고

## 1. 전체 상태

- 전체 상태: 🟡 주의
- 현재 단계: 분석/설계 준비
- 주요 이슈: 고객사 제공 테이블 목록과 실제 DB 스키마 일부 불일치
- 주요 리스크: 매핑 확정 지연으로 개발 일정 지연 가능

## 2. 금주 진행 현황

- 프로젝트 문서관리 구조 수립
- 회의록, 이슈, 리스크, 의사결정 관리 체계 구성
- 고객사 제공 테이블 목록과 실제 DB 스키마 간 차이 확인
- 확정 테이블 기준 1차 개발 우선 진행 방향 결정

## 3. 주요 완료 작업

| 항목 | 내용 |
|---|---|
| 문서 체계 | VSCode, Obsidian, Git 기반 관리 구조 수립 |
| 관리 문서 | issue_register, risk_register, decision_log 작성 시작 |
| 회의 관리 | 주간회의록 작성 및 액션아이템 도출 |
| 개발 방향 | 확정 테이블 우선 개발 방침 수립 |

## 4. 계획 대비 차이

- 마이그레이션 대상 범위 확정이 일부 지연될 가능성이 있음
- 테이블 목록과 실제 DB 스키마 불일치로 매핑 설계 착수 대상 분리가 필요함

## 5. 주요 이슈

| ID | 이슈 | 영향 | 대응 |
|---|---|---|---|
| ISS-001 | 고객사 제공 테이블 목록과 실제 DB 스키마 일부 불일치 | 매핑 확정 및 개발 착수 지연 가능 | 최신 목록 재요청 및 실제 DB 스키마 비교 |

## 6. 주요 리스크

| ID | 리스크 | 영향도 | 대응 |
|---|---|---:|---|
| RSK-001 | 매핑 확정 지연으로 개발 일정 지연 가능 | High | 확정/미확정 테이블 분리 및 우선순위 개발 |

## 7. 의사결정 필요사항

- 증분 기준 컬럼을 테이블별로 확정할 수 있는지 고객사 확인 필요
- PK 기준이 불명확한 테이블의 업무 기준 확인 필요

## 8. 차주 계획

- 고객사 최신 테이블 목록 확보
- 실제 DB 스키마와 제공 목록 비교
- 확정/미확정 테이블 분리
- 매핑 설계 우선순위 반영
- 검증 기준 초안 작성

## 9. PL 코멘트

현재 가장 중요한 관리 포인트는 전환 대상 범위와 매핑 기준 확정이다. 전체 범위 확정 지연으로 개발 일정이 지연되지 않도록, 확정 테이블과 미확정 테이블을 분리하여 병렬로 관리할 필요가 있다.
```

---

## 8. `pl-orchestrator`로 종합 정리하기

OpenCode에서 다음과 같이 입력합니다.

```text
@pl-orchestrator 현재 docs/002_PROJECT_DASHBOARD.md, docs/07_management, docs/08_meetings/weekly 내용을 기준으로 PL이 오늘 확인해야 할 항목을 정리해줘.
```

기대 출력 예시:

```markdown
## PL 오늘 확인 항목

### 1. 즉시 확인 필요

| 항목 | 이유 | 대상 문서 |
|---|---|---|
| 최신 테이블 목록 요청 상태 | 매핑 설계 착수 기준 | action_items |
| 실제 DB 스키마 비교 진행 여부 | 범위 확정 필요 | issue_register |
| 증분 기준 컬럼 확인 | 개발/검증 기준에 영향 | meeting note, action_items |

### 2. 주요 이슈

- ISS-001: 고객사 제공 테이블 목록과 실제 DB 스키마 일부 불일치

### 3. 주요 리스크

- RSK-001: 매핑 확정 지연으로 개발 일정 지연 가능

### 4. 의사결정 추적

- DEC-001: 확정 테이블 기준 1차 개발 우선 진행

### 5. 오늘의 권장 조치

1. 고객사에 최신 테이블 목록 요청 메일 발송 여부 확인
2. 개발팀의 실제 DB 스키마 비교 결과 수집
3. 확정/미확정 테이블 분리 기준 정의
4. 대시보드 기준일 업데이트
```

---

## 9. `pl-orchestrator`가 판단해야 할 항목

```text
고객사에 어떤 표현으로 요청할 것인가
리스크를 보고자료에 어느 수준으로 표현할 것인가
일정 변경이 필요한가
범위 변경으로 볼 것인가 단순 정정으로 볼 것인가
이슈 우선순위를 High로 유지할 것인가
```

---

## 10. 자주 발생하는 문제

### 10.1 Agent가 문서에 없는 내용을 만들어냄

```text
회의록에 없는 내용은 추정으로 표시하도록 요청한다.
공식 문서 반영 전 PL이 반드시 확인한다.
Agent prompt에 “없는 내용을 사실처럼 쓰지 않는다” 규칙을 강화한다.
```

### 10.2 이슈와 리스크를 혼동함

```text
이미 발생했으면 이슈
앞으로 발생할 수 있으면 리스크
```

### 10.3 보고서 문장이 너무 강함

```text
고객사 보고용으로 완곡하고 객관적인 표현으로 바꿔줘.
확정되지 않은 사항은 확정처럼 표현하지 말아줘.
```

### 10.4 너무 많은 문서를 읽으려 함

```text
참조 문서를 명확히 지정한다.
Graphify 적용 후 GRAPH_REPORT.md를 먼저 보도록 한다.
code-review-graph 적용 후 변경 영향도 결과를 먼저 보도록 한다.
```

### 10.5 파일 수정 요청이 너무 자주 뜸

초기에는 정상입니다. 초기 권한은 안전을 위해 `edit: ask`로 둡니다.

---

## 11. 이번 장 핵심 정리

```text
meeting-summarizer는 회의록을 구조화한다.
issue-risk-analyst는 이슈와 리스크를 분류한다.
docs-curator는 문서 구조와 인덱스를 점검한다.
report-writer는 보고서 초안을 만든다.
pl-orchestrator는 PL 관점에서 결과를 통합한다.
Agent 결과는 초안이며, 공식 반영 전 PL이 검토한다.
Git diff 확인 후 commit한다.
```

실무 반복 흐름은 다음입니다.

```text
회의록 작성
  ↓
meeting-summarizer
  ↓
issue/risk/decision/action 반영
  ↓
docs-curator로 정합성 점검
  ↓
report-writer로 주간보고 초안
  ↓
pl-orchestrator로 PL 확인 항목 정리
  ↓
Git commit
```

다음 장에서는 **8부. Graphify 적용: 프로젝트 지식 그래프 생성 및 OpenCode와 연계하기**를 진행합니다.
```
