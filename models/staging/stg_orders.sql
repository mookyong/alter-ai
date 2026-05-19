{{ config(materialized='view') }}

select
    order_id::integer as order_id,
    customer_id::integer as customer_id,
    order_date::date as order_date,
    status,
    channel,
    shipping_cost::numeric(12, 2) as shipping_cost,
    order_discount::numeric(12, 2) as order_discount
from {{ source('raw_orders_training', 'orders') }}
