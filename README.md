# ds-to-dbt-airflow-docs

DataStage -> dbt/Airflow 전환 프로젝트의 문서 관리 저장소입니다.

## Project Structure

```text
ds-to-dbt-airflow-docs/
├─ 00_overview/      # 프로젝트 개요
├─ 01_planning/      # 일정, 범위, 리소스
├─ 02_requirements/  # 요구사항 정리
├─ 03_mapping/       # DataStage job 매핑
├─ 04_design/        # dbt, Airflow 설계
├─ 05_execution/     # 수행 이력, 진행 문서
├─ 06_test/          # 검증, 테스트 결과
├─ 07_release/       # 전환, 릴리스 문서
├─ 08_risk_issue/    # 이슈, 리스크 관리
├─ 09_minutes/       # 회의록
├─ 99_archive/       # 완료, 보관 문서
└─ .vscode/          # VSCode 설정
```

## Usage

- 각 단계별 문서를 해당 폴더에 저장합니다.
- 문서명은 날짜나 버전을 포함해 관리합니다.
- 완료된 문서는 `99_archive`로 이동합니다.
