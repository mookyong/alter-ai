# BI 업그레이드

## 목적

기존 BI 도구와 리포트를 클라우드 기반 환경으로 전환한다.

## 핵심 요구

- ArcPlan으로 구현된 대시보드와 리포트를 Longview로 업그레이드한다.
- Strategy(구 MSTR) 시스템을 AWS 기반 MCE(FaaS) 환경으로 이관한다.
- MSTR 및 ArcPlan의 데이터베이스 연결을 AS-IS DB2에서 TO-BE DBMS로 변경한다.
- 기존 쿼리를 새로운 환경에 맞게 최적화한다.

## 참고 사항

- BI 관련 Web 연계 소스 변경 개발이 포함된다.
- BI 포털과의 연계도 함께 고려한다.
