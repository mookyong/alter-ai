# 10부. 운영 표준: Git 커밋, 문서 리뷰, 주간보고, 팀 적용 방식 정리

이번 장에서는 지금까지 구성한 환경을 실제 프로젝트 팀에서 지속적으로 운영하기 위한 표준 방식을 정리합니다.

이번 장의 핵심은 다음입니다.

```text
문서는 작성보다 운영이 중요하다.
회의록은 이슈·리스크·의사결정·액션아이템으로 연결한다.
OpenCode 결과는 초안이며 PL이 최종 검토한다.
Graphify와 code-review-graph는 AI 품질과 토큰 비용을 관리하기 위한 보조 도구다.
모든 공식 변경은 Git 이력으로 남긴다.
```

---

## 1. 이번 장의 목표

이번 장을 완료하면 팀 운영 기준을 잡을 수 있습니다.

| 항목 | 목표 |
| --- | --- |
| Git 운영 | 문서 변경 이력을 작고 명확하게 관리 |
| 문서 리뷰 | 공식 문서 반영 전 검토 기준 수립 |
| 회의 후속 처리 | 회의록에서 이슈·리스크·결정사항·액션아이템 추출 |
| 주간보고 | 대시보드와 관리 문서를 기준으로 보고서 작성 |
| OpenCode 운영 | Agent 결과를 안전하게 활용 |
| Graph 도구 운영 | Graphify, code-review-graph 재실행 기준 정의 |
| 팀 적용 | 신규 팀원 교육 및 역할 분담 기준 수립 |

---

## 2. 전체 운영 흐름

팀의 기본 운영 흐름은 다음과 같습니다.

```text
회의/작업 발생
  ↓
Obsidian 또는 VSCode에서 Markdown 문서 작성
  ↓
TODO / ISSUE / RISK / DECISION 태그 작성
  ↓
OpenCode Agent로 초안 정리
  ↓
PL 검토
  ↓
공식 관리 문서 반영
  ↓
VSCode에서 Git diff 확인
  ↓
Git commit
  ↓
필요 시 Graphify / code-review-graph 갱신
  ↓
주간보고 반영
```

이 흐름을 유지하면 프로젝트 산출물이 단순 파일 더미가 아니라, 추적 가능한 관리 체계가 됩니다.

---

## 3. Git 운영 표준

### 3.1 Git은 WSL 기준으로 사용

WSL 환경에서는 Git을 WSL에서 통일해서 사용하는 것을 권장합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
git status
```

피해야 할 방식:

```text
WSL Git으로 일부 commit
Windows Git Bash로 일부 commit
SourceTree로 일부 commit
VSCode Windows 로컬로 일부 commit
```

여러 Git 클라이언트를 섞으면 줄바꿈, 파일 권한, 변경 감지 기준이 달라질 수 있습니다.

권장 방식:

```text
Git CLI는 WSL에서 실행
VSCode도 WSL Remote 상태에서 사용
GitLens는 변경 이력 확인용으로 사용
```

---

### 3.2 커밋 전 기본 확인

문서나 설정을 수정한 뒤 항상 아래 순서로 확인합니다.

```bash
git status
git diff
```

신규 파일이 포함되어 있다면:

```bash
git add docs/
git diff --cached
```

문제가 없으면 commit합니다.

```bash
git commit -m "docs: update weekly meeting notes"
```

---

### 3.3 추천 커밋 단위

커밋은 너무 크지 않게 나누는 것이 좋습니다.

| 좋은 커밋 단위 | 예시 |
| --- | --- |
| 회의록 1건 추가 | `docs: add weekly meeting note` |
| 이슈/리스크 갱신 | `docs: update issue and risk registers` |
| 주간보고 초안 추가 | `docs: add weekly report draft` |
| OpenCode Agent 수정 | `chore: update opencode agents` |
| VSCode 설정 변경 | `chore: update vscode workspace settings` |
| Graph 도구 설정 추가 | `chore: add graph tool configuration` |

피해야 할 커밋:

```text
update
fix
문서수정
최종
진짜최종
작업내용반영
```

---

### 3.4 추천 커밋 메시지 규칙

간단한 Conventional Commit 스타일을 추천합니다.

```text
docs: 문서 변경
chore: 설정/도구 변경
test: 테스트용 샘플 추가
fix: 문서 오류 수정
refactor: 문서 구조 정리
```

예시:

```bash
git commit -m "docs: add customer weekly meeting note"
git commit -m "docs: update decision log from scope review"
git commit -m "docs: draft weekly status report"
git commit -m "chore: add opencode meeting summarizer agent"
git commit -m "chore: ignore graph generated files"
git commit -m "test: add sample dbt models for review graph"
```

---

### 3.5 Git에 올리는 것과 제외하는 것

Git에 올리는 항목:

```text
README.md
AGENTS.md
opencode.jsonc
docs/**/*.md
.opencode/agents/*.md
.opencode/commands/*.md
.vscode/settings.json
.vscode/extensions.json
.gitattributes
.gitignore
.code-review-graphignore
scripts/shell/*.sh
```

Git에서 제외하는 항목:

```text
graphify-out/
.code-review-graph/
docs/98_private_notes/
docs/.obsidian/workspace.json
docs/.obsidian/workspaces.json
docs/.obsidian/workspace-mobile.json
data/**/*.parquet
대용량 CSV
민감정보 파일
```

권장 `.gitignore` 예시:

```gitignore
# Obsidian personal workspace
docs/.obsidian/workspace.json
docs/.obsidian/workspaces.json
docs/.obsidian/workspace-mobile.json
docs/.trash/

