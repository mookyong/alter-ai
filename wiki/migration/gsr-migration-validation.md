# GSR 검증과 reconciliation

> Sources: internal memo, 2026-05-29
> Raw: [2026-05-29-gsr-migration-overview.md](../../raw/migration/2026-05-29-gsr-migration-overview.md)

## Overview

GSR 전환에서 검증과 reconciliation은 단순 적재 완료 여부가 아니라, 원천과 전환 결과가 의미 있게 일치하는지를 확인하는 핵심 단계다. 원본 문서는 이 영역을 중요한 관심사로만 제시하며, 세부 기준은 확정되지 않았다.

## 검증 관점

- 적재 건수 일치 여부
- DB2 테이블과 Snowflake 결과의 매핑 정확도
- 변동 데이터 반영 시점 일치 여부
- 누락, 중복, 순서 차이의 허용 범위

## Reconciliation 관점

- 원천과 대상 시스템 간 차이를 식별한다.
- 차이의 원인이 설계 차이인지 오류인지 구분한다.
- 재처리 또는 보정이 필요한 대상을 분류한다.

## 주의사항

원본에는 검증 기준의 구체 수치나 합격 기준이 없다. 따라서 현재 문서는 검증 영역의 존재와 중요성만 정리한 상태이며, 상세 규칙은 미확정이다.

## See Also

- [GSR 데이터 전환 프로젝트 개요](gsr-migration-overview.md)
- [GSR 전환 범위와 우선순위](gsr-migration-scope-priorities.md)
- [dbt 모델링 기준](../dbt/dbt-modeling-standard.md)
