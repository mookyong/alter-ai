# 공통 규칙은 shared prompt로 분리

프로젝트가 커지면서  다수의 agent를 만들면, 프롬프트 내에 설정한 규칙의 중복이 많습니다.

예:

```text
- source() 사용
- ref() 사용
- select * 금지
- schema.yml 관리
- naming convention
```

따라서 아래와 같이 공통 문서로 분리합니다.

```text
agents/
├── shared/
│   ├── dbt-conventions.md
│   ├── naming-rules.md
│   └── review-checklist.md
```

