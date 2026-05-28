# WSL VSCode Obsidian OpenCode Graphify PL

이 저장소는 데이터 마이그레이션 프로젝트의 문서, 운영 규칙, AI Agent, 지식 그래프를 하나의 WSL 기반 작업 공간에서 관리하기 위한 프로젝트 템플릿입니다.

## 핵심 목표

- 문서 원본을 `docs/`로 단일화합니다.
- VSCode는 프로젝트 전체를 관리합니다.
- Obsidian은 `docs/`만 Vault로 엽니다.
- OpenCode는 프로젝트 루트에서 실행합니다.
- Graphify와 code-review-graph로 문맥과 영향도를 줄입니다.

## 운영 모델

```text
WSL 프로젝트 루트
├─ VSCode: 전체 프로젝트 관리
├─ Obsidian: docs 폴더 기반 문서 연결 관리
├─ Git: 문서 및 설정 변경 이력 관리
├─ OpenCode: PL 업무 보조 AI Agent 실행
├─ Graphify: 프로젝트 지식 그래프 생성
└─ code-review-graph: 코드 변경 영향도 분석
```

## 문서 구성

- `docs/01_hands_on/part-1_overview.md`: 전체 개요와 실습 목표
- `docs/01_hands_on/part-2_wsl_setup.md`: WSL 환경에서 프로젝트 생성 및 압축 해제하기
- `docs/01_hands_on/part-3_vscode_setup.md`: VSCode 확장 설치 및 문서관리 설정하기
- `docs/01_hands_on/part-4_obsidian_setup.md`: Obsidian을 docs 폴더와 연동하기
- `docs/01_hands_on/part-5_document_workflow.md`: 회의록, 이슈, 리스크, 의사결정 연결하기
- `docs/01_hands_on/part-6_opencode_agent.md`: OpenCode 적용과 PL 업무용 Agent 구성하기
- `docs/01_hands_on/part-7_subagent_practice.md`: 회의록 요약, 문서 점검, 주간보고 생성하기
- `docs/01_hands_on/part-8_graphify_integration.md`: Graphify 적용과 지식 그래프 활용하기
- `docs/01_hands_on/part-9_code_review_graph.md`: code-review-graph 적용과 변경 영향도 분석하기
- `docs/01_hands_on/part-10_operational_standards.md`: 운영 표준과 팀 적용 방식 정리하기
- 이후 문서는 같은 형식으로 순차 추가 예정

## 시작 순서

1. `README.md`로 전체 구조를 확인합니다.
2. `docs/01_hands_on/part-1_overview.md`에서 운영 원칙을 읽습니다.
3. 이후 각 부의 실습 문서를 순서대로 추가합니다.
