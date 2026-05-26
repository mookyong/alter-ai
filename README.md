# Graphify + dbt Demo Setup

## 1. Conda 환경 생성

```bash
conda create -n graphify-dbt python=3.12 -y
conda activate graphify-dbt
pip install dbt-duckdb
pip install "graphifyy[sql,leiden]"
```

## 2. 샘플 dbt 프로젝트 생성

```bash
mkdir -p test/graphify-dbt-demo
cd test/graphify-dbt-demo

mkdir -p jaffle_graphify/{models/staging,models/marts,seeds,macros}
cd jaffle_graphify

git init
git config user.name mookyongkim
git config user.email mookyongkim@gmail.com
git remote add origin https://github.com/mookyong/alter-ai.git
git checkout -b graphify-dbt-demo

code .
```

## 3. dbt 동작 확인

```bash
dbt debug
dbt seed
dbt build
ls -lah *.duckdb
```

## 4. Graphify 설치 및 검증

```bash
pwd
graphify --version
graphify --help

graphify install --platform opencode
```

설치 결과:

- `skill installed -> /home/dharma6872/.config/opencode/skills/graphify/SKILL.md`
- `.opencode/plugins/graphify.js -> tool.execute.before hook written`
- `.opencode/opencode.json -> plugin registered`

## 4.1 code-review-graph 설치 및 활용

이 프로젝트에서는 환경을 분리해서 쓰는 구성이 가장 깔끔합니다.

- `graphify-dbt` 환경: `dbt`, `graphify`, `graspologic`, `leiden` 실행용
- `code-review-graph` 환경: MCP server 실행용, OpenCode 연결용

### 4.1.1 code-review-graph 전용 환경 생성

```bash
conda create -n code-review-graph python=3.12 -y
conda activate code-review-graph

python -m pip install -U pip
python -m pip install -U code-review-graph

code-review-graph --version
which code-review-graph
```

### 4.1.2 OpenCode 등록

```bash
code-review-graph install --platform opencode
```

설치 후에는 `graphify-dbt` 환경으로 돌아가서 OpenCode를 실행합니다.

```bash
conda activate graphify-dbt
cd ~/workspace/test/graphify-dbt-demo/jaffle_graphify

opencode .

ls -la .opencode.json opencode.json 2>/dev/null || true
cp .opencode.json opencode.json
opencode mcp list
```

필요하면 `opencode.json`을 직접 백업/수정할 수 있습니다.

```bash
cp opencode.json opencode.json.bak.$(date +%Y%m%d-%H%M%S)

cat > opencode.json <<'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "code-review-graph": {
      "type": "local",
      "command": [
        "/home/dharma6872/miniconda3/envs/code-review-graph/bin/code-review-graph",
        "serve"
      ],
      "enabled": true,
      "timeout": 30000
    }
  },
  "instructions": [
    "AGENTS.md"
  ]
}
EOF
```

### 4.1.3 그래프 생성 후 확인 순서

```bash
conda activate code-review-graph
cd ~/workspace/test/graphify-dbt-demo/jaffle_graphify

code-review-graph build
code-review-graph status

conda activate graphify-dbt
cd ~/workspace/test/graphify-dbt-demo/jaffle_graphify

opencode .
```

### 4.1.4 OpenCode 안에서 자주 쓰는 요청

OpenCode 대화창에서는 이런 식으로 물으면 됩니다.

```text
code-review-graph MCP를 사용할 수 있는지 확인하고, 현재 프로젝트 그래프 상태를 알려줘.
```

```text
code-review-graph를 사용해서 이 프로젝트의 변경 영향 분석을 해줘.
```

```text
code-review-graph를 사용해서 현재 프로젝트의 그래프 상태와 주요 구조를 요약해줘.
```

```text
code-review-graph를 사용해서 현재 git 변경사항의 영향 범위, 위험도, 관련 테스트 공백을 분석해줘.
```

```text
code-review-graph를 사용해서 이번 dbt 모델 변경의 영향 범위를 분석해줘.
```

```text
code-review-graph를 사용해서 stg_orders.sql 또는 관련 노드의 호출/참조/의존 관계를 확인하고,
이 파일을 수정할 때 같이 확인해야 할 파일을 알려줘.
```

```text
code-review-graph의 review context를 먼저 가져온 뒤,
현재 변경사항을 코드 리뷰해줘.
버그 가능성, 깨질 수 있는 의존성, 테스트 누락, 과도한 결합을 중심으로 봐줘.
```

### 4.1.5 실전 루틴

평소 개발 시작:

```bash
conda activate code-review-graph
cd ~/workspace/test/graphify-dbt-demo/jaffle_graphify
code-review-graph status

conda activate graphify-dbt
opencode .
```

코드/dbt 수정 후:

```bash
conda activate graphify-dbt
dbt build

conda activate code-review-graph
code-review-graph update --brief

conda activate graphify-dbt
graphify update .
```

OpenCode에 요청:

