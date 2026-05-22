SELECT EMPNO, SALARY, DEPTNO
FROM EMPLOYEE
AT (TIMESTAMP => TO_TIMESTAMP_NTZ('2025-12-31 23:59:59.000000'))
WHERE EMPNO = '000120';

-- Validation rules:
-- 1. 조회 시점은 2025-12-31 23:59:59.000000 이어야 한다.
-- 2. EMPNO = '000120' 조건이 유지되어야 한다.
-- 3. Time Travel 대상 테이블이 보존 기간 내 데이터에 대해 조회 가능한지 확인한다.
-- 4. 반환 컬럼은 EMPNO, SALARY, DEPTNO 여야 한다.
