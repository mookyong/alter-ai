with customers as (
    select *
    from {{ ref('stg_customers') }}
),
metrics as (
    select *
    from {{ ref('int_customer_metrics') }}
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    concat(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    c.city,
    c.country,
    c.signup_date,
    c.status,
    coalesce(m.order_count, 0) as order_count,
    coalesce(m.item_count, 0) as item_count,
    coalesce(m.total_quantity, 0) as total_quantity,
    coalesce(m.total_revenue, 0) as total_revenue,
    coalesce(m.avg_order_value, 0) as avg_order_value,
    m.first_order_date,
    m.last_order_date,
    case
        when coalesce(m.total_revenue, 0) >= 1500 then 'vip'
        when coalesce(m.total_revenue, 0) >= 500 then 'repeat'
        when coalesce(m.order_count, 0) > 0 then 'new'
        else 'prospect'
    end as customer_segment
from customers c
left join metrics m
    on c.customer_id = m.customer_id
