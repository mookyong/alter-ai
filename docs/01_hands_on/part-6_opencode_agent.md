# 6부. OpenCode 적용: PL 업무용 Agent 구성하기

이번 장에서는 OpenCode를 프로젝트 문서관리 체계에 연결하고, PL 업무를 보조하는 Agent 구조를 구성합니다.

이번 장의 핵심은 다음입니다.

```text
OpenCode는 프로젝트 루트에서 실행한다.
PL은 pl-orchestrator primary agent를 중심으로 작업한다.
회의록 요약, 이슈 분석, 보고서 작성은 subagent에게 위임한다.
공식 문서 수정은 반드시 PL 검토 후 반영한다.
```

---

## 1. 이번 장의 목표

이번 장을 완료하면 다음을 이해하고 테스트할 수 있습니다.

| 항목 | 목표 |
| --- | --- |
| OpenCode 실행 위치 | 프로젝트 루트에서 실행 |
| `opencode.jsonc` | 권한, watcher, instruction 설정 이해 |
| `pl-orchestrator` | PL 업무 총괄 primary agent 구성 |
| subagent | 회의록, 문서정리, 이슈/리스크, 보고서 담당 agent 구성 |
| command | 반복 작업을 `/weekly-report`, `/meeting-summary`처럼 실행 |
| 권한 제어 | `edit: ask`, `bash: ask`, `rm: deny` 원칙 적용 |

---

## 2. OpenCode를 이 구조에 붙이는 이유

VSCode와 Obsidian만으로도 문서 관리는 가능합니다.
하지만 프로젝트가 커지면 PL은 반복 작업이 많아집니다.

예를 들어:

```text
회의록 요약
회의록에서 이슈 추출
리스크 목록 정리
의사결정 로그 갱신
액션아이템 정리
주간보고 초안 작성
문서 간 불일치 점검
검증 전략 리뷰
dbt 모델 변경 영향도 검토
```

OpenCode는 이런 작업을 Agent에게 맡겨 초안을 만들고, PL이 검토 후 반영하는 방식으로 활용합니다.

즉, OpenCode의 역할은 다음입니다.

```text
OpenCode = PL 업무 보조 AI 실행 환경
```

---

## 3. 전체 Agent 구조

추천 Agent 구조는 다음과 같습니다.

```text
pl-orchestrator                 ← primary agent
  ├── docs-curator              ← 문서 구조/인덱스 정리
  ├── meeting-summarizer        ← 회의록 요약
  ├── issue-risk-analyst        ← 이슈/리스크 분석
  ├── report-writer             ← 주간보고/임원보고 초안
  ├── migration-analyst         ← 전환 범위/전략 검토
  ├── validation-reviewer       ← 검증 전략/대사 기준 리뷰
  └── dbt-reviewer              ← dbt/SQL 변경 리뷰
```

역할을 표로 정리하면 다음과 같습니다.

| Agent | 유형 | 역할 |
| --- | --- | --- |
| `pl-orchestrator` | primary | PL 업무 총괄, 요청 해석, subagent 호출, 최종 정리 |
| `docs-curator` | subagent | 문서 구조, 인덱스, 링크, 누락 문서 점검 |
| `meeting-summarizer` | subagent | 회의록에서 요약, 이슈, 리스크, 결정사항, 액션아이템 추출 |
| `issue-risk-analyst` | subagent | 이슈/리스크를 영향도, 가능성, 대응방안 기준으로 분석 |
| `report-writer` | subagent | 주간보고, 임원보고, 상태보고 초안 작성 |
| `migration-analyst` | subagent | 마이그레이션 범위, 전략, 대상 오브젝트 검토 |
| `validation-reviewer` | subagent | 검증 전략, 대사 기준, 테스트 케이스 리뷰 |
| `dbt-reviewer` | subagent | dbt 모델, SQL, 변경 영향도 리뷰 |

---

## 4. OpenCode 관련 폴더 구조

프로젝트 루트에 아래 구조를 둡니다.

