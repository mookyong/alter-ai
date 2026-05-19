-- depends_on: {{ ref('int_order_items_enriched') }}
{{ config(
    materialized='incremental',
    unique_key='summary_key'
) }}

with source_data as (
    select *
    from {{ ref('int_order_items_enriched') }}
    {% if is_incremental() %}
    where order_date >= (
        select coalesce(max(order_date), date '1900-01-01')
        from {{ this }}
    )
    {% endif %}
)

select
    concat_ws('|', order_date::text, sales_channel, category) as summary_key,
    order_date,
    sales_channel,
    category,
    count(distinct order_id) as order_count,
    count(*) as item_count,
    sum(quantity) as total_quantity,
    sum(line_amount) as total_revenue,
    avg(unit_price) as avg_unit_price
from source_data
group by 1, 2, 3, 4
