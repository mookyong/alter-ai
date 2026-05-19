with order_items as (
    select *
    from {{ ref('stg_order_items') }}
),
orders as (
    select *
    from {{ ref('stg_orders') }}
),
customers as (
    select *
    from {{ ref('stg_customers') }}
),
products as (
    select *
    from {{ ref('stg_products') }}
)

select
    oi.order_item_id,
    oi.order_id,
    o.customer_id,
    concat(c.first_name, ' ', c.last_name) as customer_name,
    o.order_date,
    date_trunc('month', o.order_date)::date as order_month,
    o.order_status,
    o.sales_channel,
    o.shipping_city,
    o.shipping_country,
    oi.product_id,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    oi.line_amount
from order_items oi
join orders o
    on oi.order_id = o.order_id
join customers c
    on o.customer_id = c.customer_id
join products p
    on oi.product_id = p.product_id
