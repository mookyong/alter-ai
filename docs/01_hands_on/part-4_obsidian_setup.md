# 4부. Obsidian을 docs 폴더와 연동하기

이번 장에서는 프로젝트의 `docs/` 폴더를 Obsidian Vault로 열고, VSCode와 Obsidian이 같은 문서 원본을 바라보도록 구성합니다.

핵심은 다음입니다.

```text
VSCode  → 프로젝트 루트 전체를 연다.
Obsidian → 프로젝트 안의 docs 폴더만 Vault로 연다.
Git     → 프로젝트 루트 전체를 관리한다.
```

---

## 1. 이번 장의 목표

이번 장을 완료하면 아래 상태가 됩니다.

| 항목 | 결과 |
| --- | --- |
| Obsidian Vault | `docs/` 폴더로 생성 |
| Home 문서 | `000_HOME.md`에서 주요 문서로 이동 가능 |
| Dashboard 문서 | `002_PROJECT_DASHBOARD.md`에서 PL 일일 관리 가능 |
| 내부 링크 | 회의록, 이슈, 리스크, 의사결정 문서 연결 가능 |
| VSCode 연동 | 같은 Markdown 파일을 VSCode와 Obsidian에서 모두 확인 가능 |

---

## 2. 왜 프로젝트 전체가 아니라 docs만 Vault로 여는가

Obsidian은 Markdown 문서 연결과 탐색에 강합니다.
반면 프로젝트 루트에는 문서 외에도 여러 파일이 존재합니다.

```text
data/
scripts/
dbt_project/
.opencode/
.vscode/
.git/
```

이 파일들까지 Obsidian Vault에 포함하면 문서 탐색이 복잡해질 수 있습니다.

그래서 권장 방식은 다음입니다.

```text
프로젝트 루트 전체 = VSCode 관리 대상
docs 폴더만    = Obsidian Vault
```

구조로 보면 다음과 같습니다.

```text
gsr-migration-ai-pl/
├── docs/        ← Obsidian Vault
├── data/
├── scripts/
├── dbt_project/
├── .opencode/
├── .vscode/
└── .git/
```

---

## 3. WSL에서 docs 폴더의 Windows 경로 확인

Obsidian은 Windows 앱으로 실행하는 경우가 많습니다.
WSL 내부 폴더를 Obsidian에서 열려면 Windows 경로가 필요합니다.

WSL 터미널에서 프로젝트 루트로 이동합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
```

`docs` 폴더의 Windows 경로를 확인합니다.

```bash
wslpath -w docs
```

예상 결과:

```text
\\wsl.localhost\Ubuntu\home\<wsl-user>\workspace\gsr-migration-ai-pl\docs
```

또는 환경에 따라 다음처럼 나올 수 있습니다.

```text
\\wsl$\Ubuntu\home\<wsl-user>\workspace\gsr-migration-ai-pl\docs
```

이 경로를 복사해둡니다.

---

## 4. Obsidian에서 Vault 열기

Obsidian을 실행합니다.

처음 실행했거나 새 Vault를 열려면 아래 메뉴를 선택합니다.

```text
Open folder as vault
```

앞 단계에서 확인한 `docs` 경로를 선택합니다.

```text
\\wsl.localhost\Ubuntu\home\<wsl-user>\workspace\gsr-migration-ai-pl\docs
```

정상적으로 열리면 Obsidian 왼쪽 파일 탐색기에 아래 파일들이 보여야 합니다.

```text
000_HOME.md
001_DOCUMENT_INDEX.md
002_PROJECT_DASHBOARD.md
00_admin/
01_plan/
02_scope/
03_architecture/
04_design/
05_execution/
06_validation/
07_management/
08_meetings/
09_reports/
10_knowledge/
90_templates/
91_attachments/
98_private_notes/
99_archive/
```

---

## 5. 먼저 열어볼 문서

Obsidian에서 가장 먼저 열어볼 문서는 다음 3개입니다.

```text
000_HOME.md
001_DOCUMENT_INDEX.md
002_PROJECT_DASHBOARD.md
```

각 문서의 역할은 다음과 같습니다.

| 문서 | 역할 |
| --- | --- |
| `000_HOME.md` | 프로젝트 문서 포털 |
| `001_DOCUMENT_INDEX.md` | 공식 문서 목록과 위치 관리 |
| `002_PROJECT_DASHBOARD.md` | PL 일일 점검 대시보드 |

---

## 6. `000_HOME.md` 사용법

`000_HOME.md`는 프로젝트의 시작 페이지입니다.

예시 구조:

```markdown
# Data Migration Project Home

