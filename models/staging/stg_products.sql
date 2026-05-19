{{ config(materialized='view') }}

select
    product_id::integer as product_id,
    product_name,
    category,
    subcategory,
    unit_price::numeric(12, 2) as unit_price,
    active_flag::boolean as is_active
from {{ source('raw_orders_training', 'products') }}
