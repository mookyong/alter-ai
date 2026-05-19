with items as (
    select *
    from {{ ref('int_order_items_enriched') }}
)

select
    order_id,
    customer_id,
    max(customer_name) as customer_name,
    max(order_date) as order_date,
    max(order_month) as order_month,
    max(order_status) as order_status,
    max(sales_channel) as sales_channel,
    max(shipping_city) as shipping_city,
    max(shipping_country) as shipping_country,
    count(*) as item_count,
    sum(quantity) as total_quantity,
    sum(line_amount) as order_revenue,
    avg(unit_price) as avg_item_price
from items
group by 1, 2
