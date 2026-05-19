select *
from {{ ref('mart_sales_summary') }}
where total_revenue < 0
