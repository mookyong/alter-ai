SELECT PROD_ID, PROD_NAME, PRICE
FROM PRODUCTS
WHERE CATEGORY = 'ELECTRONICS'
ORDER BY PRICE DESC
LIMIT 20;

-- Validation rules:
-- 1. ELECTRONICS 카테고리만 조회해야 한다.
-- 2. PRICE DESC 정렬이 유지되어야 한다.
-- 3. 결과는 20건으로 제한되어야 한다.
-- 4. DB2의 OPTIMIZE FOR 20 ROWS와 WITH UR에 해당하는 동작은 Snowflake 실행 SQL에서 제외되었다.