# Private notes
docs/98_private_notes/

# Generated graph/index files
graphify-out/
.code-review-graph/

# Data / large files
data/**/*.parquet
data/**/*.zip
data/**/*.gz

# Logs / temp
logs/
.tmp/
*.log

# Secrets
.env
*.key
*.pem
```

---

## 4. 문서 운영 표준

### 4.1 공식 문서 위치

공식 문서는 `docs/` 아래에 둡니다.

```text
docs/
├── 00_admin/
├── 01_plan/
├── 02_scope/
├── 03_architecture/
├── 04_design/
├── 05_execution/
├── 06_validation/
├── 07_management/
├── 08_meetings/
└── 09_reports/
```

문서 유형별 위치는 다음과 같습니다.

| 문서 유형 | 위치 |
| --- | --- |
| 프로젝트 개요 | `docs/00_admin/project_overview.md` |
| WBS 요약 | `docs/01_plan/wbs/wbs_summary.md` |
| 범위 정의 | `docs/02_scope/migration_scope.md` |
| 아키텍처 | `docs/03_architecture/architecture_overview.md` |
| 매핑 기준 | `docs/04_design/mapping/mapping_policy.md` |
| 전환 Runbook | `docs/05_execution/migration_runbook.md` |
| 검증 전략 | `docs/06_validation/validation_strategy.md` |
| 이슈 | `docs/07_management/issue_register.md` |
| 리스크 | `docs/07_management/risk_register.md` |
| 의사결정 | `docs/07_management/decision_log.md` |
| 회의록 | `docs/08_meetings/` |
| 주간보고 | `docs/09_reports/weekly_report/` |

---

### 4.2 문서 상태 관리

공식 문서는 상태를 표시합니다.

추천 상태:

| 상태 | 의미 |
| --- | --- |
| Draft | 초안 |
| Review | 검토 중 |
| Approved | 승인 또는 기준 확정 |
| Deprecated | 더 이상 사용하지 않음 |
| Archived | 보관됨 |

문서 상단에 속성을 둘 수 있습니다.

```markdown
---
type: report
status: Draft
owner: PL
date: 2026-05-27
tags:
  - weekly-report
