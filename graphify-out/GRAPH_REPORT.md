# Graph Report - jaffle_graphify  (2026-05-27)

## Corpus Check
- 13 files · ~1,612 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 115 nodes · 124 edges · 14 communities (11 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `093054ab`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]

## God Nodes (most connected - your core abstractions)
1. `Graphify + dbt Demo Setup` - 11 edges
2. `9. 코드 변경 후 Graphify 업데이트` - 10 edges
3. `4.1 code-review-graph 설치 및 활용` - 8 edges
4. `4.1.4 OpenCode 안에서 자주 쓰는 요청` - 8 edges
5. `code-review-graph` - 6 edges
6. `4.1.6 자주 쓰는 요청 템플릿` - 6 edges
7. `workbench.editorAssociations` - 6 edges
8. `5. OpenCode에서 실행` - 5 edges
9. `code-review-graph` - 5 edges
10. `MCP Tools: code-review-graph` - 4 edges

## Surprising Connections (you probably didn't know these)
- `dbt Project Configuration` --references--> `DuckDB Dev Profile`  [EXTRACTED]
  dbt_project.yml → profiles.yml

## Hyperedges (group relationships)
- **Staging Layer Flow** — dbt_staging_layer, models_staging_stg_customers_sql, models_staging_stg_orders_sql, models_staging_stg_payments_sql, raw_customers_source, raw_orders_source, raw_payments_source [INFERRED 0.87]
- **Marts Layer Flow** — dbt_marts_layer, models_marts_fct_orders_sql, models_marts_dim_customers_sql [INFERRED 0.91]
- **Quality Check Coverage** — column_test_suite, models_staging_stg_customers_sql, models_staging_stg_orders_sql, models_marts_fct_orders_sql, models_marts_dim_customers_sql [INFERRED 0.84]

## Communities (14 total, 3 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.31
Nodes (4): Column Test Suite, Raw Customers Source, Raw Orders Source, Raw Payments Source

### Community 1 - "Community 1"
Cohesion: 0.29
Nodes (6): workbench.editorAssociations, *.copilotmd, *.csv, *.parquet, *.tsv, *.xlsx

### Community 2 - "Community 2"
Cohesion: 0.50
Nodes (4): Marts Layer, dbt Project Configuration, Staging Layer, DuckDB Dev Profile

### Community 6 - "Community 6"
Cohesion: 0.18
Nodes (10): 1. Conda 환경 생성, 2. 샘플 dbt 프로젝트 생성, 3. dbt 동작 확인, 4. Graphify 설치 및 검증, 6. Graphify 결과 기준 lineage, code:bash (conda create -n graphify-dbt python=3.12 -y), code:bash (mkdir -p test/graphify-dbt-demo), code:bash (dbt debug) (+2 more)

### Community 7 - "Community 7"
Cohesion: 0.12
Nodes (17): 4.1.1 code-review-graph 전용 환경 생성, 4.1.2 OpenCode 등록, 4.1.7 dbt 샘플 프로젝트 예시, 4.1 code-review-graph 설치 및 활용, 5. OpenCode에서 실행, 7. Graphify query 예시, 8. 재실행, code:bash (conda activate graphify-dbt) (+9 more)

### Community 8 - "Community 8"
Cohesion: 0.11
Nodes (23): 4.1.4 OpenCode 안에서 자주 쓰는 요청, 9. 코드 변경 후 Graphify 업데이트, code:text (code-review-graph MCP를 사용할 수 있는지 확인하고, 현재 프로젝트 그래프 상태를 알려줘.), code:text (code-review-graph를 사용해서 이 프로젝트의 변경 영향 분석을 해줘.), code:text (code-review-graph를 사용해서 현재 프로젝트의 그래프 상태와 주요 구조를 요약해줘.), code:text (code-review-graph를 사용해서 현재 git 변경사항의 영향 범위, 위험도, 관련 테스트 공백을 ), code:text (code-review-graph를 사용해서 이번 dbt 모델 변경의 영향 범위를 분석해줘.), code:text (code-review-graph를 사용해서 stg_orders.sql 또는 관련 노드의 호출/참조/의존 관계) (+15 more)

### Community 9 - "Community 9"
Cohesion: 0.16
Nodes (13): args, cwd, enabled, env, timeout, instructions, mcp, code-review-graph (+5 more)

### Community 10 - "Community 10"
Cohesion: 0.33
Nodes (6): 4.1.6 자주 쓰는 요청 템플릿, code:text (code-review-graph를 사용해서 현재 변경사항의 blast radius를 분석해줘.), code:text (code-review-graph를 사용해서 이번 변경에 필요한 테스트 범위를 추천해줘.), code:text (code-review-graph의 minimal context를 먼저 확인하고, 필요한 파일만 읽어서 리뷰해), code:text (code-review-graph로 영향받는 함수/파일/테스트를 찾고, 수정 순서를 제안해줘.), code:text (Graphify로 전체 dbt lineage를 확인하고, code-review-graph로 변경 영향 범위를)

### Community 11 - "Community 11"
Cohesion: 0.40
Nodes (4): Key Tools, MCP Tools: code-review-graph, When to use graph tools FIRST, Workflow

### Community 20 - "Community 20"
Cohesion: 0.33
Nodes (6): 4.1.5 실전 루틴, code:bash (conda activate code-review-graph), code:bash (conda activate graphify-dbt), code:text (code-review-graph로 이번 변경의 영향 범위를 먼저 분석하고,), code:bash (dbt build), dbt 샘플 프로젝트 일상 루틴

### Community 21 - "Community 21"
Cohesion: 0.50
Nodes (4): 4.1.3 그래프 생성 후 확인 순서, code:bash (graphify update .), code:bash (conda activate code-review-graph), 수동 업데이트

## Knowledge Gaps
- **52 isolated node(s):** `args`, `cwd`, `env`, `When to use graph tools FIRST`, `Key Tools` (+47 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Graphify + dbt Demo Setup` connect `Community 6` to `Community 8`, `Community 7`?**
  _High betweenness centrality (0.179) - this node is a cross-community bridge._
- **Why does `4.1 code-review-graph 설치 및 활용` connect `Community 7` to `Community 6`, `Community 8`, `Community 10`, `Community 20`, `Community 21`?**
  _High betweenness centrality (0.147) - this node is a cross-community bridge._
- **Why does `9. 코드 변경 후 Graphify 업데이트` connect `Community 8` to `Community 20`, `Community 21`, `Community 6`?**
  _High betweenness centrality (0.137) - this node is a cross-community bridge._
- **What connects `args`, `cwd`, `env` to the rest of the system?**
  _52 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 7` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._
- **Should `Community 8` be split into smaller, more focused modules?**
  _Cohesion score 0.11067193675889328 - nodes in this community are weakly interconnected._