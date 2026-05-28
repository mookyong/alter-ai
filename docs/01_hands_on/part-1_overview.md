# 1부. 전체 개요와 실습 목표

## 1. 문서의 목적

이 문서는 데이터 마이그레이션 프로젝트의 PL 또는 팀원이 아래 환경을 직접 구성하고 사용할 수 있도록 안내하는 실습 문서입니다.

```text
WSL 프로젝트 루트
├─ VSCode: 전체 프로젝트 관리
├─ Obsidian: docs 폴더 기반 문서 연결 관리
├─ Git: 문서 및 설정 변경 이력 관리
├─ OpenCode: PL 업무 보조 AI Agent 실행
├─ Graphify: 프로젝트 지식 그래프 생성
└─ code-review-graph: 코드 변경 영향도 분석
```

이 문서의 목표는 단순히 폴더를 만드는 것이 아닙니다.

최종 목표는 다음과 같습니다.

| 목표 | 설명 |
| --- | --- |
| 문서 원본 단일화 | VSCode용 문서와 Obsidian용 문서를 따로 만들지 않음 |
| PL 업무 표준화 | 회의록, 이슈, 리스크, 의사결정, 보고서를 같은 규칙으로 관리 |
| AI 활용 기반 마련 | OpenCode Agent로 문서 정리, 보고서 초안, 이슈 추출 자동화 |
| 토큰 비용 절감 | Graphify, code-review-graph를 활용해 필요한 문맥만 AI에 제공 |
| 변경 이력 추적 | Git과 GitLens로 문서 변경 내역과 책임 추적 |
| 팀원 교육 가능 | 신규 팀원이 같은 방식으로 프로젝트 문서 체계에 합류 가능 |

---

## 2. 최종 운영 모델

최종 운영 방식은 아래와 같습니다.

```text
프로젝트는 WSL 내부에 둔다.
VSCode는 프로젝트 루트 전체를 연다.
Obsidian은 프로젝트 안의 docs 폴더만 Vault로 연다.
OpenCode는 프로젝트 루트에서 실행한다.
Graphify는 프로젝트 전체 지식 그래프를 만든다.
code-review-graph는 dbt, SQL, Python 등 코드 변경 영향을 분석한다.
```

도구별 역할은 다음과 같습니다.

| 도구 | 여는 위치 | 주요 역할 |
| --- | --- | --- |
| WSL | `~/workspace/프로젝트명` | Linux 기반 작업 공간 |
| VSCode | 프로젝트 루트 전체 | 파일 편집, Git, Todo Tree, GitLens, OpenCode 실행 |
| Obsidian | `docs/` 폴더 | 문서 연결, Backlink, 회의록, 이슈 추적 |
| Git | 프로젝트 루트 전체 | 문서 변경 이력 관리 |
| OpenCode | 프로젝트 루트 | AI Agent 기반 문서/코드 보조 |
| Graphify | 프로젝트 루트 | 문서·코드·구조 지식 그래프 생성 |
| code-review-graph | 프로젝트 루트 | 코드 변경 영향도 분석 |

---

## 3. 전체 폴더 구조

최종적으로 만들 프로젝트 구조는 다음과 같습니다.

```text
gsr-migration-ai-pl/
├── README.md
├── AGENTS.md
├── opencode.jsonc
│
├── docs/                         ← Obsidian Vault
│   ├── 000_HOME.md
│   ├── 001_DOCUMENT_INDEX.md
│   ├── 002_PROJECT_DASHBOARD.md
│   │
│   ├── 00_admin/
│   ├── 01_plan/
│   ├── 02_scope/
│   ├── 03_architecture/
│   ├── 04_design/
│   ├── 05_execution/
│   ├── 06_validation/
│   ├── 07_management/
│   ├── 08_meetings/
│   ├── 09_reports/
│   ├── 10_knowledge/
│   ├── 90_templates/
│   ├── 91_attachments/
│   ├── 98_private_notes/
│   └── 99_archive/
│
├── data/
│   ├── table_inventory/
│   ├── mapping/
│   └── validation_results/
│
├── scripts/
│   ├── sql/
│   ├── python/
│   └── shell/
│
├── dbt_project/
│
├── .opencode/
│   ├── agents/
│   │   ├── pl-orchestrator.md
│   │   ├── docs-curator.md
│   │   ├── meeting-summarizer.md
│   │   ├── issue-risk-analyst.md
│   │   ├── report-writer.md
│   │   ├── migration-analyst.md
│   │   ├── validation-reviewer.md
│   │   └── dbt-reviewer.md
│   │
│   └── commands/
│       ├── meeting-summary.md
│       ├── weekly-report.md
│       ├── document-review.md
│       ├── graphify-check.md
│       └── code-review-delta.md
│
├── .vscode/
│   ├── settings.json
│   └── extensions.json
│
├── .code-review-graphignore
├── .gitattributes
└── .gitignore
```

