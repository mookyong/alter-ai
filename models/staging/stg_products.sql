select
    cast(product_id as integer) as product_id,
    trim(product_name) as product_name,
    trim(category) as category,
    cast(unit_price as numeric(10, 2)) as unit_price,
    cast(is_active as boolean) as is_active,
    cast(launched_at as date) as launched_at
from {{ source('raw', 'products') }}
