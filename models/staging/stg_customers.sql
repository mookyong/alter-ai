select
    cast(customer_id as integer) as customer_id,
    trim(first_name) as first_name,
    trim(last_name) as last_name,
    lower(trim(email)) as email,
    trim(city) as city,
    trim(country) as country,
    cast(signup_date as date) as signup_date,
    lower(trim(status)) as status
from {{ source('raw', 'customers') }}
