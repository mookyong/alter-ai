{{ config(materialized='view') }}

select
    order_item_id::integer as order_item_id,
    order_id::integer as order_id,
    product_id::integer as product_id,
    quantity::integer as quantity,
    unit_price::numeric(12, 2) as unit_price,
    line_discount::numeric(12, 2) as line_discount
from {{ source('raw_orders_training', 'order_items') }}
