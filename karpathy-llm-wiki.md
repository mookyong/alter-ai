# karpathy-llm-wiki

karpathy-llm-wiki : raw 문서 → wiki 지식 페이지 흐름을 일관되게 수행하도록 지시하는 Skill

---

# 운영 방식

1. 외부 문서, 회의록, Q&A, 설계 메모를 계속 ingest
2. 질문은 "내 wiki 기준으로"라고 명시
3. 좋은 답변은 archive page로 저장
4. 주 1회 또는 주요 문서 추가 후 lint

---

# ingest

## 1. URL
```text
karpathy-llm-wiki를 사용해서 이 URL을 ingest 해줘.
topic은 dbt로 분류해줘.
URL: <URL>
```

## 2. 로컬 파일
```text
karpathy-llm-wiki를 사용해서 이 파일을 ingest 해줘.
파일: docs/dbt_training_qna.md
topic은 dbt-training으로 분류해줘.
```

## 3. 텍스트 대상
```text
아래 내용을 karpathy-llm-wiki에 ingest 해줘.
topic은 gsr-dbt-migration으로 분류해줘.
원문 의미는 보존하고, wiki에는 durable knowledge page 형태로 정리해줘.
```

---

# wiki 기반 답변: Query
```text
내 wiki 기준으로 <주제>를 설명해줘.
가능하면 관련 wiki 문서를 근거로 링크를 달아줘.

내 wiki 기준으로 dbt staging, intermediate, marts의 차이를 설명해줘.
내 wiki 기준으로 profiles.yml의 threads 설정 기준을 정리해줘.
내 wiki에 있는 내용만 기준으로 dbt selector.yml 사용법을 요약해줘.
```

---

# 답변 저장 (Archive)
```text
방금 답변을 wiki archive page로 저장해줘.
이 답변을 dbt 교육 Q&A용 archive page로 저장해줘.

방금 답변을 wiki archive page로 저장해줘.
제목은 "<저장할 제목>"으로 해줘.
```

---

# 품질 점검: Lint
```text
Lint my wiki.
내 LLM wiki를 lint 해줘. 깨진 링크, index 누락, raw 참조 오류를 점검하고 자동 수정 가능한 것은 수정해줘.

내 wiki를 lint 해줘.
자동 수정 가능한 것은 수정하고, 판단이 필요한 이슈는 목록으로 보고해줘.
```

---

# 실습
```text
karpathy-llm-wiki를 사용해서 아래 내용을 ingest 해줘.
내 wiki 기준으로 dbt 아키텍트의 역할을 단계별 산출물과 action item 중심으로 정리해줘.
내 wiki 기준으로 DataStage ETL을 dbt ELT로 전환할 때 가장 위험한 검증 포인트를 정리해줘.
내 wiki 기준으로 dbt 프로젝트 폴더 구조 권장안을 README 형식으로 만들어줘.
```
