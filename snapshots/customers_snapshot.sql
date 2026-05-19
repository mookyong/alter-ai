{% snapshot customers_snapshot %}

{{
    config(
      target_schema='snapshots',
      unique_key='customer_id',
      strategy='check',
      check_cols=['email', 'city', 'state', 'country', 'customer_segment']
    )
}}

select
    customer_id,
    first_name,
    last_name,
    full_name,
    email,
    city,
    state,
    country,
    signup_date,
    customer_segment
from {{ ref('stg_customers') }}

{% endsnapshot %}
