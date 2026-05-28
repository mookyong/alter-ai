# AS-IS 환경 분석

## 목적

기존 데이터분석 시스템의 현황과 이관 리스크를 파악한다.

## 주요 대상

- DW DB: IBM DB2 11.1
- OS: IBM AIX 7.1
- ETL: IBM DataStage
- BI: MSTR, ArcPlan(Longview 대상)
- BI 포털: Java SDK, JSP, Tomcat

## 핵심 요구

- AS-IS 데이터 환경 구성과 데이터 모델을 분석한다.
- 효율적이고 안정적인 이관 방안을 도출한다.
- 이관 작업 시 예상 리스크를 식별한다.

## 참고 현황

- DW DB 규모: 약 210TB(압축 기준)
- 테이블 수: 약 5,100개
- 일몰된 사업부 데이터는 이관 대상에서 제외
