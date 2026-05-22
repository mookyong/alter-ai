# 호출 프롬프터

```text
sql 폴더의 sql 파일을 하나씩 읽어서  일괄로 하지말고, 하나씩 @db2-snowflake-converter subagent에 전달해서 실행 가능한 snowflake sql로 변환해줘.

```

# 아이디어

1. 생성된 문장 snowflake 문법 다시 검증
2. sql을 실제 실행해서 결과를 검증하는 기능 (snowflake 연결 정보를 제공해야합니다.)
3. db2 실행결과와 snowflake 결과를 검증하는 기능
4. docker로 db2를 설치가능한지 확인 필요
5. IBM에서 공식 Docker 이미지를 제공하고 있습니다.
6. 개발 및 테스트 용도로 무료로 사용할 수 있는 DB2 Community Edition 이미지가 Docker Hub에 공개되어 있어, 복잡한 설치 과정 없이 명령어 한 줄로 편리하게 DB2 환경을 구성할 수 있습니다.

# 관련 에이전트 프롬프터

```text
.opencode/agent/db2-snowflake-converter.md

```

# 변환 결과 검증 방법

```text
sql 변환에서 변환 결과 검증 방법으로 db2, snowflake db를 제공하고, 동일한 스키마 및 데이터를 유지하고 검증하는 방법이 가장 확실하겟네
```
