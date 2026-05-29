# dbt 모델링 기준

> Sources: internal memo, 2026-05-29
> Raw: [2026-05-29-dbt-modeling-standard.md](../../raw/dbt/2026-05-29-dbt-modeling-standard.md)

## Overview

이 문서는 dbt 프로젝트의 기본 모델링 기준을 staging, intermediate, marts 3계층으로 정리한다. 핵심은 원천을 거의 1:1로 정리하는 staging, 재사용 가능한 비즈니스 로직을 담는 intermediate, 최종 소비용 marts를 분리하되, DataStage 로직을 dbt로 옮길 때 과도한 세분화를 피하는 데 있다.

## Model Layers

### Staging

- 원천 테이블을 거의 1:1로 정리한다.
- 컬럼명 표준화와 타입 보정을 수행한다.
- 기본 필터링과 `source freshness` 확인을 담당한다.

### Intermediate

- 여러 staging 모델을 조합해 비즈니스 중간 로직을 만든다.
- 재사용 가능한 변환 단위를 만든다.
- 전환 초기에는 기존 DataStage 로직을 무리하게 잘게 쪼개지 않는다.

### Marts

- 업무 사용자가 직접 소비하는 최종 모델이다.
- finance, sales, operation 같은 도메인 단위로 구분한다.

## Conversion Principle

DataStage Job을 dbt로 전환할 때는 Job 단위 복제보다 데이터 흐름, 조인, 필터, 집계, target table 기준으로 모델 경계를 다시 정의해야 한다. 이 기준이 있어야 staging/intermediate/marts 분리가 실제 사용 방식과 맞는다.

## Caution

원본은 이 기준을 초안으로 제시한다. 따라서 세부 네이밍 규칙, 테스트 규칙, materialization 정책은 아직 미확정이다.

## See Also

- [GSR 데이터 전환 프로젝트 개요](../migration/gsr-migration-overview.md)
- [GSR 전환 아키텍처 개요](../migration/gsr-migration-architecture.md)
- [GSR 전환 범위와 우선순위](../migration/gsr-migration-scope-priorities.md)
- [GSR 검증과 reconciliation](../migration/gsr-migration-validation.md)
