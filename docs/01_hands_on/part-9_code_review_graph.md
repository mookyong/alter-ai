# 9부. code-review-graph 적용: dbt·SQL·코드 변경 영향도 분석하기

이번 장에서는 `code-review-graph`를 적용해 dbt, SQL, Python, Shell 등 코드성 산출물의 변경 영향도를 분석하는 방법을 실습합니다.

이번 장의 핵심은 다음입니다.

```text
Graphify는 프로젝트 지식 지도다.
code-review-graph는 코드 변경 영향도 지도다.
OpenCode는 code-review-graph 결과를 먼저 보고 필요한 파일만 리뷰한다.
```

`code-review-graph`는 Tree-sitter 기반으로 코드 구조를 파싱하고, 함수·클래스·import·호출 관계 등을 그래프로 저장한 뒤 MCP를 통해 AI 도구가 필요한 컨텍스트만 읽도록 돕는 도구입니다.

---

## 1. 이번 장의 목표

이번 장을 완료하면 다음 작업을 할 수 있습니다.

| 항목 | 목표 |
| --- | --- |
| 설치 | WSL 환경에 `code-review-graph` 설치 |
| 초기화 | 프로젝트 루트에서 MCP/OpenCode 연계 설정 |
| 그래프 생성 | 코드 구조 그래프 build |
| 변경 감지 | uncommitted change 기준 영향도 확인 |
| OpenCode 연계 | `dbt-reviewer`가 변경 영향도를 먼저 참고 |
| 운영 기준 | 언제 build/update/watch를 사용할지 정의 |

---

## 2. code-review-graph를 사용하는 이유

OpenCode가 dbt 모델이나 SQL 변경을 리뷰할 때 전체 프로젝트를 모두 읽으면 비효율적입니다.

예를 들어 이런 질문이 있다고 가정합니다.

```text
이번에 수정한 stg_customer.sql이 어떤 mart 모델에 영향을 주는지 리뷰해줘.
```

도구 없이 리뷰하면 Agent가 다음 파일들을 무작정 검색할 수 있습니다.

```text
dbt_project/models/**/*.sql
dbt_project/macros/**/*.sql
dbt_project/tests/**
scripts/sql/**
```

프로젝트가 커질수록 토큰 비용이 커지고, 중요한 영향 파일을 놓칠 수도 있습니다.

`code-review-graph`는 이 문제를 줄이기 위해 코드 구조를 먼저 그래프로 만들고, 변경된 파일과 그 영향 범위를 계산합니다.

---

## 3. Graphify와 code-review-graph 차이

| 구분 | Graphify | code-review-graph |
| --- | --- | --- |
| 주 목적 | 프로젝트 전체 지식 그래프 | 코드 변경 영향도 분석 |
| 주요 대상 | 문서, 코드, 다이어그램, 구조 | 코드, 함수, import, 호출, 변경 파일 |
| PL 활용 | 문서 구조, 온보딩, 관계 파악 | 개발 변경 리뷰, 영향도 확인 |
| dbt 활용 | dbt 구조 개요 파악 | SQL/dbt 변경 영향도 리뷰 |
| OpenCode 활용 | `GRAPH_REPORT.md` 우선 참고 | MCP/CLI 결과 우선 참고 |
| 결과물 | `graphify-out/` | `.code-review-graph/` |

정리하면 다음과 같습니다.

```text
Graphify = 프로젝트를 이해하기 위한 지도
code-review-graph = 변경된 코드가 어디에 영향을 주는지 보는 지도
```

---

## 4. 적용 위치

