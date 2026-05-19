with products as (
    select *
    from {{ ref('stg_products') }}
),
product_sales as (
    select
        product_id,
        sum(quantity) as units_sold,
        sum(line_amount) as revenue,
        avg(unit_price) as avg_sold_price
    from {{ ref('int_order_items_enriched') }}
    group by 1
)

select
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price,
    p.is_active,
    p.launched_at,
    coalesce(s.units_sold, 0) as units_sold,
    coalesce(s.revenue, 0) as revenue,
    coalesce(s.avg_sold_price, 0) as avg_sold_price,
    case
        when coalesce(s.units_sold, 0) >= 20 then 'top_seller'
        when coalesce(s.units_sold, 0) >= 5 then 'steady'
        else 'long_tail'
    end as product_band
from products p
left join product_sales s
    on p.product_id = s.product_id