## 바로가기

- [[001_DOCUMENT_INDEX]]
- [[002_PROJECT_DASHBOARD]]
- [[00_admin/project_overview]]
- [[01_plan/project_plan]]
- [[02_scope/migration_scope]]
- [[03_architecture/architecture_overview]]
- [[05_execution/migration_runbook]]
- [[06_validation/validation_strategy]]
- [[07_management/issue_register]]
- [[07_management/risk_register]]
- [[07_management/decision_log]]

## PL 일일 관리

- [[002_PROJECT_DASHBOARD]]
- [[07_management/action_items]]
- [[08_meetings/weekly]]
- [[09_reports/status_dashboard]]
```

여기서 `[[문서명]]` 형태의 링크를 클릭하면 해당 문서로 이동합니다.

---

## 7. `001_DOCUMENT_INDEX.md` 사용법

`001_DOCUMENT_INDEX.md`는 공식 문서 목록입니다.

예시:

```markdown
# Document Index

## 프로젝트 관리

| 문서 | 위치 | 상태 | 비고 |
|---|---|---|---|
| 프로젝트 개요 | [[00_admin/project_overview]] | 작성중 |  |
| 이해관계자 | [[00_admin/stakeholder]] | 작성중 |  |
| 용어집 | [[00_admin/glossary]] | 작성중 |  |

## 계획

| 문서 | 위치 | 상태 | 비고 |
|---|---|---|---|
| 프로젝트 계획 | [[01_plan/project_plan]] | 작성중 |  |
| WBS 요약 | [[01_plan/wbs/wbs_summary]] | 작성중 |  |
| 마일스톤 | [[01_plan/wbs/milestone]] | 작성중 |  |
```

운영 원칙은 다음입니다.

| 원칙 | 설명 |
| --- | --- |
| 공식 문서는 반드시 Index에 등록 | 최신본 위치 혼란 방지 |
| 문서 상태를 관리 | 작성중, 검토중, 승인, 폐기 등 |
| 산출물 기준 문서 우선 관리 | 보고서, 설계서, Runbook 등 |

---

## 8. `002_PROJECT_DASHBOARD.md` 사용법

PL은 매일 이 문서에서 시작하는 것을 추천합니다.

예시:

```markdown
# Project Dashboard

## 현재 상태

- 전체 상태: 🟡 주의
- 기준일:
- 현재 단계:
- 다음 마일스톤:
- 주요 리스크:
- 주요 의사결정 필요사항:

## 이번 주 주요 작업

- [ ] WBS 업데이트
- [ ] 고객사 테이블 목록 확인
- [ ] 검증 기준 초안 작성

## 주요 링크

- [[01_plan/wbs/wbs_summary]]
- [[07_management/issue_register]]
- [[07_management/risk_register]]
- [[07_management/decision_log]]
- [[07_management/action_items]]
- [[08_meetings/weekly]]
- [[09_reports/weekly_report]]
```

이 문서는 다음 용도로 사용합니다.

| 용도 | 설명 |
| --- | --- |
| 일일 시작점 | 오늘 확인할 문서로 이동 |
| 상태 관리 | 현재 단계, 주요 리스크, 마일스톤 확인 |
| 보고 준비 | 주간보고 작성 전 현황 정리 |
| 이슈 추적 | 주요 이슈, 리스크, 의사결정 확인 |

---

## 9. 내부 링크 작성 방법

Obsidian에서는 `[[...]]` 형식으로 문서 간 링크를 걸 수 있습니다.

예시:

```markdown
관련 이슈: [[07_management/issue_register]]
관련 리스크: [[07_management/risk_register]]
관련 결정: [[07_management/decision_log]]
관련 검증 전략: [[06_validation/validation_strategy]]
```

회의록에서는 다음처럼 활용합니다.

```markdown
## 논의 내용