`code-review-graph`는 프로젝트 루트에서 실행합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
```

결과는 보통 프로젝트 루트 아래에 생성됩니다.

```text
.code-review-graph/
```

이 폴더는 로컬 인덱스/DB 성격이므로 Git 제외를 권장합니다.

`.gitignore`에 추가합니다.

```gitignore
# code-review-graph generated files
.code-review-graph/
```

---

## 5. 분석 대상과 제외 대상

우리 프로젝트에서는 다음 영역이 분석 대상입니다.

```text
dbt_project/
scripts/sql/
scripts/python/
scripts/shell/
```

반대로 다음 영역은 제외하는 것이 좋습니다.

```text
docs/91_attachments/
docs/98_private_notes/
docs/99_archive/
data/
graphify-out/
.code-review-graph/
dbt_project/target/
logs/
*.xlsx
*.pdf
*.png
*.jpg
*.parquet
```

이를 위해 루트에 `.code-review-graphignore` 파일을 둡니다.

추천 내용:

```gitignore
data/**
docs/91_attachments/**
docs/98_private_notes/**
docs/99_archive/**
graphify-out/**
.code-review-graph/**
dbt_project/target/**
logs/**

*.xlsx
*.xls
*.csv
*.pdf
*.png
*.jpg
*.jpeg
*.parquet
*.zip
```

---

## 6. 설치 전 확인

WSL 터미널에서 Python 버전을 확인합니다.

```bash
python3 --version
```

`pipx` 설치 여부를 확인합니다.

```bash
pipx --version
```

없다면 설치합니다.

```bash
sudo apt update
sudo apt install -y pipx
pipx ensurepath
source ~/.bashrc
```

---

## 7. code-review-graph 설치

WSL 프로젝트에서는 `pipx` 설치를 추천합니다.

```bash
pipx install code-review-graph
```

설치 확인:

```bash
code-review-graph --help
```

---

## 8. OpenCode/MCP 연계 설치

프로젝트 루트에서 실행합니다.

```bash
cd ~/workspace/gsr-migration-ai-pl
code-review-graph install
```

설치 후 변경사항을 확인합니다.

```bash
git status
git diff
```

예상 변경 대상은 환경에 따라 다를 수 있습니다.

```text
opencode.jsonc
.opencode/
AGENTS.md
```

변경사항이 있으면 커밋합니다.

```bash
git add opencode.jsonc .opencode AGENTS.md
git commit -m "chore: configure code-review-graph for opencode"
```

---

## 9. 코드 그래프 build

프로젝트 루트에서 실행합니다.

```bash
code-review-graph build
```

상태 확인:

```bash
code-review-graph status
```

---

## 10. 변경 감지 테스트용 샘플 SQL 만들기

테스트용 파일을 만듭니다.

```bash
mkdir -p dbt_project/models/staging
mkdir -p dbt_project/models/marts
```

staging 모델 생성:

```bash
cat > dbt_project/models/staging/stg_customer.sql <<'EOF'
select
    customer_id,
    customer_name,
    updated_at
from raw.customer
EOF
```

mart 모델 생성:

```bash
cat > dbt_project/models/marts/mart_customer.sql <<'EOF'
select
    customer_id,
    customer_name
from {{ ref('stg_customer') }}
EOF
```

현재 상태를 커밋합니다.

```bash
git add dbt_project/models
git commit -m "test: add sample dbt models"
```

다시 그래프를 build합니다.

```bash
code-review-graph build
```

---

## 11. 변경 영향도 확인 실습

이제 `stg_customer.sql`을 수정합니다.

```bash
cat > dbt_project/models/staging/stg_customer.sql <<'EOF'
select
    customer_id,
    customer_name,
    customer_status,
    updated_at
from raw.customer
EOF
```

Git 상태 확인:

```bash
git status
git diff
```

변경 감지 실행:

```bash
code-review-graph detect-changes --brief
```

기대하는 해석은 다음입니다.

```text
변경 파일:
- dbt_project/models/staging/stg_customer.sql

영향 가능 파일:
- dbt_project/models/marts/mart_customer.sql

리뷰 포인트:
- customer_status 컬럼 추가가 downstream mart에 반영되어야 하는지 확인
- dbt test 또는 schema.yml 반영 필요 여부 확인
```

---

## 12. OpenCode에서 변경 리뷰 요청

OpenCode를 실행합니다.

```bash
opencode
```

OpenCode 안에서 다음처럼 요청합니다.

```text
@dbt-reviewer code-review-graph detect-changes 결과를 기준으로 현재 dbt_project 변경분의 영향 범위와 리뷰 포인트를 정리해줘.
```

또는 먼저 CLI 결과를 파일로 저장합니다.

```bash
mkdir -p .tmp
code-review-graph detect-changes --brief > .tmp/code_review_delta.txt
```

OpenCode 요청:

```text
@dbt-reviewer .tmp/code_review_delta.txt와 git diff를 기준으로 현재 변경분의 영향 범위, 테스트 필요 항목, PL 확인 필요사항을 정리해줘.
```

---

## 13. 기대 리뷰 결과

```markdown
## 1. 변경 요약

- `stg_customer.sql`에 `customer_status` 컬럼이 추가됨.

## 2. 영향 범위

| 영향 대상 | 영향 내용 | 확인 필요 |
| --- | --- | --- |
| `mart_customer.sql` | downstream 모델에서 신규 컬럼 사용 여부 검토 필요 | mart에 반영할지 결정 |
| schema.yml | 신규 컬럼 설명/test 추가 필요 가능 | not_null/accepted_values 여부 확인 |
| 검증 SQL | 컬럼 수 또는 컬럼 매핑 검증 기준 변경 가능 | 검증 기준 업데이트 필요 |

## 3. 리뷰 포인트

| 파일 | 리뷰 포인트 | 심각도 | 권장 조치 |
| --- | --- | --- | --- |
| stg_customer.sql | 신규 컬럼이 업무적으로 필요한지 확인 | Medium | 컬럼 정의서와 매핑표 확인 |
| mart_customer.sql | mart에 신규 컬럼을 노출할지 확인 | Medium | PL/업무 협의 필요 |
| schema.yml | 컬럼 test 누락 가능 | Low | 필요 시 dbt test 추가 |

## 4. 테스트 필요 항목

- `dbt run --select stg_customer+`
- `dbt test --select stg_customer+`
- downstream row count 비교
- 컬럼 매핑표 반영 확인

## 5. PL/개발팀 확인 필요사항

- `customer_status`가 target mart에 필요한 컬럼인지 확인
- 고객사 컬럼 정의서에 해당 컬럼이 포함되어 있는지 확인
- 검증 기준에 신규 컬럼 확인을 포함할지 결정
```

---

## 14. `dbt-reviewer`에 code-review-graph 우선 사용 규칙 추가

파일:

```text
.opencode/agents/dbt-reviewer.md
```

아래 내용을 추가합니다.

```markdown
## code-review-graph 사용 규칙

- dbt, SQL, Python, Shell 변경 리뷰는 먼저 `code-review-graph detect-changes --brief` 결과를 확인한다.
- 전체 `dbt_project/`를 무작정 읽지 않는다.
- code-review-graph 결과에서 변경 파일과 영향 파일을 확인한 뒤 필요한 파일만 읽는다.
- code-review-graph 결과가 없거나 오래되었으면 `code-review-graph build` 또는 `code-review-graph update` 실행을 제안한다.
- 최종 판단은 `git diff`와 원본 파일 확인을 기준으로 한다.
```

---

## 15. OpenCode command 만들기

파일:

```text
.opencode/commands/code-review-delta.md
```

내용:

```markdown
---
description: code-review-graph 결과를 기준으로 현재 변경분 리뷰
agent: dbt-reviewer
---

먼저 `code-review-graph detect-changes --brief` 결과를 확인하고, 현재 Git 변경분의 영향 범위를 리뷰해줘.

점검 항목:
1. 변경 파일 요약
2. 영향 가능 파일
3. dbt 모델 downstream 영향
4. SQL/스크립트 리뷰 포인트
5. 테스트 필요 항목
6. PL 또는 개발팀 확인 필요사항

주의:
- 전체 프로젝트를 무작정 읽지 않는다.
- code-review-graph 결과와 `git diff`를 함께 확인한다.
- 결과가 없거나 오래되었으면 build/update 필요성을 알려준다.
```

OpenCode에서 실행:

```text
/code-review-delta
```

---

## 16. 실행 스크립트 만들기

파일:

```text
scripts/shell/run_code_review_graph.sh
```

내용:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[code-review-graph] project root:"
pwd

if ! command -v code-review-graph >/dev/null 2>&1; then
  echo "[ERROR] code-review-graph command not found."
  echo "Install with: pipx install code-review-graph"
  exit 1
fi

echo "[code-review-graph] status"
code-review-graph status || true

echo "[code-review-graph] detect changes"
code-review-graph detect-changes --brief || true

echo "[code-review-graph] done."
```

실행 권한 부여:

```bash
chmod +x scripts/shell/run_code_review_graph.sh
```

실행:

```bash
./scripts/shell/run_code_review_graph.sh
```

---

## 17. build, update, watch 사용 기준

| 명령 | 사용 시점 | 설명 |
| --- | --- | --- |
| `build` | 최초 구성, 대량 변경 후 | 전체 코드 그래프 생성 |
| `update` | 일부 파일 변경 후 | 변경된 파일 중심으로 그래프 갱신 |
| `watch` | 개발 중 지속 감시 | 파일 변경 시 자동 갱신 |
| `status` | 상태 확인 | 그래프 상태 확인 |
| `detect-changes --brief` | 리뷰 전 | 현재 변경분 요약 |
| `visualize` | 그래프 시각화 | 브라우저/파일 기반 확인 |
| `serve` | MCP 연동 | AI 도구가 그래프 질의 가능 |

추천 운영은 다음입니다.

```text
초기 1회:
code-review-graph build

개발 중:
code-review-graph update
또는
code-review-graph watch

리뷰 전:
code-review-graph detect-changes --brief
```

---

## 18. dbt 프로젝트에서의 활용 기준

dbt 프로젝트에서는 특히 다음 변경을 리뷰할 때 유용합니다.

| 변경 유형 | 확인할 영향 |
| --- | --- |
| staging 모델 변경 | downstream intermediate/mart 영향 |
| source 변경 | staging 모델 영향 |
| macro 변경 | macro를 사용하는 모델 전체 영향 |
| schema.yml 변경 | test, docs, column 설명 영향 |
| incremental 모델 변경 | 기존 데이터 재처리 필요 여부 |
| seed 변경 | seed 참조 모델 영향 |
| snapshot 변경 | 이력 테이블 영향 |
| test 추가/삭제 | 검증 커버리지 영향 |

OpenCode 요청 예시는 다음입니다.

```text
@dbt-reviewer code-review-graph 결과를 기준으로 이번 변경이 downstream mart와 dbt test에 미치는 영향을 정리해줘.
```

---

## 19. PL 관점 체크리스트

`code-review-graph` 결과를 받은 뒤 PL은 아래를 확인합니다.

| 체크 항목 | 질문 |
| --- | --- |
| 변경 범위 | 어떤 모델/스크립트가 바뀌었는가 |
| 영향 범위 | downstream 모델이나 검증 SQL에 영향이 있는가 |
| 테스트 범위 | 어떤 dbt run/test가 필요한가 |
| 문서 반영 | 매핑표, 설계서, 검증 전략에 반영이 필요한가 |
| 일정 영향 | 재작업 또는 추가 검증으로 일정 영향이 있는가 |
| 고객 확인 | 업무 기준 또는 컬럼 정의 확인이 필요한가 |

특히 데이터 마이그레이션 프로젝트에서는 코드 변경이 문서 변경으로 이어지는 경우가 많습니다.

예:

```text
stg_customer.sql 컬럼 추가
  ↓
column_mapping.xlsx 반영 필요
  ↓
mapping_policy.md 영향 여부 확인
  ↓
schema.yml test 추가 여부 확인
  ↓
validation_checklist.md 반영 필요
  ↓
주간보고 이슈 또는 변경사항 반영
```

---

## 20. Git hook 관련 주의사항

초기 운영에서는 hook 자동화보다 수동 명령을 추천합니다.

```bash
code-review-graph build
code-review-graph detect-changes --brief
```

안정화 후에만 hook을 검토합니다.

---

## 21. 보안 및 제외 기준

다음 폴더는 제외하는 것이 안전합니다.

```text
data/
docs/98_private_notes/
docs/91_attachments/
.env
*.key
*.pem
```

`.code-review-graphignore`와 `.gitignore`를 함께 사용합니다.

---

## 22. Git 관리 기준

다음은 Git에 올리지 않습니다.

```gitignore
.code-review-graph/
```

다음은 Git에 올립니다.

```text
.code-review-graphignore
.opencode/agents/dbt-reviewer.md
.opencode/commands/code-review-delta.md
scripts/shell/run_code_review_graph.sh
```

---

## 23. 실습 결과 정리

이번 장이 끝나면 아래를 확인합니다.

| 항목 | 확인 방법 | 기대 결과 |
| --- | --- | --- |
| 설치 | `code-review-graph --help` | CLI 도움말 표시 |
| 설치 연계 | `code-review-graph install` | MCP/OpenCode 설정 반영 |
| 그래프 생성 | `code-review-graph build` | 그래프 DB 생성 |
| 상태 확인 | `code-review-graph status` | index 상태 표시 |
| 변경 감지 | `code-review-graph detect-changes --brief` | 변경 요약 표시 |
| OpenCode 리뷰 | `/code-review-delta` | 영향도/리뷰 포인트 출력 |
| Git 제외 | `git status` | `.code-review-graph/` 미표시 |

---

## 24. 자주 발생하는 문제

### 24.1 `code-review-graph: command not found`

```bash
pipx install code-review-graph
```

### 24.2 `build`가 너무 오래 걸림

```text
.code-review-graphignore 점검
data, target, logs 제외
문서 첨부파일 제외
```

### 24.3 변경 영향도가 기대보다 약함

```bash
code-review-graph update
code-review-graph build
code-review-graph detect-changes --brief
```

### 24.4 hook 때문에 commit이 불편해짐

초기에는 hook을 비활성화하거나 수동 실행을 권장합니다.

### 24.5 OpenCode가 전체 파일을 계속 읽으려 함

```markdown
전체 `dbt_project/`를 무작정 읽지 않는다.
먼저 `code-review-graph detect-changes --brief`와 `git diff`를 확인한다.
그 결과에서 필요한 파일만 읽는다.
```

---

## 25. 이번 장 핵심 정리

```text
code-review-graph는 코드 변경 영향도 분석 도구다.
설치 후 install, build, detect-changes 흐름으로 테스트한다.
OpenCode의 dbt-reviewer는 code-review-graph 결과를 먼저 본다.
.code-review-graph/는 Git에 올리지 않는다.
.code-review-graphignore는 Git에 올려 팀 표준으로 관리한다.
Graphify는 프로젝트 지식 지도, code-review-graph는 코드 변경 영향도 지도다.
```

운영 흐름은 다음과 같습니다.

```text
코드/dbt/SQL 수정
  ↓
code-review-graph update 또는 build
  ↓
detect-changes --brief
  ↓
OpenCode dbt-reviewer 실행
  ↓
영향 범위/테스트 범위 확인
  ↓
문서 반영 필요 여부 확인
  ↓
Git diff 확인
  ↓
commit
```

다음 장에서는 **10부. 운영 표준: Git 커밋, 문서 리뷰, 주간보고, 팀 적용 방식 정리**를 진행합니다.
