{% snapshot customers_snapshot %}

{%- set snapshot_target_schema = target.schema ~ '_snapshots' -%}

{{
    config(
      target_schema=snapshot_target_schema,
      unique_key='customer_id',
      strategy='check',
      check_cols='all'
    )
}}

select
    *
from {{ source('raw', 'customers') }}

{% endsnapshot %}
