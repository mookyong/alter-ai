select *
from {{ ref('dim_products') }}
where product_band not in ('top_seller', 'steady', 'long_tail')