고객사 제공 테이블 목록과 실제 DB 스키마가 일부 불일치함.

관련 이슈: [[07_management/issue_register]]
관련 결정: [[07_management/decision_log]]
관련 범위 문서: [[02_scope/migration_scope]]
관련 검증 문서: [[06_validation/validation_strategy]]
```

---

## 10. 회의록과 관리 문서 연결 예시

회의록 파일:

```text
docs/08_meetings/weekly/2026-05-27_weekly_meeting.md
```

내용 예시:

```markdown
# 2026-05-27 주간회의

## 주요 논의

고객사 제공 테이블 목록과 실제 DB 스키마가 일부 불일치함.

## 결정사항

DECISION: 1차 개발은 확정 테이블 기준으로 우선 진행

## 이슈

ISSUE: 고객사 제공 테이블 목록과 실제 DB 스키마가 불일치함

## 리스크

RISK: 매핑 확정 지연으로 개발 일정 지연 가능

## 액션아이템

TODO: 고객사에 최신 테이블 목록 재요청
CHECK: 실제 DB 스키마와 제공 목록 비교 필요

## 관련 문서

- [[07_management/issue_register]]
- [[07_management/risk_register]]
- [[07_management/decision_log]]
- [[02_scope/migration_scope]]
- [[04_design/mapping/mapping_policy]]
```

이렇게 작성하면 다음과 같은 효과가 있습니다.

| 효과 | 설명 |
| --- | --- |
| Obsidian | 관련 문서 간 이동 가능 |
| Backlinks | 특정 문서를 참조한 회의록 확인 가능 |
| Todo Tree | `TODO`, `ISSUE`, `RISK` 태그 자동 추적 |
| OpenCode | 회의록에서 구조화된 항목 추출 가능 |

---

## 11. Backlinks 활용법

Obsidian에서 특정 문서를 열면, 해당 문서를 참조하는 다른 문서를 확인할 수 있습니다.

예를 들어 아래 문서를 엽니다.

```text
07_management/decision_log.md
```

Backlinks 패널을 보면 이 문서를 참조한 회의록이 나타날 수 있습니다.

```text
2026-05-27_weekly_meeting.md
```

이 기능을 통해 다음 질문에 답할 수 있습니다.

```text
이 결정은 어느 회의에서 나온 것인가?
이 이슈는 어떤 설계 문서와 연결되는가?
이 리스크는 어떤 주간보고에서 언급되었는가?
```

PL 업무에서는 특히 다음 흐름 추적에 유용합니다.

```text
회의록 → 이슈 → 의사결정 → 설계 → 실행계획 → 검증결과
```

---

## 12. Graph View 활용법

Obsidian의 Graph View는 문서 간 링크 관계를 시각화합니다.

처음부터 복잡하게 사용할 필요는 없습니다.
다만 프로젝트가 커지면 다음 관계를 확인하는 데 도움이 됩니다.

| 확인 대상 | 예시 |
| --- | --- |
| 이슈 중심 연결 | 어떤 회의록과 설계 문서가 연결되어 있는가 |
| 의사결정 중심 연결 | 어떤 문서가 특정 결정에 영향을 받는가 |
| 검증 전략 연결 | 어떤 실행계획과 검증 결과가 연결되는가 |
| 주간보고 연결 | 어떤 이슈/리스크가 보고에 반영되었는가 |

Graph View는 보조 기능입니다.
공식 관리 기준은 `001_DOCUMENT_INDEX.md`와 `002_PROJECT_DASHBOARD.md`를 우선으로 합니다.

---

## 13. Obsidian 설정 파일 관리

Obsidian에서 `docs/`를 Vault로 열면 아래 폴더가 생성됩니다.

```text
docs/.obsidian/
```

이 폴더에는 Obsidian 설정이 저장됩니다.

주의할 점은 다음입니다.

| 파일 | 설명 | Git 관리 권장 |
| --- | --- | --- |
| `appearance.json` | 테마/외관 설정 | 선택 |
| `core-plugins.json` | 기본 플러그인 설정 | 선택 |
| `workspace.json` | 개인 화면 배치 | 제외 권장 |
| `workspace-mobile.json` | 모바일 화면 배치 | 제외 권장 |
| `plugins/` | 커뮤니티 플러그인 | 초기에는 사용 최소화 |

프로젝트의 `.gitignore`에는 아래 항목을 둡니다.

```gitignore
# Obsidian personal workspace
docs/.obsidian/workspace.json
docs/.obsidian/workspaces.json
docs/.obsidian/workspace-mobile.json

