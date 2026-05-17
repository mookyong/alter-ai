## opencode.jsonc 설정 방법


작성 원칙:

- 설정(config)과 운영 정책(policy), 프롬프트(prompt), 역할(role) 분리
- opencode.json은 등록(register)만 담당한다.
- 실제 지능(intelligence, 행동)은 Markdown 문서로 분리한다.
- JSON: 배선(wiring) 정보 만 설정
- Markdown: 행동 또는 지능(behavior), 별도의 마크다운 문서로 작성

---

구조: 아래 내용만 포함하도록 한다.

opencode.json 최소화하는 것이 중요합니다.

- default_agent
- agent 등록
- mode
- permission
- prompt 파일 위치
- command 등록

---

예:

```json
{
  "$schema": "https://opencode.ai/config.json",  
  "default_agent": "dbt-orchestrator",
  "permission": {
    "edit": "ask",
    "bash": "ask"
  },
  "agent": {
    "dbt-orchestrator": {
      "description": "PostgreSQL 기반 dbt 프로젝트를 총괄하는 primary agent",
      "mode": "primary",
      "temperature": 0.1,
      "prompt": "{file:./agents/primary/dbt-orchestrator.md}",
      // primary 에이전트가 하위 에이전트들에게 라우팅하도록 설계 가능
      "permission": {
        "edit": "ask",
        "bash": "ask"
      }
    },
    "dbt-discoverer": {
      "description": "PostgreSQL raw schema와 현재 dbt 프로젝트 상태를 탐색하는 subagent",
      "mode": "subagent",
      "temperature": 0.1,
      "prompt": "{file:./agents/subagents/dbt-discoverer.md}",
      "permission": {
        "edit": "deny",
        "bash": "ask"
      }
    }    
  }
}
```