---
```

---

### 4.3 문서명 규칙

파일명은 아래 규칙을 따릅니다.

```text
소문자
영문
언더스코어
날짜는 YYYY-MM-DD
```

좋은 예:

```text
2026-05-27_weekly_meeting.md
2026-W22_weekly_report.md
decision_log.md
issue_register.md
risk_register.md
validation_strategy.md
migration_runbook.md
```

피해야 할 예:

```text
회의록최종.md
문서_v1_진짜최종.md
DecisionLog.md
검증전략(수정).md
```

---

### 4.4 문서 인덱스 관리

`docs/001_DOCUMENT_INDEX.md`는 반드시 관리합니다.

새 공식 문서를 만들면 Index에 등록합니다.

운영 원칙:

```text
문서를 만들면 Index에 등록한다.
폐기 문서는 Deprecated 또는 Archived로 표시한다.
주요 문서는 Dashboard에서 링크한다.
```

---

## 5. 회의록 운영 표준

### 5.1 회의록 작성 위치

회의 유형별로 폴더를 나눕니다.

```text
docs/08_meetings/
├── daily/
├── weekly/
├── customer/
├── technical/
└── steering/
```

파일명 예시:

```text
2026-05-27_weekly_meeting.md
2026-05-28_customer_scope_review.md
2026-05-29_technical_mapping_review.md
```

---

### 5.2 회의록 기본 템플릿

```markdown
# YYYY-MM-DD 회의명

## 1. 회의 정보

- 일시:
- 회의 유형:
- 참석자:

## 2. 주요 논의 내용

## 3. 결정사항

DECISION:

## 4. 이슈

ISSUE:

## 5. 리스크

RISK:

## 6. 액션아이템

TODO:
CHECK:
QUESTION:

## 7. 관련 문서

- [[07_management/issue_register]]
- [[07_management/risk_register]]
- [[07_management/decision_log]]
- [[07_management/action_items]]
```

---

### 5.3 회의 후 10분 처리 규칙

회의가 끝나면 바로 아래 작업을 수행합니다.

```text
1. 회의록 저장
2. TODO / ISSUE / RISK / DECISION 태그 확인
3. meeting-summarizer 실행
4. 이슈/리스크/결정사항/액션아이템 초안 확인
5. 공식 관리 문서 반영 여부 결정
```

---

## 6. 이슈·리스크·의사결정 운영 표준

### 6.1 이슈와 리스크 구분

| 구분 | 기준 | 예시 |
| --- | --- | --- |
| 이슈 | 이미 발생한 문제 | 테이블 목록과 실제 DB가 다름 |
| 리스크 | 발생 가능성이 있는 위험 | 매핑 확정 지연으로 일정 지연 가능 |
| 의사결정 | 선택지 중 하나를 결정 | 확정 테이블부터 개발 진행 |
| 액션아이템 | 누가 해야 하는 일 | 고객사에 최신 테이블 목록 요청 |

---

### 6.2 이슈 등록 기준

다음 중 하나에 해당하면 `issue_register.md`에 등록합니다.

```text
일정에 영향이 있다.
범위에 영향이 있다.
품질에 영향이 있다.
고객사 확인이 필요하다.
반복적으로 언급된다.
담당자와 후속 조치가 필요하다.
```

---

### 6.3 리스크 등록 기준

다음 중 하나에 해당하면 `risk_register.md`에 등록합니다.

```text
아직 발생하지 않았지만 가능성이 있다.
발생 시 일정/품질/범위에 영향이 크다.
사전에 대응 방안이 필요하다.
보고 대상이 될 수 있다.
```

---

### 6.4 의사결정 등록 기준

다음은 반드시 `decision_log.md`에 남깁니다.

```text
전환 범위 결정
검증 기준 결정
개발 우선순위 결정
컷오버 방식 결정
리허설 방식 결정
일정 기준 변경
도구/아키텍처 결정
고객사 승인 사항
```

---

## 7. OpenCode 운영 표준

### 7.1 OpenCode 실행 위치

항상 프로젝트 루트에서 실행합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
opencode
```

---

### 7.2 Agent 사용 기준

| 작업 | Agent |
| --- | --- |
| 전체 PL 관점 정리 | `@pl-orchestrator` |
| 회의록 요약 | `@meeting-summarizer` |
| 문서 구조 점검 | `@docs-curator` |
| 이슈/리스크 분석 | `@issue-risk-analyst` |
| 주간보고 초안 | `@report-writer` |
| 전환 전략 검토 | `@migration-analyst` |
| 검증 전략 리뷰 | `@validation-reviewer` |
| dbt/SQL 변경 리뷰 | `@dbt-reviewer` |

---

### 7.3 OpenCode 요청 예시

회의록 요약:

