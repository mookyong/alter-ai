select
    order_item_id,
    order_id,
    customer_id,
    customer_name,
    order_date,
    order_month,
    order_status,
    sales_channel,
    shipping_city,
    shipping_country,
    product_id,
    product_name,
    category,
    quantity,
    unit_price,
    line_amount
from {{ ref('int_order_items_enriched') }}
