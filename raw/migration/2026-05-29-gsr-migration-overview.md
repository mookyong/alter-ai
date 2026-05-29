---
title: GSR 데이터 전환 프로젝트 개요
source: internal memo
collected: 2026-05-29
published: 2026-05-29
---

# GSR 데이터 전환 프로젝트 개요

GSR 프로젝트는 기존 DB2와 DataStage 기반 ETL 자산을 S3, Snowflake, dbt, Airflow 기반 구조로 전환하는 리프트 앤 시프트 성격의 데이터 전환 프로젝트이다.

초기 데이터는 DB2에서 S3로 이관하고, 변동 데이터는 원천에서 DataStage를 이용해 S3로 적재한 뒤 Snowflake와 dbt 기반으로 변환한다.

주요 관심사는 다음과 같다.

- DataStage Job 분석
- DB2 테이블 및 컬럼 매핑
- dbt 모델 구조화
- Snowflake 적재 전략
- Airflow 기반 오케스트레이션
- 데이터 검증 및 reconciliation
- AI agent를 활용한 전환 생산성 향상

현재 과제는 5,100개 DB2 테이블, 4,000개 DataStage Job, 210TB 규모의 데이터를 대상으로 전환 범위와 우선순위를 정의하는 것이다.
