# GSR LLM Wiki PoC

GSR 데이터 전환 프로젝트의 Markdown 문서를 AI 전용 지식베이스로 정리하기 위한 LLM Wiki 실습 저장소입니다.

이 실습은 `raw/` 폴더에 원본 Markdown 문서를 저장하고, OpenCode와 `karpathy-llm-wiki` skill을 이용해 `wiki/` 폴더에 AI가 활용하기 좋은 지식 페이지를 생성·갱신하는 과정을 다룹니다.

---
## 0. 참조

http://github.com/Astro-Han/karpathy-llm-wiki/tree/main

---

## 1. 개요

### 목적

이 PoC의 목적은 다음과 같습니다.

* 회의록, 분석 메모, dbt 기준, DataStage 분석 결과를 Markdown 기반 지식베이스로 관리한다.
* 원본 문서는 `raw/`에 보관한다.
* AI가 정리한 지식 문서는 `wiki/`에 저장한다.
* OpenCode Agent가 `karpathy-llm-wiki` skill을 사용하여 ingest, query, archive, lint 작업을 수행한다.
* 모든 변경사항은 Git diff로 검토한 뒤 커밋한다.

---

## 2. 핵심 개념

| 구분             | 설명                                           |
| -------------- | -------------------------------------------- |
| `raw/`         | 사용자가 작성하거나 외부에서 수집한 원본 Markdown 문서 저장소       |
| `wiki/`        | AI가 원본을 읽고 정리한 지식 페이지 저장소                    |
| `ingest`       | `raw/` 문서를 읽어 `wiki/`에 반영하는 과정               |
| `compile`      | 원본 내용을 AI가 활용하기 좋은 지식 구조로 재구성하는 과정           |
| `query`        | `wiki/`를 기준으로 질문에 답하는 과정                     |
| `archive page` | AI 답변이나 분석 결과 중 재사용 가치가 있는 내용을 wiki에 저장한 페이지 |
| `lint`         | `wiki/`의 링크, 색인, 출처, 중복, 모순 등을 점검하는 품질검사 과정  |

정리하면 다음과 같습니다.

```text
raw/  = 원본 저장소
wiki/ = AI가 컴파일한 지식 저장소
lint  = wiki 품질검사
```

---

## 3. 권장 디렉터리 구조

```text
gsr-llm-wiki-poc/
├── AGENTS.md
├── opencode.json
├── raw/
│   ├── migration/
│   ├── dbt/
│   └── datastage/
├── wiki/
│   ├── index.md
│   ├── log.md
│   ├── migration/
│   ├── dbt/
│   └── datastage/
└── .opencode/
    └── skills/
        └── karpathy-llm-wiki/
```

---

## 4. Conda 가상환경 생성

```bash
conda create -n gsr-llm-wiki python=3.12 -y
conda activate gsr-llm-wiki
```

Node.js, npm, npx가 필요합니다. 환경 안에 Node.js가 없다면 설치합니다.

```bash
conda install -c conda-forge nodejs -y
```

설치 확인:

```bash
node -v
npm -v
npx -v
```

OpenCode 설치 여부도 확인합니다.

```bash
opencode --version
```

---

## 5. Git 저장소 생성

```bash
mkdir gsr-llm-wiki-poc
cd gsr-llm-wiki-poc

git init
```

필요 시 Git 사용자 정보를 설정합니다.

```bash
git config user.name "<your-name>"
git config user.email "<your-email>"
```

Windows 또는 WSL 환경에서 줄바꿈 처리가 필요하면 다음 설정을 사용할 수 있습니다.

```bash
git config --global core.autocrlf true
```

원격 저장소를 연결하는 경우:

```bash
git remote add origin <your-git-repository-url>
git checkout -b gsr-llm-wiki-poc
```

---

## 6. `karpathy-llm-wiki` Skill 설치

먼저 GitHub 저장소가 접근 가능한지 확인합니다.

```bash
git ls-remote https://github.com/Astro-Han/karpathy-llm-wiki.git
```

Skill을 설치합니다.

```bash
npx add-skill Astro-Han/karpathy-llm-wiki
```

설치 결과를 확인합니다.

