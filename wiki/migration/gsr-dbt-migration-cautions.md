# GSR 데이터 전환 프로젝트에서 dbt 전환 시 주의할 점

> Sources: [dbt 모델링 기준](../dbt/dbt-modeling-standard.md); [GSR 전환 범위와 우선순위](gsr-migration-scope-priorities.md); [GSR 검증과 reconciliation](gsr-migration-validation.md); [GSR 전환 아키텍처 개요](gsr-migration-architecture.md)
> Archived: 2026-05-29

## Overview

GSR 데이터 전환 프로젝트에서 dbt 전환은 DataStage 로직을 그대로 복제하는 작업이 아니라, staging/intermediate/marts 계층으로 재구성하면서 검증 가능성을 유지하는 작업이다. 특히 초기에는 과도한 세분화와 재구조화를 피하고, 전환 범위와 검증 기준을 함께 고려해야 한다.

## Key Points

- `staging`은 원천 테이블을 거의 1:1로 정리하는 계층으로 두고, 컬럼명 표준화, 타입 보정, 기본 필터링, `source freshness` 확인에 집중한다.
- `intermediate`는 여러 `staging` 모델을 조합하는 재사용 로직만 담고, 전환 초기에는 기존 DataStage 로직을 너무 잘게 쪼개지 않는다.
- `DataStage Job`을 그대로 1:1 복제하지 말고, 데이터 흐름, 조인, 필터, 집계, target table 기준으로 dbt 모델 경계를 다시 잡는다.
- `marts`는 최종 소비용이므로 finance, sales, operation 같은 도메인 단위로 정리한다.
- 검증과 reconciliation 기준이 아직 미확정이므로, dbt 설계 단계에서부터 적재 건수, 매핑 정확도, 변동 반영 시점, 차이 허용 범위를 같이 고려한다.
- 전환 범위가 크기 때문에 어떤 테이블과 Job을 먼저 dbt로 옮길지 우선순위 기준을 먼저 세운다.
- dbt는 전체 전환 아키텍처의 일부이므로 S3, Snowflake, Airflow와의 역할 분리를 함께 본다.

## See Also

- [dbt 모델링 기준](../dbt/dbt-modeling-standard.md)
- [GSR 데이터 전환 프로젝트 개요](gsr-migration-overview.md)
- [GSR 전환 아키텍처 개요](gsr-migration-architecture.md)
- [GSR 전환 범위와 우선순위](gsr-migration-scope-priorities.md)
- [GSR 검증과 reconciliation](gsr-migration-validation.md)