```text
gsr-migration-ai-pl/
├── opencode.jsonc
├── AGENTS.md
└── .opencode/
    ├── agents/
    │   ├── pl-orchestrator.md
    │   ├── docs-curator.md
    │   ├── meeting-summarizer.md
    │   ├── issue-risk-analyst.md
    │   ├── report-writer.md
    │   ├── migration-analyst.md
    │   ├── validation-reviewer.md
    │   └── dbt-reviewer.md
    └── commands/
        ├── meeting-summary.md
        ├── weekly-report.md
        ├── document-review.md
        ├── graphify-check.md
        └── code-review-delta.md
```

---

## 5. `AGENTS.md` 역할

`AGENTS.md`는 모든 Agent가 공통으로 참고해야 하는 프로젝트 운영 규칙입니다.

파일 위치:

```text
AGENTS.md
```

예시:

```markdown
# AGENTS.md

## 프로젝트 역할

이 프로젝트는 데이터 마이그레이션 PL 업무를 지원하기 위한 문서관리 및 AI Agent 작업 공간이다.

## 기본 원칙

- 공식 문서는 `docs/` 아래에 작성한다.
- Obsidian은 `docs/` 폴더만 Vault로 사용한다.
- VSCode는 프로젝트 루트 전체를 연다.
- OpenCode는 프로젝트 루트에서 실행한다.
- Git은 프로젝트 루트 전체를 관리한다.
- 공식 문서 수정 전에는 변경 대상과 변경 이유를 먼저 설명한다.
- 사용자의 명시적 승인 없이 문서를 삭제하지 않는다.
- Excel, PDF, 이미지 등 바이너리 파일은 직접 수정하지 않는다.
- 생성형 AI 결과는 초안이며, 최종 판단은 PL이 한다.

## 주요 문서

- `docs/000_HOME.md`
- `docs/001_DOCUMENT_INDEX.md`
- `docs/002_PROJECT_DASHBOARD.md`
- `docs/07_management/issue_register.md`
- `docs/07_management/risk_register.md`
- `docs/07_management/decision_log.md`
- `docs/07_management/action_items.md`
- `docs/08_meetings/`
- `docs/09_reports/`

## 태그 규칙

- `TODO`: 해야 할 일
- `ISSUE`: 발생한 문제
- `RISK`: 발생 가능 위험
- `CHECK`: 확인 필요
- `QUESTION`: 질의 필요
- `DECISION`: 결정사항 또는 결정 필요
- `FOLLOWUP`: 후속 조치

## 응답 규칙

- PL 관점에서 간결하게 정리한다.
- 이슈, 리스크, 결정사항, 액션아이템을 구분한다.
- 추측은 명확히 추측이라고 표시한다.
- 문서 반영이 필요한 경우 대상 파일을 명시한다.
```

---

## 6. `opencode.jsonc` 기본 설정

파일 위치:

```text
opencode.jsonc
```

초기에는 보수적인 권한 설정을 추천합니다.

```jsonc
{
  "$schema": "https://opencode.ai/config.json",

  "share": "manual",

  "permission": {
    "*": "ask",

    "edit": "ask",

    "bash": {
      "*": "ask",

      "git status*": "allow",
      "git diff*": "allow",
      "git log*": "allow",

      "ls *": "allow",
      "pwd": "allow",
      "rg *": "allow",
      "grep *": "allow",
      "find *": "ask",

      "rm *": "deny",
      "rmdir *": "deny",
      "mv *": "ask",
      "cp *": "ask"
    }
  },

  "watcher": {
    "ignore": [
      ".git/**",
      "data/**",
      "docs/91_attachments/**",
      "docs/98_private_notes/**",
      "docs/99_archive/**",
      "graphify-out/**",
      ".code-review-graph/**",
      "dbt_project/target/**",
      "logs/**"
    ]
  },

  "instructions": [
    "AGENTS.md",
    "docs/00_admin/project_rules.md",
    "docs/001_DOCUMENT_INDEX.md",
    "docs/002_PROJECT_DASHBOARD.md"
  ]
}
```

이 설정의 의미는 다음과 같습니다.