```bash
find . -path "*skills*" -name "SKILL.md"
find ~/.config/opencode -path "*skills*" -name "SKILL.md" 2>/dev/null
```

---

## 7. OpenCode 설정 파일 작성

프로젝트 루트에 `opencode.json`을 생성합니다.

```bash
nano opencode.json
```

내용:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": "ask",
    "bash": "ask",
    "skill": {
      "*": "deny",
      "karpathy-llm-wiki": "allow"
    }
  },
  "agent": {
    "build": {
      "permission": {
        "edit": "ask",
        "bash": {
          "*": "ask",
          "git status*": "allow",
          "git diff*": "allow",
          "find *": "allow",
          "ls *": "allow",
          "cat *": "allow"
        },
        "skill": {
          "karpathy-llm-wiki": "allow"
        }
      }
    },
    "plan": {
      "permission": {
        "edit": "deny",
        "bash": "ask",
        "skill": {
          "karpathy-llm-wiki": "allow"
        }
      }
    }
  }
}
```

---

## 8. AGENTS.md 작성

프로젝트 루트에 `AGENTS.md`를 생성합니다.

```bash
nano AGENTS.md
```

내용:

```markdown
# GSR LLM Wiki PoC

이 저장소는 GSR 데이터 전환 프로젝트 지식관리를 위한 LLM Wiki 실습 저장소이다.

## 목적

- 회의록, 분석 메모, dbt 기준, DataStage 분석 결과를 Markdown 기반 지식베이스로 정리한다.
- raw/에는 원본 자료를 보관한다.
- wiki/에는 AI가 유지하는 요약, 개념, 의사결정, 관련 문서 링크를 저장한다.
- raw/ 파일은 원본성이 중요하므로 사용자가 명시하지 않는 한 수정하지 않는다.
- wiki/ 파일은 karpathy-llm-wiki skill 규칙에 따라 생성·갱신한다.

## 운영 규칙

- 원본 문서는 raw/에 저장한다.
- 정리된 지식 문서는 wiki/에 저장한다.
- 모든 wiki 문서는 출처 raw 파일을 링크해야 한다.
- 모순되는 내용은 삭제하지 말고 "Contradictions" 또는 "주의사항" 섹션에 기록한다.
- 확정되지 않은 내용은 "가정", "검토 필요", "미확정"으로 표시한다.
- GSR 프로젝트 문서에서는 DataStage, DB2, Snowflake, dbt, Airflow, S3, migration, WBS, 검증, reconciliation 용어를 일관되게 사용한다.

## 주요 작업 요청 예시

- "문서를 LLM wiki에 ingest 해줘."
- "raw/migration 아래 문서를 읽고 wiki를 갱신해줘."
- "dbt 전환 기준에 대해 내가 알고 있는 내용을 요약해줘."
- "wiki를 lint 해줘."
- "DataStage to dbt 전환 관련 모순이나 누락을 찾아줘."
```

---

## 9. OpenCode 실행

```bash
opencode
```

OpenCode가 실행되면 Build 모드로 전환한 뒤 실습을 진행합니다.

---

## 10. 원본 문서 폴더 생성

```bash
mkdir -p raw/migration raw/dbt raw/datastage
ls -al raw/
```

---

## 11. 샘플 원본 문서 1: GSR 데이터 전환 개요

```bash
cat > raw/migration/2026-05-29-gsr-migration-overview.md <<'EOF'
---
title: GSR 데이터 전환 프로젝트 개요
source: internal memo
collected: 2026-05-29
published: 2026-05-29
---

# GSR 데이터 전환 프로젝트 개요

GSR 프로젝트는 기존 DB2와 DataStage 기반 ETL 자산을 S3, Snowflake, dbt, Airflow 기반 구조로 전환하는 리프트 앤 시프트 성격의 데이터 전환 프로젝트이다.

초기 데이터는 DB2에서 S3로 이관하고, 변동 데이터는 원천에서 DataStage를 이용해 S3로 적재한 뒤 Snowflake와 dbt 기반으로 변환한다.

주요 관심사는 다음과 같다.

