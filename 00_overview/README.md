# 00_overview

## 프로젝트 개요

본 프로젝트는 2026년 6월 1일부터 시작하는 IBM DataStage 기반 업무를 `dbt`와 `Airflow` 중심의 ELT 구조로 전환하고, 레이크하우스 환경으로 클라우드 이전하기 위한 문서 관리 프로젝트입니다.

### 주요 범위

- 레이크하우스 환경 구성
- 편의점, 수퍼, MD, 고객통합, 임원 대시보드 등 주요 DW/DM의 클라우드 이전
- IBM DataStage ETL Job의 `dbt + Airflow` 기반 재구현
- 초기 데이터 이행 및 일일/월간 증분 적재 체계 구축
- 데이터 정합성 검증 체계 수립
- ArcPlan, Strategy(MSTR) 등 BI 관련 시스템 업그레이드 및 이전
- 통합 BI 포털 기획 및 개발
- 개발 소스 형상관리, 리스크 대응, 일정/리소스 관리

### AS-IS 현황 요약

- DW DB: IBM DB2 11.1
- ETL: IBM DataStage
- BI: MSTR, ArcPlan(Longview 전환 대상)
- BI 포털: Java SDK, JSP, Tomcat 기반
- DataStage Job 규모: 약 4,000건 이상 수준의 다수 배치가 존재

### 주요 산출물

- AS-IS 데이터 환경구성 분석결과
- DW 아키텍처 설계서
- AS-IS 데이터모델 분석결과
- 개념/논리/물리 데이터 모델 설계서
- DFD(Data Flow Diagram)
- 매핑 정의서
- 레이크하우스 통합 아키텍처 설계서
- TO-BE 데이터모델 설계 결과
- 착수/중간/완료 보고서
- 주간 보고서, WBS

### 문서 관리 기준

- 기획과 요구사항은 `01_planning`, `02_requirements`에 정리합니다.
- DataStage 대상 분석과 매핑은 `03_mapping`에 정리합니다.
- dbt, Airflow, 레이크하우스 설계는 `04_design`에 정리합니다.
- 수행, 검증, 릴리스, 이슈는 각각 `05_execution`, `06_test`, `07_release`, `08_risk_issue`에 정리합니다.
