select
    city,
    count(*) as customer_count
from {{ ref('stg_customers') }}
group by 1