- DataStage Job 분석
- DB2 테이블 및 컬럼 매핑
- dbt 모델 구조화
- Snowflake 적재 전략
- Airflow 기반 오케스트레이션
- 데이터 검증 및 reconciliation
- AI agent를 활용한 전환 생산성 향상

현재 과제는 5,100개 DB2 테이블, 4,000개 DataStage Job, 210TB 규모의 데이터를 대상으로 전환 범위와 우선순위를 정의하는 것이다.
EOF
```

---

## 12. 첫 번째 ingest 실행

OpenCode에서 다음 프롬프트를 실행합니다.

```text
raw/migration/2026-05-29-gsr-migration-overview.md 파일을 기준으로 wiki를 컴파일하라.

karpathy-llm-wiki skill을 사용해서 raw/migration/2026-05-29-gsr-migration-overview.md 파일을 ingest 해줘.

raw 파일은 수정하지 말고, wiki/ 아래에 관련 지식 페이지, index.md, log.md를 생성해줘.
```

기대 결과:

```text
wiki/
├── index.md
├── log.md
└── migration/
    └── ...
```

---

## 13. 샘플 원본 문서 2: dbt 모델링 기준

```bash
cat > raw/dbt/2026-05-29-dbt-modeling-standard.md <<'EOF'
---
title: dbt 모델링 기준 초안
source: internal memo
collected: 2026-05-29
published: 2026-05-29
---

# dbt 모델링 기준 초안

dbt 프로젝트는 staging, intermediate, marts 구조를 기본으로 한다.

staging 모델은 원천 테이블을 거의 1:1로 정리하는 계층이다. 컬럼명 표준화, 타입 보정, 기본 필터링, source freshness 확인을 담당한다.

intermediate 모델은 여러 staging 모델을 조합하여 재사용 가능한 비즈니스 중간 로직을 구성한다. 단, 기존 DataStage 로직을 무리하게 모두 intermediate로 쪼개면 검증 부하가 커질 수 있으므로 전환 초기에는 과도한 재구조화를 피한다.

marts 모델은 업무 사용자가 직접 소비하는 최종 모델이다. finance, sales, operation 등 도메인 단위로 구분한다.

DataStage Job을 dbt로 전환할 때는 Job 단위 변환보다 데이터 흐름, 조인, 필터, 집계, target table 기준으로 모델 경계를 다시 정의해야 한다.
EOF
```

---

## 14. 두 번째 ingest 실행

OpenCode에서 다음 프롬프트를 실행합니다.

```text
karpathy-llm-wiki skill을 사용해서 raw/dbt/2026-05-29-dbt-modeling-standard.md 파일을 ingest 해줘.

기존 migration 관련 wiki 문서와 관련성이 있으면 cross-link도 추가해줘.
```

---

## 15. 생성 결과 확인

터미널에서 변경사항을 확인합니다.

```bash
git status
git diff wiki/index.md
git diff wiki/log.md
find wiki -type f
```

확인할 항목:

* `wiki/index.md`가 생성 또는 갱신되었는가?
* `wiki/log.md`에 작업 이력이 남았는가?
* `wiki/migration/`, `wiki/dbt/` 하위에 지식 페이지가 생성되었는가?
* 관련 문서 간 cross-link가 추가되었는가?
* `raw/` 원본 파일이 수정되지 않았는가?

---

## 16. Query 실습

OpenCode에서 다음 질문을 실행합니다.

```text
내 wiki 기준으로 GSR 데이터 전환 프로젝트에서 dbt 전환 시 주의해야 할 점을 요약해줘.

답변에는 관련 wiki 문서 링크를 포함해줘.

파일은 수정하지 마.
```

이 단계에서는 파일을 수정하지 않고, `wiki/` 문서를 기반으로 답변이 생성되는지 확인합니다.

---

## 17. Archive Page 저장 실습

앞 단계의 답변이 재사용 가치가 있다면 archive page로 저장합니다.

```text
방금 답변을 wiki에 archive page로 저장해줘.
```

`archive page`는 AI 답변이나 분석 결과 중 다시 참조할 가치가 있는 내용을 wiki 내부에 보존하는 문서입니다.

예를 들어 다음과 같은 내용은 archive로 남길 수 있습니다.

* DataStage Job을 dbt 모델로 전환할 때의 핵심 원칙
* GSR 데이터 전환 프로젝트의 dbt 전환 리스크
* reconciliation 검증 기준
* AI agent 기반 전환 파이프라인 검토 결과
* WBS 일정 현실성 검토 결과

---

## 18. Lint 실행

OpenCode에서 다음 프롬프트를 실행합니다.

```text
karpathy-llm-wiki skill을 사용해서 wiki를 lint 해줘.
```

보다 구체적으로 실행하려면 다음과 같이 요청합니다.

```text
karpathy-llm-wiki skill을 사용해서 wiki를 lint 해줘.

