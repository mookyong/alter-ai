with orders as (
    select *
    from {{ ref('int_orders_enriched') }}
)

select
    customer_id,
    max(customer_name) as customer_name,
    count(*) as order_count,
    sum(item_count) as item_count,
    sum(total_quantity) as total_quantity,
    sum(order_revenue) as total_revenue,
    avg(order_revenue) as avg_order_value,
    min(order_date) as first_order_date,
    max(order_date) as last_order_date
from orders
group by 1
