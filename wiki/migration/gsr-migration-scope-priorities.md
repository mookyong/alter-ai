# GSR 전환 범위와 우선순위

> Sources: internal memo, 2026-05-29
> Raw: [2026-05-29-gsr-migration-overview.md](../../raw/migration/2026-05-29-gsr-migration-overview.md)

## Overview

GSR 전환은 5,100개 DB2 테이블, 4,000개 DataStage Job, 210TB 규모의 데이터를 다루므로, 모든 자산을 동일한 방식으로 처리할 수 없다. 이 문서는 전환 범위를 쪼개고 우선순위를 정하는 관점을 정리한다.

## 범위 판단 기준

- DB2 테이블과 컬럼 매핑의 복잡도
- DataStage Job의 영향도와 의존성
- 초기 적재와 변경 적재의 분리 가능성
- 검증과 reconciliation 난이도
- 전환 생산성에 대한 AI agent 활용 가능성

## 미확정 사항

- 어떤 테이블을 먼저 전환할지의 명시적 기준은 아직 없다.
- DataStage Job 분류 규칙은 문서에 정의되어 있지 않다.
- 검증 성공 기준과 우선순위는 후속 설계가 필요하다.

## See Also

- [GSR 데이터 전환 프로젝트 개요](gsr-migration-overview.md)
- [GSR 전환 아키텍처 개요](gsr-migration-architecture.md)
- [GSR 검증과 reconciliation](gsr-migration-validation.md)
- [dbt 모델링 기준](../dbt/dbt-modeling-standard.md)
