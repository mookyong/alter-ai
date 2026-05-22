WITH RECURSIVE ORG_CHART (DEPTNO, DEPTNAME, REPORTS_TO, LEVEL) AS (
    -- 1단계: 최상위 부서 찾기 (Anchor Member)
    SELECT DEPTNO, DEPTNAME, REPORTS_TO, 1
    FROM DEPARTMENT
    WHERE REPORTS_TO IS NULL
    UNION ALL
    -- 2단계: 하위 부서를 반복적으로 조인 (Recursive Member)
    SELECT child.DEPTNO, child.DEPTNAME, child.REPORTS_TO, parent.LEVEL + 1
    FROM DEPARTMENT child
    INNER JOIN ORG_CHART parent ON child.REPORTS_TO = parent.DEPTNO
)
SELECT LEVEL, DEPTNO, DEPTNAME, REPORTS_TO
FROM ORG_CHART
ORDER BY LEVEL, DEPTNO;

-- Validation rules:
-- 1. 최상위 부서는 REPORTS_TO IS NULL 조건으로 시작해야 한다.
-- 2. 재귀 조인은 child.REPORTS_TO = parent.DEPTNO 조건을 유지해야 한다.
-- 3. LEVEL 값은 계층 깊이를 1부터 증가시켜야 한다.
-- 4. 최종 정렬은 LEVEL, DEPTNO 순서여야 한다.
