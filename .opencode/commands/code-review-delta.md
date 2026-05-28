---
description: 코드 변경 영향도 초안 점검
agent: dbt-reviewer
---

먼저 `code-review-graph detect-changes --brief` 결과를 확인하고, 현재 Git 변경분의 영향 범위를 리뷰해줘.

점검 항목:
1. 변경 파일 요약
2. 영향 가능 파일
3. dbt 모델 downstream 영향
4. SQL/스크립트 리뷰 포인트
5. 테스트 필요 항목
6. PL 또는 개발팀 확인 필요사항

주의:
- 전체 프로젝트를 무작정 읽지 않는다.
- code-review-graph 결과와 `git diff`를 함께 확인한다.
- 결과가 없거나 오래되었으면 build/update 필요성을 알려준다.
