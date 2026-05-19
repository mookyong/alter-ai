{{ config(materialized='table') }}

with orders as (
    select *
    from {{ ref('fct_orders') }}
)

select
    order_date,
    count(*) as order_count,
    sum(item_quantity) as units_sold,
    sum(total_order_amount) as gross_revenue,
    avg(total_order_amount) as avg_order_amount
from orders
group by order_date
order by order_date
