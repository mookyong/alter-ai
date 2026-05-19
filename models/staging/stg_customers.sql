{{ config(materialized='view') }}

select
    customer_id::integer as customer_id,
    initcap(first_name) as first_name,
    initcap(last_name) as last_name,
    initcap(first_name) || ' ' || initcap(last_name) as full_name,
    lower(email) as email,
    city,
    state,
    country,
    signup_date::date as signup_date,
    customer_segment
from {{ source('raw_orders_training', 'customers') }}