---

## 4. 폴더별 역할

### 4.1 루트 폴더

| 파일/폴더 | 역할 |
| --- | --- |
| `README.md` | 프로젝트 전체 소개 |
| `AGENTS.md` | OpenCode Agent 공통 작업 지침 |
| `opencode.jsonc` | OpenCode 프로젝트 설정 |
| `.gitignore` | Git 제외 대상 관리 |
| `.gitattributes` | 줄바꿈, 텍스트 파일 규칙 관리 |
| `.vscode/` | VSCode 추천 확장 및 설정 |
| `.opencode/` | OpenCode Agent와 Command 정의 |

### 4.2 `docs/`

`docs/`는 Obsidian Vault로 사용하는 문서 중심 폴더입니다.

```text
docs/
├── 000_HOME.md
├── 001_DOCUMENT_INDEX.md
├── 002_PROJECT_DASHBOARD.md
├── 00_admin/
├── 01_plan/
├── 02_scope/
├── 03_architecture/
├── 04_design/
├── 05_execution/
├── 06_validation/
├── 07_management/
├── 08_meetings/
├── 09_reports/
├── 10_knowledge/
├── 90_templates/
├── 91_attachments/
├── 98_private_notes/
└── 99_archive/
```

| 폴더 | 설명 |
| --- | --- |
| `00_admin` | 프로젝트 개요, 이해관계자, 용어집, 운영 규칙 |
| `01_plan` | WBS, 일정, 리소스 계획 |
| `02_scope` | 마이그레이션 범위, 대상 시스템, 대상 오브젝트 |
| `03_architecture` | AS-IS/TO-BE, 데이터 흐름, 아키텍처 |
| `04_design` | 매핑, 변환 규칙, dbt 설계, 검증 설계 |
| `05_execution` | 이관 실행, 리허설, 컷오버, Runbook |
| `06_validation` | 검증 전략, 체크리스트, 대사 결과 |
| `07_management` | 이슈, 리스크, 의사결정, 액션아이템 |
| `08_meetings` | 회의록 |
| `09_reports` | 주간보고, 임원보고, 상태 대시보드 |
| `10_knowledge` | 프로젝트 지식, 학습 내용, Lessons Learned |
| `90_templates` | 회의록, 보고서, 이슈 템플릿 |
| `91_attachments` | 이미지, PDF 등 첨부파일 |
| `98_private_notes` | 개인 메모, Git 제외 권장 |
| `99_archive` | 종료, 폐기, 과거 문서 |

### 4.3 `data/`

`data/`는 문서보다 데이터성 파일을 보관하는 공간입니다.

예시는 다음과 같습니다.

```text
data/table_inventory/source_table_list.xlsx
data/table_inventory/target_table_list.xlsx
data/mapping/table_mapping.xlsx
data/mapping/column_mapping.xlsx
data/validation_results/reconciliation_result.csv
```

운영 원칙은 아래와 같습니다.

| 원칙 | 설명 |
| --- | --- |
| Excel 원본은 `data/`에 둔다 | WBS, 매핑표, 검증 결과 등 |
| Markdown 요약은 `docs/`에 둔다 | 사람이 읽는 설명 문서 |
| 대용량 파일은 Git 제외를 검토한다 | CSV, Parquet, 대용량 Excel 등 |

### 4.4 `scripts/`

`scripts/`는 보조 스크립트를 두는 공간입니다.

```text
scripts/
├── sql/
├── python/
└── shell/
```

예시는 다음과 같습니다.

```text
scripts/sql/check_row_count.sql
scripts/python/compare_csv.py
scripts/shell/bootstrap_wsl.sh
scripts/shell/run_graphify.sh
scripts/shell/run_code_review_graph.sh
```

### 4.5 `dbt_project/`

`dbt_project/`는 추후 dbt 프로젝트를 둘 수 있는 위치입니다.

초기에는 비워두어도 됩니다.

```text
dbt_project/
├── dbt_project.yml
├── models/
├── macros/
├── seeds/
├── snapshots/
└── tests/
```

---

## 5. 핵심 운영 흐름

팀원은 아래 순서로 업무를 수행합니다.

