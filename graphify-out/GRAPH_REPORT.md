# Graph Report - .  (2026-05-26)

## Corpus Check
- Corpus is ~375 words - fits in a single context window. You may not need a graph.

## Summary
- 29 nodes · 26 edges · 7 communities (3 shown, 4 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Editor Associations|Editor Associations]]
- [[_COMMUNITY_dbt Customer Models|dbt Customer Models]]
- [[_COMMUNITY_dbt Project Setup|dbt Project Setup]]
- [[_COMMUNITY_OpenCode Plugin Config|OpenCode Plugin Config]]
- [[_COMMUNITY_Graphify Plugin Logic|Graphify Plugin Logic]]
- [[_COMMUNITY_OpenCode Dependencies|OpenCode Dependencies]]
- [[_COMMUNITY_Payments Staging|Payments Staging]]

## God Nodes (most connected - your core abstractions)
1. `workbench.editorAssociations` - 6 edges
2. `Column Test Suite` - 4 edges
3. `dbt Project Configuration` - 3 edges
4. `*.copilotmd` - 1 edges
5. `*.parquet` - 1 edges
6. `*.csv` - 1 edges
7. `*.tsv` - 1 edges
8. `*.xlsx` - 1 edges
9. `@opencode-ai/plugin` - 1 edges
10. `$schema` - 1 edges

## Surprising Connections (you probably didn't know these)
- `dbt Project Configuration` --references--> `DuckDB Dev Profile`  [EXTRACTED]
  dbt_project.yml → profiles.yml

## Hyperedges (group relationships)
- **Staging Layer Flow** — dbt_staging_layer, models_staging_stg_customers_sql, models_staging_stg_orders_sql, models_staging_stg_payments_sql, raw_customers_source, raw_orders_source, raw_payments_source [INFERRED 0.87]
- **Marts Layer Flow** — dbt_marts_layer, models_marts_fct_orders_sql, models_marts_dim_customers_sql [INFERRED 0.91]
- **Quality Check Coverage** — column_test_suite, models_staging_stg_customers_sql, models_staging_stg_orders_sql, models_marts_fct_orders_sql, models_marts_dim_customers_sql [INFERRED 0.84]

## Communities (7 total, 4 thin omitted)

### Community 0 - "Editor Associations"
Cohesion: 0.29
Nodes (6): workbench.editorAssociations, *.copilotmd, *.csv, *.parquet, *.tsv, *.xlsx

### Community 1 - "dbt Customer Models"
Cohesion: 0.43
Nodes (3): Column Test Suite, Raw Customers Source, Raw Orders Source

### Community 2 - "dbt Project Setup"
Cohesion: 0.50
Nodes (4): Marts Layer, dbt Project Configuration, Staging Layer, DuckDB Dev Profile

## Knowledge Gaps
- **15 isolated node(s):** `*.copilotmd`, `*.parquet`, `*.csv`, `*.tsv`, `*.xlsx` (+10 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `*.copilotmd`, `*.parquet`, `*.csv` to the rest of the system?**
  _15 weakly-connected nodes found - possible documentation gaps or missing edges._