select *
from {{ ref('dim_customers') }}
where customer_segment not in ('vip', 'repeat', 'new', 'prospect')
