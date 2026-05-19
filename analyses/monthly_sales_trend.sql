select
    order_month,
    sales_channel,
    sum(order_revenue) as revenue,
    sum(item_count) as items,
    count(*) as orders
from {{ ref('fct_orders') }}
group by 1, 2
order by 1, 2