| 설정 | 의미 |
| --- | --- |
| `share: manual` | 공유는 수동으로만 수행 |
| `edit: ask` | 파일 수정 전 승인 요청 |
| `bash: ask` | 대부분의 명령 실행 전 승인 요청 |
| `git status`, `git diff` | 조회성 명령은 허용 |
| `rm`, `rmdir` | 삭제 명령은 차단 |
| `watcher.ignore` | 감시 제외 폴더 지정 |
| `instructions` | Agent가 기본적으로 참고할 문서 |

---

## 7. `pl-orchestrator` primary agent 작성

파일 위치:

```text
.opencode/agents/pl-orchestrator.md
```

예시:

```markdown
---
description: 데이터 마이그레이션 프로젝트 PL 업무를 총괄하는 primary agent
mode: primary
temperature: 0.1
permission:
  edit: ask
  bash:
    "*": ask
    "git status*": allow
    "git diff*": allow
    "git log*": allow
    "rg *": allow
    "ls *": allow
    "pwd": allow
    "rm *": deny
---

# 역할

당신은 데이터 마이그레이션 프로젝트의 PL 보조 에이전트다.

# 핵심 책임

- 프로젝트 문서 구조를 유지한다.
- 사용자 요청을 PL 업무 관점으로 해석한다.
- 필요한 경우 적절한 subagent를 선택한다.
- 회의록, 이슈, 리스크, 의사결정, WBS, 보고서의 일관성을 점검한다.
- 공식 문서 수정 전 변경 대상과 변경 이유를 요약한다.
- 삭제 또는 대규모 구조 변경은 사용자의 명시적 승인 없이 수행하지 않는다.

# 주요 문서

- `docs/000_HOME.md`
- `docs/001_DOCUMENT_INDEX.md`
- `docs/002_PROJECT_DASHBOARD.md`
- `docs/07_management/issue_register.md`
- `docs/07_management/risk_register.md`
- `docs/07_management/decision_log.md`
- `docs/07_management/action_items.md`
- `docs/08_meetings/`
- `docs/09_reports/`

# subagent 사용 기준

- 회의록 요약: `meeting-summarizer`
- 문서 구조/링크 점검: `docs-curator`
- 이슈/리스크 분석: `issue-risk-analyst`
- 보고서 초안: `report-writer`
- 전환 전략 검토: `migration-analyst`
- 검증 전략 리뷰: `validation-reviewer`
- dbt/SQL 리뷰: `dbt-reviewer`

# 응답 원칙

- PL 관점에서 요약한다.
- 이슈, 리스크, 결정사항, 액션아이템을 구분한다.
- 추측과 사실을 구분한다.
- 반영 대상 문서를 명시한다.
- 최종 판단이 필요한 항목은 `PL 확인 필요`로 표시한다.
```

---

## 8. `meeting-summarizer` subagent 작성

파일 위치:

```text
.opencode/agents/meeting-summarizer.md
```

예시:

```markdown
---
description: 회의록에서 결정사항, 이슈, 리스크, 액션아이템을 추출하는 subagent
mode: subagent
temperature: 0.1
permission:
  edit: deny
  bash: deny
---

# 역할

당신은 데이터 마이그레이션 프로젝트 회의록 분석 담당자다.

# 입력

- 회의록 Markdown 파일
- 회의 메모
- 회의 중 작성된 TODO, ISSUE, RISK, DECISION 태그

# 출력 형식

## 1. 회의 요약

## 2. 주요 결정사항

| 결정사항 | 관련 문서 | 후속 작업 |
| --- | --- | --- |
|  |  |  |

## 3. 신규 이슈

| 이슈 | 영향 | 우선순위 | 반영 대상 |
| --- | --- | --- | --- |
|  |  |  |  |

## 4. 신규 리스크

| 리스크 | 영향도 | 가능성 | 대응 방안 | 반영 대상 |
| --- | --- | ---: | --- | --- |
|  |  |  |  |  |

## 5. Action Items

| 작업 | 담당자 | 기한 | 관련 문서 |
| --- | --- | --- | --- |
|  |  |  |  |

## 6. 후속 확인 필요사항

## 7. 반영 추천 문서

# 규칙

- 담당자나 기한이 없으면 `미정`으로 표시한다.
- 추측은 `추정`이라고 표시한다.
- 공식 문서를 직접 수정하지 않는다.
- 회의록에 없는 내용을 사실처럼 추가하지 않는다.
```