# Obsidian trash
docs/.trash/

# Private notes
docs/98_private_notes/
```

이렇게 하면 개인 화면 배치나 개인 메모가 Git에 올라가는 것을 방지할 수 있습니다.

---

## 14. 개인 메모 관리

PL이나 팀원이 개인적으로 메모하고 싶은 내용은 다음 폴더에 둡니다.

```text
docs/98_private_notes/
```

이 폴더는 Git에서 제외하는 것을 추천합니다.

사용 예시:

```text
docs/98_private_notes/customer_meeting_private_note.md
docs/98_private_notes/my_questions.md
docs/98_private_notes/risk_thoughts.md
```

주의할 점:

| 항목 | 설명 |
| --- | --- |
| 고객 공유 불가 내용 | 개인 메모에만 작성 |
| 공식 결정 전 의견 | 공식 문서와 구분 |
| 민감한 판단 | Git에 올리지 않음 |
| 공식화 필요 내용 | 검토 후 issue/risk/decision 문서로 승격 |

---

## 15. VSCode와 Obsidian 동시 사용 시 주의사항

같은 Markdown 파일을 두 도구에서 모두 열 수 있습니다.
하지만 같은 파일을 동시에 수정하는 것은 피하는 것이 좋습니다.

예시:

```text
VSCode에서 decision_log.md 수정 중
동시에 Obsidian에서도 decision_log.md 수정
둘 다 저장
```

이 경우 마지막 저장 내용이 우선 반영되어 변경사항이 덮일 수 있습니다.

권장 방식은 다음입니다.

| 작업 | 추천 도구 |
| --- | --- |
| 회의 중 빠른 기록 | Obsidian |
| 링크 연결 및 탐색 | Obsidian |
| 대량 검색/수정 | VSCode |
| Git diff 확인 | VSCode |
| Todo 태그 점검 | VSCode |
| 최종 커밋 | VSCode 또는 WSL Git |

---

## 16. Obsidian에서 샘플 회의록 작성 실습

Obsidian에서 아래 폴더를 엽니다.

```text
08_meetings/weekly/
```

새 파일을 만듭니다.

```text
2026-05-27_weekly_meeting.md
```

아래 내용을 입력합니다.

```markdown
# 2026-05-27 주간회의

## 참석자

- PL
- 개발팀
- 고객사 담당자

## 주요 논의

고객사 제공 테이블 목록과 실제 DB 스키마가 일부 불일치함.

## 결정사항

DECISION: 1차 개발은 확정 테이블 기준으로 우선 진행

## 이슈

ISSUE: 고객사 제공 테이블 목록과 실제 DB 스키마가 불일치함

## 리스크

RISK: 매핑 확정 지연으로 개발 일정 지연 가능

## 액션아이템

TODO: 고객사에 최신 테이블 목록 재요청
CHECK: 실제 DB 스키마와 제공 목록 비교 필요

## 관련 문서

- [[07_management/issue_register]]
- [[07_management/risk_register]]
- [[07_management/decision_log]]
- [[02_scope/migration_scope]]
```

저장합니다.

---

## 17. VSCode에서 같은 회의록 확인

VSCode에서 동일한 파일을 엽니다.

```text
docs/08_meetings/weekly/2026-05-27_weekly_meeting.md
```

Todo Tree에서 아래 태그가 보이는지 확인합니다.

```text
DECISION
ISSUE
RISK
TODO
CHECK
```

이것이 정상 동작입니다.

즉, 하나의 Markdown 파일을 기준으로:

```text
Obsidian은 문서 연결과 탐색을 담당
VSCode는 태그 추적과 Git 관리를 담당
```

---

## 18. Git 변경사항 확인

WSL 터미널 또는 VSCode 터미널에서 실행합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
git status
```