```text
@meeting-summarizer docs/08_meetings/weekly/2026-05-27_weekly_meeting.md를 기준으로 이슈, 리스크, 결정사항, 액션아이템을 추출해줘.
```

문서 점검:

```text
@docs-curator docs/001_DOCUMENT_INDEX.md와 실제 docs 폴더 구조를 비교해서 누락 가능 문서를 알려줘.
```

주간보고:

```text
@report-writer docs/002_PROJECT_DASHBOARD.md와 docs/07_management 문서를 기준으로 이번 주 주간보고 초안을 작성해줘.
```

PL 종합:

```text
@pl-orchestrator 현재 주요 이슈, 리스크, 의사결정, 액션아이템 기준으로 오늘 PL이 확인해야 할 항목을 정리해줘.
```

---

### 7.4 OpenCode 결과 반영 원칙

OpenCode 결과는 초안입니다.

공식 반영 전에는 다음을 확인합니다.

| 확인 항목 | 설명 |
| --- | --- |
| 사실 여부 | 문서에 없는 내용을 추가하지 않았는가 |
| 표현 수위 | 고객사 공유 가능한 표현인가 |
| 이슈/리스크 구분 | 이미 발생한 것과 가능성이 구분되었는가 |
| 담당자/기한 | 미정이면 미정으로 표시했는가 |
| 반영 대상 | 적절한 문서에 반영하는가 |
| 보안 | 민감정보가 포함되지 않았는가 |

---

## 8. Graphify 운영 표준

### 8.1 Graphify 역할

```text
Graphify = 프로젝트 지식 지도
```

주요 용도:

```text
프로젝트 구조 파악
문서 관계 파악
신규 팀원 온보딩
OpenCode 컨텍스트 절감
문서 누락 점검
```

---

### 8.2 실행 명령

```bash
cd ~/workspace/gsr-migration-ai-pl
graphify .
```

또는 스크립트:

```bash
./scripts/shell/run_graphify.sh
```

---

### 8.3 재실행 기준

| 시점 | 재실행 여부 |
| --- | --- |
| 주요 문서 구조 변경 | 실행 |
| 핵심 문서 대량 추가 | 실행 |
| dbt 모델 대량 추가 | 실행 |
| 신규 팀원 온보딩 전 | 실행 |
| 주간 문서 점검 전 | 선택 |
| 회의록 1건 추가 | 보통 생략 가능 |

---

### 8.4 OpenCode 사용 규칙

Agent 지침에 다음 원칙을 둡니다.

```text
프로젝트 구조나 문서 관계 질문은 graphify-out/GRAPH_REPORT.md를 먼저 확인한다.
전체 docs를 무작정 읽지 않는다.
Graphify 결과가 부족하면 원본 문서를 확인한다.
최종 근거는 원본 문서다.
```

---

## 9. code-review-graph 운영 표준

### 9.1 code-review-graph 역할

```text
code-review-graph = 코드 변경 영향도 지도
```

주요 용도:

```text
dbt 모델 변경 영향도 확인
SQL 변경 리뷰
Python/Shell 스크립트 변경 리뷰
리뷰 대상 파일 축소
테스트 필요 범위 도출
```

---

### 9.2 기본 명령

최초 또는 대량 변경 후:

```bash
code-review-graph build
```

상태 확인:

```bash
code-review-graph status
```

변경 영향도 확인:

```bash
code-review-graph detect-changes --brief
```

스크립트 실행:

```bash
./scripts/shell/run_code_review_graph.sh
```

---

### 9.3 dbt 변경 리뷰 흐름

```text
dbt 모델 수정
  ↓
code-review-graph detect-changes --brief
  ↓
@dbt-reviewer 실행
  ↓
영향 모델 확인
  ↓
dbt run/test 범위 확인
  ↓
문서 반영 필요 여부 확인
  ↓
Git diff 확인
  ↓
commit
```

---

## 10. 주간보고 운영 표준

### 10.1 보고 전 확인 문서

주간보고 작성 전 아래 문서를 확인합니다.

```text
docs/002_PROJECT_DASHBOARD.md
docs/01_plan/wbs/wbs_summary.md
docs/07_management/issue_register.md
docs/07_management/risk_register.md
docs/07_management/decision_log.md
docs/07_management/action_items.md
docs/08_meetings/weekly/
```

