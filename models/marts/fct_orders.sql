select
    order_id,
    customer_id,
    customer_name,
    order_date,
    order_month,
    order_status,
    sales_channel,
    shipping_city,
    shipping_country,
    item_count,
    total_quantity,
    order_revenue,
    avg_item_price
from {{ ref('int_orders_enriched') }}
