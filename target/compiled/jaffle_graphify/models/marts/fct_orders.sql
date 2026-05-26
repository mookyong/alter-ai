with orders as (
    select * from "jaffle_graphify"."main"."stg_orders"
),

payments as (
    select
        order_id,
        sum(amount) as total_amount
    from "jaffle_graphify"."main"."stg_payments"
    group by 1
)

select
    orders.order_id,
    orders.customer_id,
    orders.order_date,
    orders.status,
    coalesce(payments.total_amount, 0) as total_amount
from orders
left join payments using (order_id)