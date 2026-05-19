{{ config(materialized='view') }}

with order_items as (
    select *
    from {{ ref('stg_order_items') }}
),
orders as (
    select *
    from {{ ref('stg_orders') }}
),
products as (
    select *
    from {{ ref('stg_products') }}
)

select
    oi.order_item_id,
    oi.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.channel,
    o.shipping_cost,
    o.order_discount,
    oi.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    oi.quantity,
    oi.unit_price,
    oi.line_discount,
    oi.quantity * oi.unit_price as line_gross_amount,
    greatest((oi.quantity * oi.unit_price) - oi.line_discount, 0) as line_net_amount
from order_items oi
join orders o
    on oi.order_id = o.order_id
join products p
    on oi.product_id = p.product_id
