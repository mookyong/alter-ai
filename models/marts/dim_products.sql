{{ config(materialized='table') }}

with products as (
    select *
    from {{ ref('stg_products') }}
),
sales as (
    select *
    from {{ ref('int_order_items_enriched') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_key,
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.unit_price,
    p.is_active,
    coalesce(sum(s.quantity), 0) as units_sold,
    coalesce(sum(s.line_net_amount), 0) as revenue_generated,
    count(distinct s.order_id) as orders_covered
from products p
left join sales s
    on p.product_id = s.product_id
group by
    p.product_id,
    p.product_name,
    p.category,
    p.subcategory,
    p.unit_price,
    p.is_active
