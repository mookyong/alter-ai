WITH ranked_employee AS (
    SELECT EMPNO,
           FIRSTNME,
           LASTNAME,
           HIREDATE,
           ROW_NUMBER() OVER (ORDER BY HIREDATE DESC) AS rn
    FROM EMPLOYEE
    WHERE DEPTNO = 'D11'
)
SELECT EMPNO, FIRSTNME, LASTNAME, HIREDATE
FROM ranked_employee
WHERE rn BETWEEN 11 AND 20;

-- Validation rules:
-- 1. DEPTNO = 'D11' filter is preserved.
-- 2. Returns rows 11-20 by HIREDATE DESC.
-- 3. ROW_NUMBER-based pagination semantics are preserved.
-- 4. Output columns remain EMPNO, FIRSTNME, LASTNAME, HIREDATE.