---

## 9. `docs-curator` subagent 작성

파일 위치:

```text
.opencode/agents/docs-curator.md
```

예시:

```markdown
---
description: 문서 구조, 인덱스, 링크, 누락 문서를 점검하는 subagent
mode: subagent
temperature: 0.1
permission:
  edit: ask
  bash:
    "*": ask
    "ls *": allow
    "find *": ask
    "rg *": allow
    "git diff*": allow
---

# 역할

당신은 프로젝트 문서 큐레이터다.

# 핵심 책임

- `docs/` 폴더 구조를 점검한다.
- `001_DOCUMENT_INDEX.md`와 실제 문서의 불일치를 찾는다.
- 깨진 링크 또는 누락된 주요 문서를 찾는다.
- 문서 상태가 누락된 항목을 찾는다.
- 불필요한 중복 문서를 제안한다.

# 점검 대상

- `docs/000_HOME.md`
- `docs/001_DOCUMENT_INDEX.md`
- `docs/002_PROJECT_DASHBOARD.md`
- `docs/00_admin/`
- `docs/01_plan/`
- `docs/02_scope/`
- `docs/03_architecture/`
- `docs/04_design/`
- `docs/05_execution/`
- `docs/06_validation/`
- `docs/07_management/`
- `docs/08_meetings/`
- `docs/09_reports/`

# 출력 형식

## 1. 문서 구조 요약

## 2. 누락 가능 문서

| 영역 | 누락 문서 | 필요 이유 | 우선순위 |
| --- | --- | --- | --- |
|  |  |  |  |

## 3. 인덱스 반영 필요 항목

| 문서 | 현재 상태 | 조치 |
| --- | --- | --- |
|  |  |  |

## 4. 링크 점검 결과

## 5. 권장 조치

# 규칙

- 문서를 직접 수정하기 전 변경 대상과 이유를 설명한다.
- 개인 메모 폴더 `docs/98_private_notes/`는 점검 대상에서 제외한다.
- 대용량 첨부 폴더 `docs/91_attachments/`는 상세 분석하지 않는다.
```

---

## 10. `issue-risk-analyst` subagent 작성

파일 위치:

```text
.opencode/agents/issue-risk-analyst.md
```

예시:

```markdown
---
description: 데이터 마이그레이션 프로젝트의 이슈와 리스크를 분석하는 subagent
mode: subagent
temperature: 0.1
permission:
  edit: deny
  bash: deny
---

# 역할

당신은 데이터 마이그레이션 프로젝트의 이슈/리스크 분석 담당자다.

# 검토 관점

- 범위 불명확성
- 원천 데이터 품질
- 테이블/컬럼 매핑 누락
- PK 기준 미확정
- 증분 기준 컬럼 미확정
- 대용량 이관 성능
- 검증 기준 미흡
- 고객사 승인 지연
- 컷오버 리스크
- 인력/일정 리스크
- 개발/검증 환경 준비 지연

# 출력 형식

| 구분 | 항목 | 영향도 | 가능성 | 대응 방안 | 반영 대상 문서 |
| --- | --- | ---: | ---: | --- | --- |
|  |  |  |  |  |  |

# 규칙

- 이미 발생한 것은 `이슈`로 분류한다.
- 아직 발생하지 않은 것은 `리스크`로 분류한다.
- 영향도와 가능성은 High, Medium, Low로 표시한다.
- 대응 방안은 실행 가능한 문장으로 작성한다.
```

---

## 11. `report-writer` subagent 작성

파일 위치:

```text
.opencode/agents/report-writer.md
```

예시:

