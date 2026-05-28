# GRAPH_REPORT

## Corpus summary
This repo is a documentation-only knowledge base for a DataStage → dbt/Airflow migration. The main structure is planning-led: scope, deliverables, AI-assisted execution, WBS, staffing, and requirements.

## God Nodes
- `README.md` — folder taxonomy and lifecycle rules.
- `00_overview/README.md` — project goal, AS-IS, and major deliverables.
- `01_planning/산출물 정의표.md` — official vs working vs reference deliverable taxonomy.
- `01_planning/공식 산출물-작업용 산출물 매핑표.md` — bridges drafts to formal deliverables.
- `01_planning/AI 에이전트 적용 전략.md` — defines AI as an execution + verification actor.
- `01_planning/WBS DBT 전환 일정.md` — master schedule and phase ownership.
- `01_planning/프로젝트 킥오프 R&R 및 액션아이템.md` — ownership and initial actions.
- `02_requirements/README.md` — five requirements areas.

## Communities
### 1) Scope + requirements
- `00_overview/README.md`
- `02_requirements/README.md`
- `02_requirements/01_as_is_analysis.md`
- `02_requirements/02_elt_implementation.md`
- `02_requirements/03_bi_upgrade.md`
- `02_requirements/04_bi_portal.md`
- `02_requirements/05_project_management.md`

### 2) Deliverable governance
- `01_planning/산출물 정의표.md`
- `01_planning/공식 산출물-작업용 산출물 매핑표.md`
- `01_planning/프로젝트 킥오프 R&R 및 액션아이템.md`

### 3) AI-assisted delivery model
- `01_planning/AI 에이전트 적용 전략.md`
- `01_planning/AI 에이전트 적용 전략 및 인력 배분 정리.md`
- `01_planning/WBS DBT 전환 일정.md`

### 4) Schedule + staffing + accountability
- `01_planning/WBS DBT 전환 일정.md`
- `01_planning/AI 에이전트 적용 전략 및 인력 배분 정리.md`
- `01_planning/프로젝트 킥오프 R&R 및 액션아이템.md`

## Surprising cross-links
- AI strategy ↔ WBS: schedule is framed as an AI-based transform/verify loop.
- Deliverable taxonomy ↔ kickoff R&R ↔ WBS: document classification is an early operating rule.
- Requirements ↔ AI strategy: AI-assisted effort reduction appears in requirements and is operationalized in planning.

## Suggested questions
1. Which document is the source of truth for deliverable status?
2. How do WBS output names map to official deliverables?
3. What is the canonical target architecture across overview and WBS?

## Gaps / ambiguities
- `03_mapping`~`09_minutes` are mostly placeholders.
- `99_archive` has no detailed policy.
- The two AI planning docs overlap and lack a canonical version marker.
- No explicit traceability matrix from requirements to WBS/deliverables.