---

### 10.2 주간보고 생성 요청

OpenCode에서 실행:

```text
/weekly-report
```

또는 직접 요청:

```text
@report-writer docs/002_PROJECT_DASHBOARD.md, docs/07_management, docs/08_meetings/weekly 내용을 기준으로 이번 주 주간보고 초안을 작성해줘.
```

---

### 10.3 주간보고 저장 위치

```text
docs/09_reports/weekly_report/2026-W22_weekly_report.md
```

---

### 10.4 주간보고 검토 기준

| 검토 항목 | 설명 |
| --- | --- |
| 전체 상태 | 정상/주의/위험이 적절한가 |
| 진행 현황 | 실제 수행 내용과 맞는가 |
| 계획 대비 차이 | 일정 차이가 명확한가 |
| 주요 이슈 | 관리 대상 이슈가 포함되었는가 |
| 주요 리스크 | 과소/과대 표현되지 않았는가 |
| 의사결정 필요사항 | 고객사/내부 요청이 명확한가 |
| 차주 계획 | 실행 가능한 단위인가 |
| 표현 | 고객사 보고용으로 적절한가 |

---

## 11. 팀 역할 분담

초기 팀 운영에서는 다음 역할을 권장합니다.

| 역할 | 담당 |
| --- | --- |
| PL | Dashboard, 이슈, 리스크, 의사결정, 주간보고 최종 승인 |
| 개발 리드 | dbt/SQL 변경 영향도, 개발 일정, 테스트 범위 |
| 개발자 | 모델/스크립트 작성, 테스트 결과 기록 |
| 검증 담당 | 검증 전략, 대사 결과, 결함 관리 |
| 문서 담당 또는 PMO | 회의록, 문서 인덱스, 보고자료 정리 |

---

## 12. 신규 팀원 온보딩 절차

신규 팀원에게는 아래 순서로 교육합니다.

```text
1. WSL 프로젝트 위치 안내
2. VSCode로 프로젝트 루트 열기
3. Obsidian으로 docs Vault 열기
4. 000_HOME.md 확인
5. 002_PROJECT_DASHBOARD.md 확인
6. 001_DOCUMENT_INDEX.md 확인
7. issue_register, risk_register, decision_log 확인
8. Todo Tree 사용법 확인
9. OpenCode Agent 사용법 확인
10. Git commit 규칙 확인
```

신규 팀원에게 가장 먼저 보게 할 문서:

```text
docs/000_HOME.md
docs/001_DOCUMENT_INDEX.md
docs/002_PROJECT_DASHBOARD.md
AGENTS.md
README.md
```

---

## 13. 일일 운영 루틴

PL 기준 일일 루틴입니다.

```text
1. Obsidian에서 002_PROJECT_DASHBOARD.md 열기
2. issue_register.md 확인
3. risk_register.md 확인
4. action_items.md 확인
5. Todo Tree에서 TODO/QUESTION/CHECK 확인
6. 필요한 회의록 작성 또는 갱신
7. OpenCode로 요약/점검 요청
8. Git diff 확인
9. commit
```

---

## 14. 주간 운영 루틴

```text
1. 주간회의록 작성
2. meeting-summarizer 실행
3. issue/risk/decision/action 반영
4. docs-curator로 문서 구조 점검
5. Dashboard 업데이트
6. report-writer로 주간보고 초안 생성
7. PL 검토
8. Git commit
9. 필요 시 Graphify 재실행
```

---

## 15. 단계 전환 시 운영 루틴

프로젝트 단계가 바뀔 때는 문서 점검을 강화합니다.

예:

```text
분석 → 설계
설계 → 개발
개발 → 검증
검증 → 리허설
리허설 → 본전환
```

점검 항목:

| 문서 | 확인 내용 |
| --- | --- |
| `migration_scope.md` | 범위 확정 여부 |
| `wbs_summary.md` | 일정 변경 반영 여부 |
| `mapping_policy.md` | 매핑 기준 확정 여부 |
| `validation_strategy.md` | 검증 기준 확정 여부 |
| `migration_runbook.md` | 실행 절차 준비 여부 |
| `cutover_plan.md` | 본전환 절차 준비 여부 |
| `risk_register.md` | 주요 리스크 최신화 여부 |
| `decision_log.md` | 주요 결정 누락 여부 |