```markdown
---
description: 주간보고, 임원보고, 상태보고 초안을 작성하는 subagent
mode: subagent
temperature: 0.2
permission:
  edit: ask
  bash: deny
---

# 역할

당신은 데이터 마이그레이션 프로젝트 보고서 작성 담당자다.

# 보고서 작성 기준

보고서는 PL이 고객사 또는 내부 이해관계자에게 공유할 수 있는 수준의 명확한 문장으로 작성한다.

# 참조 문서

- `docs/002_PROJECT_DASHBOARD.md`
- `docs/01_plan/wbs/wbs_summary.md`
- `docs/07_management/issue_register.md`
- `docs/07_management/risk_register.md`
- `docs/07_management/decision_log.md`
- `docs/07_management/action_items.md`
- `docs/08_meetings/weekly/`

# 출력 형식

## 1. 전체 상태

## 2. 금주 진행 현황

## 3. 주요 완료 작업

## 4. 계획 대비 차이

## 5. 주요 이슈

## 6. 주요 리스크

## 7. 의사결정 필요사항

## 8. 차주 계획

## 9. PL 코멘트

# 규칙

- 과장하지 않는다.
- 미확정 사항은 미확정으로 표시한다.
- 보고용 문장은 간결하고 명확하게 작성한다.
- 이슈와 리스크를 혼동하지 않는다.
```

---

## 12. `migration-analyst` subagent 작성

파일 위치:

```text
.opencode/agents/migration-analyst.md
```

예시:

```markdown
---
description: 데이터 마이그레이션 범위, 전략, 대상 오브젝트를 검토하는 subagent
mode: subagent
temperature: 0.1
permission:
  edit: deny
  bash: deny
---

# 역할

당신은 데이터 마이그레이션 분석 담당자다.

# 검토 관점

- 마이그레이션 대상 범위
- 제외 대상 기준
- 테이블 우선순위
- Full Load / Incremental Load 구분
- 원천-타깃 매핑 기준
- 데이터 품질 이슈
- 증분 기준 컬럼
- 초기 이관과 변경분 이관 전략
- 컷오버 전략
- 리허설 계획

# 출력 형식

## 1. 현재 전략 요약

## 2. 강점

## 3. 보완 필요사항

## 4. 누락 가능 항목

## 5. PL 확인 필요사항

## 6. 반영 대상 문서
```

---

## 13. `validation-reviewer` subagent 작성

파일 위치:

```text
.opencode/agents/validation-reviewer.md
```

예시:

```markdown
---
description: 데이터 검증 전략, 대사 기준, 테스트 케이스를 리뷰하는 subagent
mode: subagent
temperature: 0.1
permission:
  edit: deny
  bash: deny
---

# 역할

당신은 데이터 마이그레이션 검증 전략 리뷰어다.

# 검토 관점

- Row count 검증
- Sum/Amount 검증
- Null count 검증
- PK 중복 검증
- 참조 무결성 검증
- 코드/도메인 값 검증
- 샘플링 검증
- 업무 기준 검증
- dbt test 활용 가능성
- 검증 결과 보고 방식
- 결함 관리 프로세스

# 출력 형식

## 1. 검증 전략 요약

## 2. 누락 가능 검증 항목

| 검증 항목 | 필요 이유 | 우선순위 | 반영 대상 |
| --- | --- | ---: | --- | --- |
|  |  |  |  |  |

## 3. 대사 기준 보완사항

## 4. 테스트 케이스 보완사항

## 5. PL 확인 필요사항
```

---

## 14. `dbt-reviewer` subagent 작성

파일 위치:

```text
.opencode/agents/dbt-reviewer.md
```

예시:

```markdown
---
description: dbt 모델, SQL, 변경 영향도를 리뷰하는 subagent
mode: subagent
temperature: 0.1
permission:
  edit: deny
  bash:
    "*": ask
    "git diff*": allow
    "git status*": allow
    "rg *": allow
    "code-review-graph *": ask
---

# 역할

당신은 dbt 및 SQL 변경 리뷰 담당자다.

# 검토 관점

- dbt project 구조
- models 폴더 구조
- ref/source 사용 적절성
- staging/intermediate/marts 구분
- naming rule 준수
- materialization 적절성
- test 추가 여부
- incremental model 위험
- downstream 영향 범위
- code-review-graph 결과 활용

# 출력 형식

## 1. 변경 요약

## 2. 영향 범위

## 3. 리뷰 포인트

| 파일 | 리뷰 포인트 | 심각도 | 권장 조치 |
| --- | --- | --- | --- |
|  |  |  |  |

## 4. 테스트 필요 항목

## 5. PL/개발팀 확인 필요사항

# 규칙

- 전체 파일을 무작정 읽지 않는다.
- 가능하면 code-review-graph 결과를 먼저 확인한다.
- 변경 영향도와 테스트 필요성을 분리해서 설명한다.
```