깨진 링크, index 누락, raw reference 오류는 자동 수정해줘.

모순, 오래된 주장, 고아 문서, 누락 개념은 보고만 해줘.
```

Lint에서 점검하는 대표 항목은 다음과 같습니다.

| 항목               | 설명                          |
| ---------------- | --------------------------- |
| 깨진 링크            | 존재하지 않는 wiki 문서를 참조하는 링크    |
| index 누락         | `wiki/index.md`에 등록되지 않은 문서 |
| raw reference 오류 | 원본 문서 출처 누락 또는 오류           |
| 중복 개념            | 같은 주제가 여러 문서에 흩어진 경우        |
| 모순 후보            | 문서 간 내용이 충돌하는 경우            |
| 고아 문서            | 다른 문서와 연결되지 않은 문서           |
| 누락된 cross-link   | 관련 문서 간 연결이 부족한 경우          |

---

## 19. Git 변경사항 검토

AI가 생성하거나 수정한 파일은 반드시 Git diff로 검토합니다.

```bash
git status
git diff
```

검토 기준:

* `raw/` 원본 파일이 의도치 않게 수정되지 않았는가?
* `wiki/` 문서의 요약이 원본 내용과 일치하는가?
* 출처 링크가 남아 있는가?
* 확정되지 않은 내용이 확정 표현으로 바뀌지 않았는가?
* 모순이나 검토 필요 항목이 적절히 표시되었는가?

---

## 20. Git 커밋

검토 후 문제가 없으면 커밋합니다.

```bash
git add AGENTS.md opencode.json raw wiki .opencode
git commit -m "Initialize GSR LLM wiki PoC"
```

---

## 21. 반복 작업 흐름

실제 운영 시에는 아래 흐름을 반복합니다.

```text
1. raw/에 원본 문서 추가
2. OpenCode에서 ingest 요청
3. wiki/index.md 확인
4. 관련 wiki article 확인
5. query로 내용 질의
6. 필요한 답변은 archive page로 저장
7. lint 실행
8. git diff 검토
9. commit
```

---

## 22. 자주 사용하는 OpenCode 프롬프트

### 22.1 단일 문서 ingest

```text
karpathy-llm-wiki skill을 사용해 raw/migration/2026-05-29-gsr-migration-overview.md 파일을 ingest 해줘.

raw 파일은 수정하지 말고, wiki/ 아래에 지식 페이지를 생성해줘.

wiki/index.md와 wiki/log.md도 갱신해줘.
```

### 22.2 특정 폴더 전체 ingest

```text
karpathy-llm-wiki skill을 사용해서 raw/dbt/ 아래의 Markdown 문서를 모두 ingest 해줘.

이미 존재하는 wiki article과 같은 주제면 병합하고, 새 개념이면 새 article을 만들어줘.

관련 migration, validation, datastage 문서가 있으면 cross-link를 추가해줘.
```

### 22.3 wiki 기반 질의

```text
내 wiki 기준으로 DataStage Job을 dbt 모델로 전환할 때의 핵심 원칙을 정리해줘.

관련 wiki 문서 링크를 포함하고, 확정된 내용과 검토 필요 내용을 구분해줘.

파일은 수정하지 마.
```

### 22.4 검증 관점 리스크 질의

```text
내 wiki 기준으로 GSR 데이터 전환 프로젝트에서 데이터 검증과 reconciliation 관점의 리스크를 정리해줘.

누락된 개념 페이지가 있으면 후보로 제안만 하고 파일은 수정하지 마.
```

### 22.5 wiki lint

```text
karpathy-llm-wiki skill을 사용해서 wiki를 lint 해줘.

