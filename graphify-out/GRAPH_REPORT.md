# Graph Report - jaffle_graphify  (2026-05-26)

## Corpus Check
- 10 files · ~817 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 66 nodes · 62 edges · 22 communities (6 shown, 16 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `4c2dd052`
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
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]

## God Nodes (most connected - your core abstractions)
1. `Graphify + dbt Demo Setup` - 10 edges
2. `9. 코드 변경 후 Graphify 업데이트` - 10 edges
3. `workbench.editorAssociations` - 6 edges
4. `Column Test Suite` - 4 edges
5. `5. OpenCode에서 실행` - 3 edges
6. `dbt Project Configuration` - 3 edges
7. `1. Conda 환경 생성` - 2 edges
8. `2. 샘플 dbt 프로젝트 생성` - 2 edges
9. `3. dbt 동작 확인` - 2 edges
10. `4. Graphify 설치 및 검증` - 2 edges

## Surprising Connections (you probably didn't know these)
- `dbt Project Configuration` --references--> `DuckDB Dev Profile`  [EXTRACTED]
  dbt_project.yml → profiles.yml

## Hyperedges (group relationships)
- **Staging Layer Flow** — dbt_staging_layer, models_staging_stg_customers_sql, models_staging_stg_orders_sql, models_staging_stg_payments_sql, raw_customers_source, raw_orders_source, raw_payments_source [INFERRED 0.87]
- **Marts Layer Flow** — dbt_marts_layer, models_marts_fct_orders_sql, models_marts_dim_customers_sql [INFERRED 0.91]
- **Quality Check Coverage** — column_test_suite, models_staging_stg_customers_sql, models_staging_stg_orders_sql, models_marts_fct_orders_sql, models_marts_dim_customers_sql [INFERRED 0.84]

## Communities (22 total, 16 thin omitted)

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
Cohesion: 0.40
Nodes (4): 3. dbt 동작 확인, 6. Graphify 결과 기준 lineage, code:bash (dbt debug), Graphify + dbt Demo Setup

### Community 7 - "Community 7"
Cohesion: 0.67
Nodes (3): 5. OpenCode에서 실행, code:bash (opencode .), code:bash (ls -lah graphify-out)

### Community 8 - "Community 8"
Cohesion: 0.67
Nodes (3): 9. 코드 변경 후 Graphify 업데이트, code:bash (graphify hook install), git commit 기준 자동 업데이트

## Knowledge Gaps
- **33 isolated node(s):** `code:bash (conda create -n graphify-dbt python=3.12 -y)`, `code:bash (mkdir -p test/graphify-dbt-demo)`, `code:bash (dbt debug)`, `code:bash (pwd)`, `code:bash (opencode .)` (+28 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `9. 코드 변경 후 Graphify 업데이트` connect `Community 8` to `Community 6`, `Community 14`, `Community 15`, `Community 16`, `Community 17`, `Community 18`, `Community 19`, `Community 20`, `Community 21`?**
  _High betweenness centrality (0.225) - this node is a cross-community bridge._
- **Why does `Graphify + dbt Demo Setup` connect `Community 6` to `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 13`?**
  _High betweenness centrality (0.216) - this node is a cross-community bridge._
- **Why does `5. OpenCode에서 실행` connect `Community 7` to `Community 6`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **What connects `code:bash (conda create -n graphify-dbt python=3.12 -y)`, `code:bash (mkdir -p test/graphify-dbt-demo)`, `code:bash (dbt debug)` to the rest of the system?**
  _33 weakly-connected nodes found - possible documentation gaps or missing edges._