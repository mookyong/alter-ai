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
