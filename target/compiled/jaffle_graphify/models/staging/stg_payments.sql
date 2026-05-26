select
    id as payment_id,
    order_id,
    payment_method,
    amount
from "jaffle_graphify"."main"."raw_payments"