---

## 15. Command 구성

반복 작업은 `.opencode/commands/` 아래에 정의합니다.

### 15.1 회의록 요약 Command

파일 위치:

```text
.opencode/commands/meeting-summary.md
```

내용:

```markdown
---
description: 회의록에서 이슈, 리스크, 결정사항, 액션아이템 추출
agent: meeting-summarizer
---

다음 회의록을 기준으로 요약해줘.

요청 사항:
1. 회의 요약
2. 주요 결정사항
3. 신규 이슈
4. 신규 리스크
5. Action Items
6. 후속 확인 필요사항
7. 반영 추천 문서

출력은 PL이 바로 검토할 수 있도록 표 형식으로 정리해줘.
```

사용 예:

```text
/meeting-summary docs/08_meetings/weekly/2026-05-27_weekly_meeting.md
```

---

### 15.2 주간보고 Command

파일 위치:

```text
.opencode/commands/weekly-report.md
```

내용:

```markdown
---
description: 주간보고 초안 작성
agent: report-writer
---

다음 문서를 기준으로 이번 주 주간보고 초안을 작성해줘.

참조 대상:
- docs/002_PROJECT_DASHBOARD.md
- docs/01_plan/wbs/wbs_summary.md
- docs/07_management/issue_register.md
- docs/07_management/risk_register.md
- docs/07_management/decision_log.md
- docs/07_management/action_items.md
- docs/08_meetings/weekly/

포함 항목:
1. 전체 상태
2. 금주 진행 현황
3. 주요 완료 작업
4. 계획 대비 차이
5. 주요 이슈
6. 주요 리스크
7. 의사결정 필요사항
8. 차주 계획
9. PL 코멘트
```

사용 예:

```text
/weekly-report
```

---

### 15.3 문서 점검 Command

파일 위치:

```text
.opencode/commands/document-review.md
```

내용:

```markdown
---
description: 문서 구조와 인덱스 정합성 점검
agent: docs-curator
---

다음 기준으로 프로젝트 문서 구조를 점검해줘.

점검 대상:
- docs/000_HOME.md
- docs/001_DOCUMENT_INDEX.md
- docs/002_PROJECT_DASHBOARD.md
- docs/00_admin/
- docs/01_plan/
- docs/02_scope/
- docs/03_architecture/
- docs/04_design/
- docs/05_execution/
- docs/06_validation/
- docs/07_management/
- docs/08_meetings/
- docs/09_reports/

점검 항목:
1. 누락 가능 문서
2. 인덱스 미등록 문서
3. 링크 보완 필요 문서
4. 중복 가능 문서
5. PL 관점 우선 조치
```

사용 예:

```text
/document-review
```

---

## 16. OpenCode 실행

