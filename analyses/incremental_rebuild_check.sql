select
    max(order_date) as latest_order_date,
    sum(total_revenue) as total_revenue
from {{ ref('mart_sales_summary') }}
