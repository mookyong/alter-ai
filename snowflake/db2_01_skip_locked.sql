SELECT ORDER_ID, CUSTOMER_ID, STATUS
FROM ORDERS
WHERE STATUS = 'PENDING'
ORDER BY CREATE_TIME ASC
LIMIT 10;

-- Validation rules:
-- 1. 결과 건수는 최대 10건이어야 한다.
-- 2. CREATE_TIME ASC 정렬이 유지되어야 한다.
-- 3. DB2의 SKIP LOCKED DATA 의미는 Snowflake에서 직접 대응되지 않으므로 제외되었는지 확인한다.
-- 4. 대기 중(PENDING) 주문만 반환되어야 한다.