---

## 16. 품질 관리 체크리스트

| 항목 | 확인 |
| --- | --- |
| 문서가 올바른 폴더에 있는가 | ☐ |
| 파일명이 규칙을 따르는가 | ☐ |
| 상태가 명시되어 있는가 | ☐ |
| 관련 문서 링크가 있는가 | ☐ |
| 이슈/리스크/결정사항이 분리되어 있는가 | ☐ |
| 담당자와 기한이 있는가 | ☐ |
| 고객사 공유 가능한 표현인가 | ☐ |
| Git commit이 남아 있는가 | ☐ |

---

## 17. AI 사용 품질 체크리스트

| 항목 | 확인 |
| --- | --- |
| 원문 문서에 없는 내용이 추가되지 않았는가 | ☐ |
| 추측이 사실처럼 표현되지 않았는가 | ☐ |
| 이슈와 리스크가 구분되었는가 | ☐ |
| 보고용 표현이 과하지 않은가 | ☐ |
| 반영 대상 문서가 적절한가 | ☐ |
| 민감정보가 포함되지 않았는가 | ☐ |
| 최종 판단이 필요한 항목이 표시되었는가 | ☐ |
| Git diff로 변경사항을 확인했는가 | ☐ |

---

## 18. 최종 권장 운영 원칙

```text
1. 문서 원본은 하나만 둔다.
2. Obsidian은 docs 폴더만 Vault로 연다.
3. VSCode는 프로젝트 루트 전체를 연다.
4. OpenCode는 프로젝트 루트에서 실행한다.
5. 공식 문서는 Markdown 중심으로 관리한다.
6. 회의록은 이슈, 리스크, 결정사항, 액션아이템으로 연결한다.
7. OpenCode 결과는 초안으로만 사용한다.
8. Graphify는 프로젝트 지식 지도다.
9. code-review-graph는 코드 변경 영향도 지도다.
10. 모든 공식 변경은 Git으로 남긴다.
```

---

## 19. 전체 구조 최종 요약

```text
WSL ~/workspace/gsr-migration-ai-pl
├── VSCode
│   ├── 전체 프로젝트 편집
│   ├── Todo Tree
│   ├── GitLens
│   └── Excel Viewer
│
├── Obsidian
│   └── docs Vault
│       ├── 회의록
│       ├── 이슈
│       ├── 리스크
│       ├── 의사결정
│       └── 보고서
│
├── OpenCode
│   ├── pl-orchestrator
│   ├── meeting-summarizer
│   ├── docs-curator
│   ├── issue-risk-analyst
│   ├── report-writer
│   ├── migration-analyst
│   ├── validation-reviewer
│   └── dbt-reviewer
│
├── Graphify
│   └── 프로젝트 지식 그래프
│
├── code-review-graph
│   └── 코드 변경 영향도 그래프
│
└── Git
    └── 모든 공식 변경 이력
```

---

## 20. 마무리

이 문서관리 체계는 단순히 도구를 많이 붙이는 것이 목적이 아닙니다.

핵심은 다음입니다.

```text
PL이 프로젝트 상황을 빠르게 파악하고,
팀원이 같은 기준으로 문서를 작성하고,
AI Agent가 반복 작업을 줄이고,
Git이 변경 이력을 남기고,
Graph 도구가 AI의 문맥 비용을 줄이는 구조를 만드는 것
```

실무에서는 처음부터 모든 것을 완벽하게 적용하지 않아도 됩니다.

추천 도입 순서는 다음입니다.

```text
1단계: WSL + VSCode + Git
2단계: docs 폴더 + Obsidian
3단계: Todo Tree + GitLens
4단계: OpenCode + pl-orchestrator
5단계: meeting-summarizer, docs-curator, report-writer
6단계: Graphify
7단계: code-review-graph
8단계: 팀 표준화 및 주간 운영 루틴 정착
```

이 순서로 적용하면 부담 없이 시작하면서도, 프로젝트가 커질수록 문서 품질과 AI 활용 효과를 함께 높일 수 있습니다.