깨진 링크, index 누락, raw reference 오류는 자동 수정해줘.

모순, 오래된 주장, 고아 문서, 누락 개념은 보고만 해줘.
```

### 22.6 archive page 저장

```text
방금 답변을 wiki에 archive page로 저장해줘.

archive page는 가장 관련 있는 topic 아래에 생성하고, wiki/index.md와 wiki/log.md를 갱신해줘.
```

---

## 23. 운영 원칙

### 23.1 raw는 원본이다

`raw/`는 원본 문서 저장소입니다.

AI가 임의로 수정하지 않도록 해야 합니다.

```text
raw/ 수정 원칙:
- 사용자가 직접 작성하거나 외부 문서를 Markdown으로 변환해 저장한다.
- AI는 기본적으로 raw 파일을 수정하지 않는다.
- 오탈자 수정이나 frontmatter 보정도 사용자가 명시적으로 요청한 경우에만 수행한다.
```

### 23.2 wiki는 AI 전용 지식 레이어다

`wiki/`는 AI가 원본을 읽고 정리한 지식 페이지 저장소입니다.

```text
wiki/ 관리 원칙:
- 원본 출처를 남긴다.
- 관련 문서 간 링크를 추가한다.
- 확정/미확정 내용을 구분한다.
- 모순은 삭제하지 말고 기록한다.
- 오래된 내용은 갱신 후보로 표시한다.
```

### 23.3 lint는 품질검사다

`lint`는 지식 저장 과정이 아니라, 이미 생성된 `wiki/`의 품질을 점검하는 과정입니다.

```text
ingest  = raw 문서를 wiki에 반영
compile = raw 내용을 지식 페이지로 재구성
query   = wiki 기준으로 질문에 답변
archive = 유용한 AI 답변을 wiki에 보존
lint    = wiki 품질 점검
```

### 23.4 Git diff 검토는 필수다

AI가 생성한 문서는 반드시 사람이 검토해야 합니다.

```bash
git status
git diff
```

검토 후 문제가 없을 때만 commit 합니다.

---

## 24. PoC 성공 기준

이 실습의 성공 기준은 다음과 같습니다.

```text
- raw/ 원본 문서가 보존된다.
- wiki/에 주제별 지식 문서가 생성된다.
- wiki/index.md가 전체 목차 역할을 한다.
- wiki/log.md에 작업 이력이 남는다.
- 관련 문서 간 cross-link가 생성된다.
- query 시 wiki 문서를 근거로 답변한다.
- archive page로 재사용 가능한 분석 결과를 보존할 수 있다.
- lint로 링크, 색인, 출처, 모순 후보를 점검할 수 있다.
- Git diff로 모든 AI 변경사항을 검토할 수 있다.
```

---

## 25. 향후 확장 방향

PoC 이후에는 다음 방향으로 확장할 수 있습니다.

```text
- raw/ 폴더 변경 감지 자동화
- 문서 frontmatter 표준화
- wiki lint 자동 실행
- Git pre-commit hook 연계
- Obsidian 또는 VS Code 기반 문서 탐색
- Mermaid 또는 Excalidraw 기반 시각화
- dbt/DataStage 전환 지식 템플릿 추가
- reconciliation 기준 문서 자동 생성
- 프로젝트 WBS, 이슈, 의사결정 로그 연계
```

---

## 26. 요약

이 저장소는 GSR 데이터 전환 프로젝트의 문서를 다음 구조로 관리합니다.

```text
raw/
  → 사람이 작성하거나 외부에서 수집한 원본 Markdown 문서

wiki/
  → AI가 raw 문서를 읽고 정리한 지식 페이지

OpenCode + karpathy-llm-wiki
  → ingest, query, archive, lint 수행

Git
  → 모든 변경사항 검토 및 이력 관리
```

핵심 운영 방식은 다음과 같습니다.

```text
원본은 raw에 저장한다.
AI는 wiki에 지식 페이지를 만든다.
좋은 답변은 archive page로 남긴다.
wiki 품질은 lint로 점검한다.
모든 변경사항은 git diff로 검토한다.
```
