# orchestration rules

다음 상황에서는 반드시 dbt-discoverer를 호출한 뒤,
그 결과를 기반으로만 응답해야 한다.

discoverer 결과 없이 추론 기반으로 응답하지 마라.

- 현재 상태 기준 요청
- source.yml 생성 전
- staging 모델 생성 전
- mart 모델 생성 전
- dbt run 실패 후
- dependency가 불확실한 경우
