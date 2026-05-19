{{ config(materialized='table') }}

with customers as (
    select *
    from {{ ref('stg_customers') }}
),
orders as (
    select *
    from {{ ref('fct_orders') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }} as customer_key,
    c.customer_id,
    c.full_name,
    c.email,
    c.city,
    c.state,
    c.country,
    c.signup_date,
    c.customer_segment,
    coalesce(count(o.order_id), 0) as total_orders,
    coalesce(sum(o.total_order_amount), 0) as lifetime_value,
    min(o.order_date) as first_order_date,
    max(o.order_date) as last_order_date,
    round({{ safe_divide('sum(o.total_order_amount)', 'count(o.order_id)') }}, 2) as avg_order_value
from customers c
left join orders o
    on c.customer_id = o.customer_id
group by
    c.customer_id,
    c.full_name,
    c.email,
    c.city,
    c.state,
    c.country,
    c.signup_date,
    c.customer_segment
