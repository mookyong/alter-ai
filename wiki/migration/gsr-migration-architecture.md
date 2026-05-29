# GSR 전환 아키텍처 개요

> Sources: internal memo, 2026-05-29
> Raw: [2026-05-29-gsr-migration-overview.md](../../raw/migration/2026-05-29-gsr-migration-overview.md)

## Overview

GSR 전환의 대상 아키텍처는 DB2와 DataStage 기반 자산을 S3, Snowflake, dbt, Airflow 중심 구조로 바꾸는 것이다. 이 문서의 핵심은 각 구성요소의 역할을 분리해 보는 데 있다.

## 아키텍처 구성

- DB2: 기존 기준 데이터와 테이블 소스
- DataStage: 변동 데이터 적재와 기존 ETL 자산
- S3: 중간 적재 및 이관 버퍼
- Snowflake: 분석용 적재 및 변환 대상
- dbt: 변환 모델 구조화
- Airflow: 오케스트레이션

## 흐름

1. 초기 데이터는 DB2에서 S3로 옮긴다.
2. 변동 데이터는 원천에서 DataStage를 통해 S3로 적재한다.
3. S3 데이터를 Snowflake로 적재하고 dbt로 변환한다.
4. Airflow가 전체 흐름을 조율한다.

## See Also

- [GSR 데이터 전환 프로젝트 개요](gsr-migration-overview.md)
- [GSR 전환 범위와 우선순위](gsr-migration-scope-priorities.md)
- [dbt 모델링 기준](../dbt/dbt-modeling-standard.md)
