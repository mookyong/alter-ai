# Knowledge Base Index

## migration

GSR 데이터 전환 프로젝트의 범위, 아키텍처, 검증 관점을 정리한 문서 묶음.

| Article | Summary | Updated |
|---------|---------|---------|
| [GSR 데이터 전환 프로젝트 개요](migration/gsr-migration-overview.md) | DB2, DataStage, S3, Snowflake, dbt, Airflow 기반 전환 개요. | 2026-05-29 |
| [GSR 전환 아키텍처 개요](migration/gsr-migration-architecture.md) | DB2, DataStage, S3, Snowflake, dbt, Airflow의 역할과 흐름을 분리해 정리한 문서. | 2026-05-29 |
| [GSR 전환 범위와 우선순위](migration/gsr-migration-scope-priorities.md) | 5,100개 테이블, 4,000개 Job, 210TB 규모에서 우선순위 판단 기준을 정리한 문서. | 2026-05-29 |
| [GSR 검증과 reconciliation](migration/gsr-migration-validation.md) | 전환 결과의 정합성과 차이 분석 관점을 정리한 문서. | 2026-05-29 |
| [GSR 데이터 전환 프로젝트에서 dbt 전환 시 주의할 점](migration/gsr-dbt-migration-cautions.md) | [Archived] dbt 계층 설계, DataStage 전환, 검증, 우선순위, 아키텍처 분리를 요약한 아카이브 문서. | 2026-05-29 |

## dbt

dbt 모델링 기준과 전환 원칙을 정리한 문서.

| Article | Summary | Updated |
|---------|---------|---------|
| [dbt 모델링 기준](dbt/dbt-modeling-standard.md) | staging, intermediate, marts 3계층과 DataStage to dbt 전환 원칙을 정리한 문서. | 2026-05-29 |
