{{ config(materialized='table') }}

with line_items as (
    select *
    from {{ ref('int_order_items_enriched') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['order_id']) }} as order_key,
    order_id,
    customer_id,
    order_date,
    status,
    channel,
    shipping_cost,
    order_discount,
    count(*) as item_count,
    sum(quantity) as item_quantity,
    sum(line_gross_amount) as gross_item_amount,
    sum(line_net_amount) as net_item_amount,
    round(sum(line_net_amount) + max(shipping_cost) - max(order_discount), 2) as total_order_amount
from line_items
group by
    order_id,
    customer_id,
    order_date,
    status,
    channel,
    shipping_cost,
    order_discount
