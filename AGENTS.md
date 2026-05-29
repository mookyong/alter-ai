# GSR LLM Wiki PoC

이 저장소는 GSR 데이터 전환 프로젝트 지식관리를 위한 LLM Wiki 실습 저장소이다.

## 목적

- 회의록, 분석 메모, dbt 기준, DataStage 분석 결과를 Markdown 기반 지식베이스로 정리한다.
- raw/에는 원본 자료를 보관한다.
- wiki/에는 AI가 유지하는 요약, 개념, 의사결정, 관련 문서 링크를 저장한다.
- raw/ 파일은 원본성이 중요하므로 사용자가 명시하지 않는 한 수정하지 않는다.
- wiki/ 파일은 karpathy-llm-wiki skill 규칙에 따라 생성·갱신한다.

## 운영 규칙

- 원본 문서는 raw/에 저장한다.
- 정리된 지식 문서는 wiki/에 저장한다.
- 모든 wiki 문서는 출처 raw 파일을 링크해야 한다.
- 모순되는 내용은 삭제하지 말고 "Contradictions" 또는 "주의사항" 섹션에 기록한다.
- 확정되지 않은 내용은 "가정", "검토 필요", "미확정"으로 표시한다.
- GSR 프로젝트 문서에서는 DataStage, DB2, Snowflake, dbt, Airflow, S3, migration, WBS, 검증, reconciliation 용어를 일관되게 사용한다.

## 주요 작업 요청 예시

- "문서를 LLM wiki에 ingest 해줘."
- "raw/migration 아래 문서를 읽고 wiki를 갱신해줘."
- "dbt 전환 기준에 대해 내가 알고 있는 내용을 요약해줘."
- "wiki를 lint 해줘."
- "DataStage to dbt 전환 관련 모순이나 누락을 찾아줘."

