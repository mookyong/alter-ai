# GSR 데이터 전환 프로젝트 개요

> Sources: internal memo, 2026-05-29
> Raw: [2026-05-29-gsr-migration-overview.md](../../raw/migration/2026-05-29-gsr-migration-overview.md)

## Overview

GSR 데이터 전환 프로젝트는 DB2와 DataStage 중심의 기존 ETL 자산을 S3, Snowflake, dbt, Airflow 기반 구조로 옮기는 리프트 앤 시프트 성격의 전환 과제다. 현재 초점은 데이터 적재 방식, 변환 구조, 오케스트레이션, 검증 체계를 함께 정리하면서 5,100개 DB2 테이블, 4,000개 DataStage Job, 210TB 규모의 전환 범위와 우선순위를 정의하는 데 있다.

## 핵심 요약

- 초기 데이터는 DB2에서 S3로 이관한다.
- 변동 데이터는 원천에서 DataStage를 통해 S3로 적재한 뒤 Snowflake와 dbt로 변환한다.
- 주요 관심사는 DataStage 분석, DB2 매핑, dbt 모델 구조화, Snowflake 적재, Airflow 오케스트레이션, 검증과 reconciliation이다.
- 전환 범위가 크기 때문에 우선순위 정의와 작업 분해가 핵심이다.

## See Also

- [GSR 전환 아키텍처 개요](gsr-migration-architecture.md)
- [GSR 전환 범위와 우선순위](gsr-migration-scope-priorities.md)
- [GSR 검증과 reconciliation](gsr-migration-validation.md)
- [dbt 모델링 기준](../dbt/dbt-modeling-standard.md)
