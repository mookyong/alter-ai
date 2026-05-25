with source_data as (
    select
        id as order_id,
        customer_id,
        order_date,
        status,
        total_amount
    from {{ source('postgres_raw', 'orders') }}
)

select *
from source_data
