# Graph Report - .  (2026-05-26)

## Corpus Check
- Corpus is ~604 words - fits in a single context window. You may not need a graph.

## Summary
- 30 nodes · 33 edges · 6 communities (3 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Demo Docs|Demo Docs]]
- [[_COMMUNITY_Editor Associations|Editor Associations]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Graphify Plugin Logic|Graphify Plugin Logic]]
- [[_COMMUNITY_OpenCode Dependencies|OpenCode Dependencies]]
- [[_COMMUNITY_OpenCode Plugin Config|OpenCode Plugin Config]]

## God Nodes (most connected - your core abstractions)
1. `Graphify + dbt Demo Setup` - 7 edges
2. `workbench.editorAssociations` - 6 edges
3. `dbt Project Configuration` - 4 edges
4. `Column Test Suite` - 4 edges
5. `OpenCode Plugin Config` - 2 edges
6. `*.copilotmd` - 1 edges
7. `*.parquet` - 1 edges
8. `*.csv` - 1 edges
9. `*.tsv` - 1 edges
10. `*.xlsx` - 1 edges

## Surprising Connections (you probably didn't know these)
- `OpenCode Plugin Config` --references--> `Graphify + dbt Demo Setup`  [EXTRACTED]
  .opencode/opencode.json → README.md
- `dbt Project Configuration` --references--> `Graphify + dbt Demo Setup`  [EXTRACTED]
  dbt_project.yml → README.md
- `dbt Project Configuration` --references--> `DuckDB Dev Profile`  [EXTRACTED]
  dbt_project.yml → profiles.yml

## Hyperedges (group relationships)
- **Staging Layer Flow** — dbt_staging_layer, models_staging_stg_customers_sql, models_staging_stg_orders_sql, models_staging_stg_payments_sql, raw_customers_source, raw_orders_source, raw_payments_source [INFERRED 0.87]
- **Marts Layer Flow** — dbt_marts_layer, models_marts_fct_orders_sql, models_marts_dim_customers_sql [INFERRED 0.91]
- **Quality Check Coverage** — column_test_suite, models_staging_stg_customers_sql, models_staging_stg_orders_sql, models_marts_fct_orders_sql, models_marts_dim_customers_sql [INFERRED 0.84]

## Communities (6 total, 3 thin omitted)

### Community 0 - "Demo Docs"
Cohesion: 0.36
Nodes (5): Column Test Suite, Raw Customers Source, Raw Orders Source, Raw Payments Source, Graphify + dbt Demo Setup

### Community 1 - "Editor Associations"
Cohesion: 0.29
Nodes (6): workbench.editorAssociations, *.copilotmd, *.csv, *.parquet, *.tsv, *.xlsx

### Community 2 - "Community 2"
Cohesion: 0.50
Nodes (4): Marts Layer, dbt Project Configuration, Staging Layer, DuckDB Dev Profile

## Knowledge Gaps
- **14 isolated node(s):** `*.copilotmd`, `*.parquet`, `*.csv`, `*.tsv`, `*.xlsx` (+9 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Graphify + dbt Demo Setup` connect `Demo Docs` to `Community 2`, `Graphify Plugin Logic`?**
  _High betweenness centrality (0.210) - this node is a cross-community bridge._
- **Why does `dbt Project Configuration` connect `Community 2` to `Demo Docs`?**
  _High betweenness centrality (0.103) - this node is a cross-community bridge._
- **Why does `OpenCode Plugin Config` connect `Graphify Plugin Logic` to `Demo Docs`?**
  _High betweenness centrality (0.069) - this node is a cross-community bridge._
- **What connects `*.copilotmd`, `*.parquet`, `*.csv` to the rest of the system?**
  _14 weakly-connected nodes found - possible documentation gaps or missing edges._