1. Obsidian에서 회의록 작성
2. 회의록에 `TODO`, `ISSUE`, `RISK`, `DECISION` 태그 작성
3. VSCode Todo Tree에서 미결사항 확인
4. OpenCode `meeting-summarizer`로 회의록 요약
5. `issue_register`, `risk_register`, `decision_log` 반영
6. Git diff로 변경사항 확인
7. Git commit 수행
8. 주간보고 시 `report-writer` Agent 활용

---

## 6. 문서 작성 기본 규칙

문서는 기본적으로 Markdown을 사용합니다.

파일명 규칙은 아래와 같습니다.

| 규칙 | 설명 |
| --- | --- |
| 소문자 | 파일명은 소문자로 작성 |
| 영문 | 가능하면 영문 사용 |
| 언더스코어 사용 | 단어 구분은 `_` 사용 |
| 날짜 형식 | `YYYY-MM-DD` 형식 사용 |

좋은 예시는 다음과 같습니다.

```text
2026-05-27_weekly_meeting.md
decision_log.md
issue_register.md
risk_register.md
validation_strategy.md
migration_runbook.md
```

피하는 것이 좋은 예시는 다음과 같습니다.

```text
주간회의록최종.md
DecisionLog.md
이슈 목록 최종_v2_진짜최종.md
검증전략(수정본).md
```

---

## 7. 태그 사용 규칙

회의록이나 설계 문서 안에는 아래 태그를 사용할 수 있습니다.

| 태그 | 의미 |
| --- | --- |
| `TODO` | 해야 할 일 |
| `FIXME` | 수정 필요 |
| `ISSUE` | 이미 발생한 문제 |
| `RISK` | 발생 가능성이 있는 위험 |
| `CHECK` | 확인 필요 |
| `QUESTION` | 질의 필요 |
| `DECISION` | 결정 사항 또는 결정 필요 |
| `FOLLOWUP` | 후속 조치 필요 |

예시는 다음과 같습니다.

```markdown
TODO: 고객사에 증분 기준 컬럼 확인 요청
ISSUE: 일부 테이블의 PK 기준이 불명확함
RISK: 대용량 테이블 Full Load 시 배치 윈도우 초과 가능성
CHECK: 최신 테이블 목록과 실제 DB 스키마 비교 필요
QUESTION: 대사 기준은 row count만 볼 것인지 금액 합계까지 볼 것인지 확인 필요
DECISION: 1차 개발은 확정 테이블 기준으로 우선 진행
FOLLOWUP: 다음 주간회의에서 검증 기준 재확인
```

이 태그는 VSCode의 Todo Tree 확장에서 자동으로 수집됩니다.

---

## 8. 교육 진행 방식

팀원 교육은 아래 순서로 진행하는 것을 추천합니다.

| 차수 | 주제 | 실습 내용 |
| --- | --- | --- |
| 1부 | 전체 개요 | 구조와 운영 모델 이해 |
| 2부 | WSL 환경 구성 | 프로젝트 압축 해제, Git 초기화, VSCode 실행 |
| 3부 | VSCode 설정 | 추천 확장 설치, Todo Tree, GitLens 확인 |
| 4부 | Obsidian 연동 | `docs/` Vault 열기, Home/Dashboard 확인 |
| 5부 | 문서 작성 실습 | 회의록 작성, TODO/ISSUE/RISK 태그 작성 |
| 6부 | OpenCode 적용 | Agent 구조 이해, `pl-orchestrator` 실행 |
| 7부 | Subagent 실습 | `meeting-summarizer`, `docs-curator`, `report-writer` 사용 |
| 8부 | Graphify 적용 | 프로젝트 지식 그래프 생성 및 활용 |
| 9부 | code-review-graph 적용 | 코드 변경 영향도 분석 |
| 10부 | 운영 표준 | Git commit, 리뷰, 보고서 작성 흐름 정리 |

---

## 9. 이번 1부에서 이해해야 할 핵심

이번 장에서 가장 중요한 내용은 다음입니다.

```text
문서는 docs에 모은다.
VSCode는 프로젝트 전체를 관리한다.
Obsidian은 docs만 Vault로 연다.
OpenCode는 프로젝트 루트에서 실행한다.
Graphify는 전체 지식 지도를 만든다.
code-review-graph는 코드 변경 영향을 분석한다.
Git은 전체 변경 이력을 관리한다.
```

즉, 전체 구조는 다음 한 줄로 요약할 수 있습니다.

```text
WSL 기반 프로젝트 폴더 하나를 중심으로 문서, AI Agent, 지식 그래프, 코드 리뷰 그래프를 통합 관리한다.
```

---

다음 장에서는 **2부. WSL 환경에서 프로젝트 생성 및 압축 해제하기**를 이어서 작성하겠습니다.