새 회의록 파일이 변경사항으로 표시됩니다.

```text
docs/08_meetings/weekly/2026-05-27_weekly_meeting.md
```

변경 내용을 확인합니다.

```bash
git diff
```

신규 파일은 `git diff --cached` 전에는 내용이 보이지 않을 수 있으므로 다음처럼 확인합니다.

```bash
git add docs/08_meetings/weekly/2026-05-27_weekly_meeting.md
git diff --cached
```

커밋합니다.

```bash
git commit -m "docs: add weekly meeting note"
```

---

## 19. 이번 장 실습 결과 확인

| 항목 | 확인 방법 | 기대 결과 |
| --- | --- | --- |
| Obsidian Vault | Obsidian 파일 탐색기 | `000_HOME.md`, `001_DOCUMENT_INDEX.md` 표시 |
| docs 경로 | Vault 위치 확인 | `...gsr-migration-ai-pl/docs` |
| 내부 링크 | `[[07_management/issue_register]]` 클릭 | 관련 문서 이동 가능 |
| Backlinks | decision_log 열기 | 참조 회의록 확인 가능 |
| Todo Tree | VSCode 패널 | TODO, ISSUE, RISK 표시 |
| Git 변경 이력 | `git log --oneline` | 회의록 추가 커밋 확인 |

---

## 20. 자주 발생하는 문제

### 20.1 Obsidian에서 WSL 폴더가 안 보임

WSL 경로를 직접 입력해야 할 수 있습니다.

WSL에서 다시 확인합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
wslpath -w docs
```

출력된 경로를 Obsidian의 폴더 선택 창 주소창에 붙여넣습니다.

---

### 20.2 Obsidian에서 파일이 느리게 열림

가능한 원인:

```text
docs 안에 대용량 PDF, 이미지, Excel이 너무 많음
WSL 경로를 Windows 앱에서 접근 중
파일 수가 지나치게 많음
```

대응:

```text
대용량 파일은 data/ 또는 별도 저장소로 이동
docs/91_attachments에는 필요한 첨부만 저장
PDF/Excel 대량 보관은 피함
```

---

### 20.3 내부 링크가 깨짐

원인:

```text
파일명 변경
폴더 이동
링크 경로 불일치
```

대응:

```text
Obsidian 안에서 파일명을 변경하면 링크 자동 업데이트 가능
VSCode에서 대량 파일명 변경 시 링크 확인 필요
001_DOCUMENT_INDEX.md에서 주요 문서 링크 점검
```

---

### 20.4 Obsidian 설정 파일이 Git 변경사항에 계속 나타남

확인:

```bash
git status
```

`docs/.obsidian/workspace.json`이 계속 보이면 `.gitignore`를 확인합니다.

```gitignore
docs/.obsidian/workspace.json
docs/.obsidian/workspaces.json
docs/.obsidian/workspace-mobile.json
```

이미 Git에 추가된 적이 있다면 캐시에서 제거합니다.

```bash
git rm --cached docs/.obsidian/workspace.json
git rm --cached docs/.obsidian/workspaces.json
git rm --cached docs/.obsidian/workspace-mobile.json
```

그다음 커밋합니다.

```bash
git commit -m "chore: ignore Obsidian workspace files"
```

---

## 21. 이번 장 핵심 정리

이번 장에서 반드시 기억할 내용은 다음입니다.

```text
Obsidian은 프로젝트 전체가 아니라 docs 폴더만 연다.
VSCode와 Obsidian은 같은 Markdown 원본을 바라본다.
Obsidian은 문서 연결과 Backlink 추적에 사용한다.
VSCode는 Todo Tree, GitLens, Git commit에 사용한다.
개인 메모와 Obsidian workspace 파일은 Git에서 제외한다.
```

추천 운영 패턴은 다음입니다.

```text
회의록 작성       → Obsidian
TODO/ISSUE 추적  → VSCode Todo Tree
변경 이력 확인   → VSCode GitLens
공식 반영        → Git commit
문서 연결 추적   → Obsidian Backlinks
```

다음 장에서는 **5부. 문서 작성 실습: 회의록, 이슈, 리스크, 의사결정 연결하기**를 진행합니다.
