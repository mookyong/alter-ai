select
    cast(order_id as integer) as order_id,
    cast(customer_id as integer) as customer_id,
    cast(order_date as date) as order_date,
    lower(trim(order_status)) as order_status,
    lower(trim(sales_channel)) as sales_channel,
    trim(shipping_city) as shipping_city,
    trim(shipping_country) as shipping_country,
    cast(loaded_at as timestamp) as loaded_at
from {{ source('raw', 'orders') }}
