select
    cast(order_item_id as integer) as order_item_id,
    cast(order_id as integer) as order_id,
    cast(product_id as integer) as product_id,
    cast(quantity as integer) as quantity,
    cast(unit_price as numeric(10, 2)) as unit_price,
    cast(quantity as numeric(10, 2)) * cast(unit_price as numeric(10, 2)) as line_amount
from {{ source('raw', 'order_items') }}
