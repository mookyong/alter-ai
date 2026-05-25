with source_data as (
    select
        id as customer_id,
        first_name,
        last_name,
        email,
        created_at
    from {{ source('postgres_raw', 'customers') }}
)

select *
from source_data