```text
code-review-graph로 이번 변경의 영향 범위를 먼저 분석하고,
그 다음 Graphify 관점에서 dbt lineage와 전체 데이터 흐름이 어떻게 바뀌었는지 설명해줘.
```

### 4.1.6 자주 쓰는 요청 템플릿

가장 많이 쓰게 될 템플릿입니다.

```text
code-review-graph를 사용해서 현재 변경사항의 blast radius를 분석해줘.
```

```text
code-review-graph를 사용해서 이번 변경에 필요한 테스트 범위를 추천해줘.
```

```text
code-review-graph의 minimal context를 먼저 확인하고, 필요한 파일만 읽어서 리뷰해줘.
```

```text
code-review-graph로 영향받는 함수/파일/테스트를 찾고, 수정 순서를 제안해줘.
```

```text
Graphify로 전체 dbt lineage를 확인하고, code-review-graph로 변경 영향 범위를 교차검증해줘.
```

### 4.1.7 dbt 샘플 프로젝트 예시

예를 들어 `models/staging/stg_orders.sql`를 수정했다면:

```bash
conda activate graphify-dbt
dbt build --select stg_orders+

conda activate code-review-graph
code-review-graph update --brief
```

OpenCode에서는 이렇게 요청하면 됩니다.

```text
code-review-graph를 사용해서 stg_orders.sql 변경이 fct_orders, dim_customers, schema tests에 미치는 영향을 분석해줘.
그 다음 Graphify 결과 기준으로 raw_orders → stg_orders → fct_orders → dim_customers lineage를 설명해줘.
```

핵심 결론:

- 작업 전/중: `code-review-graph status`, `code-review-graph detect-changes --brief`
- 작업 후: `code-review-graph update --brief`, `dbt build`, `graphify update .`
- OpenCode 안: `code-review-graph를 사용해서 변경 영향 분석해줘`, `Graphify 기준으로 전체 구조와 dbt lineage를 설명해줘`

즉, `code-review-graph`는 리뷰용 레이더, `Graphify`는 프로젝트 지도처럼 쓰면 가장 효과적입니다.

## 5. OpenCode에서 실행

```bash
opencode .
/graphify .
```

검증:

```bash
ls -lah graphify-out
test -f graphify-out/graph.html && echo "graph.html OK"
test -f graphify-out/GRAPH_REPORT.md && echo "GRAPH_REPORT.md OK"
test -f graphify-out/graph.json && echo "graph.json OK"
```

## 6. Graphify 결과 기준 lineage

- `raw_customers -> stg_customers -> dim_customers`
- `raw_orders -> stg_orders -> fct_orders -> dim_customers`
- `raw_payments -> stg_payments -> fct_orders -> dim_customers`

`dim_customers`는 직접적으로 `stg_customers`와 `fct_orders`에 의존하며, 간접적으로는 `raw_customers`, `raw_orders`, `raw_payments`까지 upstream lineage가 이어집니다.

## 7. Graphify query 예시

```bash
graphify query "dim_customers 모델은 어떤 seed와 staging 모델에 의존하나요?"
```

## 8. 재실행

```bash
rm -rf graphify-out target dbt_packages logs jaffle_graphify.duckdb
dbt seed
dbt build
graphify .
```

## 9. 코드 변경 후 Graphify 업데이트

### 수동 업데이트

```bash
graphify update .
/graphify . --update
```

### dbt 프로젝트 변경 후 추천 순서

```bash
cd ~/work/graphify-dbt-demo/jaffle_graphify
conda activate graphify-dbt
export DBT_PROFILES_DIR=$PWD

dbt compile
dbt build

graphify update .

ls -lah graphify-out/

graphify query "dim_customers 모델의 upstream dependency를 설명해줘"
graphify query "fct_orders와 stg_payments는 어떻게 연결되나요?"
```

### 개발 중 자동 동기화

```bash
graphify watch .
/graphify . --watch
```

### git commit 기준 자동 업데이트

```bash
graphify hook install
graphify hook status

git add .
git commit -m "update dbt models"
```

### 코드 변경 vs 문서 변경 구분

```bash
graphify update .
/graphify . --update

export ANTHROPIC_API_KEY="..."
graphify extract ./docs --backend claude
graphify update .
```

### 삭제 또는 대규모 리팩터링 후

```bash
cp -r graphify-out graphify-out.backup.$(date +%Y%m%d-%H%M%S)

graphify update . --force

GRAPHIFY_FORCE=1 graphify update .
```

### 완전 재생성이 필요한 경우

```bash
rm -rf graphify-out
graphify .

/graphify .

graphify extract . --force
graphify update . --force
```

### graphify-out Git 관리 추천

```bash
graphify-out/manifest.json
graphify-out/cost.json
# graphify-out/cache/
```

### dbt 샘플 프로젝트 일상 루틴

```bash
dbt build
graphify update .
graphify query "이번 변경이 dim_customers lineage에 어떤 영향을 주나요?"

graphify hook install

dbt build
cp -r graphify-out graphify-out.backup.$(date +%Y%m%d-%H%M%S)
graphify update . --force

rm -rf graphify-out
graphify .
```