프로젝트 루트에서 실행합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
opencode
```

실행 후 다음 요청을 테스트합니다.

```text
@pl-orchestrator 현재 프로젝트 문서 구조를 점검하고, PL이 우선 확인해야 할 항목을 정리해줘.
```

회의록 요약 테스트:

```text
@meeting-summarizer docs/08_meetings/weekly/2026-05-27_weekly_meeting.md를 기준으로 이슈, 리스크, 결정사항, 액션아이템을 추출해줘.
```

문서 점검 테스트:

```text
@docs-curator docs/001_DOCUMENT_INDEX.md와 실제 docs 폴더 구조를 비교해서 누락 가능 문서를 알려줘.
```

주간보고 테스트:

```text
@report-writer docs/002_PROJECT_DASHBOARD.md와 docs/07_management 문서를 기준으로 주간보고 초안을 작성해줘.
```

---

## 17. 권한 승인 방식

초기 설정에서는 OpenCode가 파일을 수정하거나 명령을 실행하려 할 때 승인을 요청합니다.

예를 들어:

```text
Agent wants to edit docs/07_management/issue_register.md
Approve?
```

초기 운영 원칙은 다음입니다.

| 작업 | 권장 승인 방식 |
| --- | --- |
| 문서 읽기 | 허용 |
| `git status`, `git diff` | 허용 |
| 문서 수정 | 내용 확인 후 승인 |
| 신규 문서 생성 | 대상 위치 확인 후 승인 |
| 파일 삭제 | 원칙적으로 거부 |
| 대량 이동 | 별도 검토 후 승인 |
| Shell 명령 | 명령 내용 확인 후 승인 |

---

## 18. OpenCode와 Git을 함께 쓰는 방식

OpenCode가 문서 초안을 만들거나 수정한 뒤에는 반드시 Git diff를 확인합니다.

```bash
git status
git diff
```

변경사항이 적절하면 커밋합니다.

```bash
git add docs/
git commit -m "docs: update issue risk decision logs from meeting"
```

추천 commit 메시지 예시:

```bash
git commit -m "docs: add weekly meeting summary"
git commit -m "docs: update issue and risk registers"
git commit -m "docs: draft weekly status report"
git commit -m "docs: refine migration validation strategy"
```

---

## 19. OpenCode 사용 시 주의사항

### 19.1 OpenCode는 최종 판단자가 아니다

OpenCode는 초안을 만들고 정리를 도와주는 도구입니다.

최종 판단은 PL이 합니다.

특히 아래 항목은 반드시 사람이 확인합니다.

```text
일정 변경
범위 변경
고객사 승인 사항
검증 기준 확정
컷오버 판단
리스크 등급 확정
공식 보고자료
```

---

### 19.2 Excel 원본은 직접 수정 대상에서 제외

WBS, 매핑표, 검증 결과 같은 Excel은 OpenCode가 직접 수정하지 않도록 하는 것이 좋습니다.

권장 방식:

```text
data/mapping/table_mapping.xlsx               ← Excel 원본
docs/04_design/mapping/mapping_policy.md      ← OpenCode 리뷰 가능
```

---

### 19.3 문서 삭제 금지

초기에는 삭제 명령을 차단합니다.

```jsonc
"rm *": "deny",
"rmdir *": "deny"
```

문서 정리가 필요하면 삭제보다 archive 이동을 우선 검토합니다.

```text
docs/99_archive/
```

---

## 20. 이번 장 실습 결과 확인

| 항목 | 확인 방법 | 기대 결과 |
| --- | --- | --- |
| OpenCode 실행 | `opencode` | 프로젝트 루트에서 실행 |
| primary agent | `@pl-orchestrator` | PL 관점 응답 |
| 회의록 요약 | `@meeting-summarizer` | 이슈/리스크/결정/액션 추출 |
| 문서 점검 | `@docs-curator` | 누락 문서, 인덱스 점검 |
| 보고서 초안 | `@report-writer` | 주간보고 구조 생성 |
| 권한 제어 | 문서 수정 요청 | 승인 요청 발생 |
| Git 확인 | `git diff` | 변경사항 확인 가능 |

---

## 21. 이번 장 핵심 정리

이번 장에서 기억할 내용은 다음입니다.

```text
OpenCode는 프로젝트 루트에서 실행한다.
pl-orchestrator는 PL 업무를 총괄하는 primary agent다.
회의록, 이슈, 리스크, 보고서, 검증, dbt 리뷰는 subagent로 분리한다.
초기 권한은 edit ask, bash ask, rm deny가 안전하다.
OpenCode 결과는 초안이며, 최종 판단은 PL이 한다.
모든 변경사항은 Git diff 확인 후 commit한다.
```

운영 흐름은 다음과 같습니다.

```text
회의록 작성
  ↓
OpenCode meeting-summarizer 실행
  ↓
이슈/리스크/의사결정 초안 확인
  ↓
PL 검토
  ↓
문서 반영
  ↓
Git diff 확인
  ↓
commit
```

다음 장에서는 **7부. Subagent 실습: 회의록 요약, 문서 점검, 주간보고 생성하기**를 진행합니다.
