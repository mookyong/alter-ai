SELECT EMPNO, FIRSTNME, LASTNAME, HIREDATE
FROM EMPLOYEE
WHERE DEPTNO = 'D11'
QUALIFY ROW_NUMBER() OVER (ORDER BY HIREDATE DESC) BETWEEN 11 AND 20;

-- Validation rules:
-- 1. DEPTNO = 'D11' filter must be preserved.
-- 2. Return only rows 11 through 20 by HIREDATE DESC.
-- 3. ROW_NUMBER-based pagination semantics must be preserved.
-- 4. Returned columns must be EMPNO, FIRSTNME, LASTNAME, HIREDATE.
