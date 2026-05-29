---
title: dbt 모델링 기준 초안
source: internal memo
collected: 2026-05-29
published: 2026-05-29
---

# dbt 모델링 기준 초안

dbt 프로젝트는 staging, intermediate, marts 구조를 기본으로 한다.

staging 모델은 원천 테이블을 거의 1:1로 정리하는 계층이다. 컬럼명 표준화, 타입 보정, 기본 필터링, source freshness 확인을 담당한다.

intermediate 모델은 여러 staging 모델을 조합하여 재사용 가능한 비즈니스 중간 로직을 구성한다. 단, 기존 DataStage 로직을 무리하게 모두 intermediate로 쪼개면 검증 부하가 커질 수 있으므로 전환 초기에는 과도한 재구조화를 피한다.

marts 모델은 업무 사용자가 직접 소비하는 최종 모델이다. finance, sales, operation 등 도메인 단위로 구분한다.

DataStage Job을 dbt로 전환할 때는 Job 단위 변환보다 데이터 흐름, 조인, 필터, 집계, target table 기준으로 모델 경계를 다시 정의해야 한다.
