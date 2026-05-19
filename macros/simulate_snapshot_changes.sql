{% macro simulate_snapshot_changes() %}
  {% do run_query("update " ~ source('raw', 'customers') ~ " set email = 'inseop.oh+updated@example.com', city = 'Jeju', status = 'active' where customer_id = 17") %}
  {% do run_query("update " ~ source('raw', 'customers') ~ " set status = 'inactive' where customer_id = 20") %}
{% endmacro %}
