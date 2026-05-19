{% macro simulate_incremental_append() %}
  {% do run_query("insert into " ~ source('raw', 'orders') ~ " (order_id, customer_id, order_date, order_status, sales_channel, shipping_city, shipping_country, loaded_at) values (25, 2, date '2025-02-01', 'placed', 'web', 'Busan', 'KR', timestamp '2026-05-19 00:00:00'), (26, 7, date '2025-02-02', 'delivered', 'mobile', 'Seoul', 'KR', timestamp '2026-05-19 00:00:00')") %}
  {% do run_query("insert into " ~ source('raw', 'order_items') ~ " (order_item_id, order_id, product_id, quantity, unit_price) values (49, 25, 12, 1, 149.00), (50, 25, 2, 1, 89.00), (51, 26, 4, 1, 219.00), (52, 26, 7, 1, 129.00)") %}
{% endmacro %}
