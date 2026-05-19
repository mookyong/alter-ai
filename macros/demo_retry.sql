{% macro demo_retry(task_name='demo_retry') %}
  {% if execute %}
    {% set sql %}
      select should_fail
      from {{ source('raw_orders_training', 'retry_controls') }}
      where task_name = '{{ task_name }}'
      limit 1
    {% endset %}

    {% set result = run_query(sql) %}
    {% set should_fail = result.columns[0].values()[0] if result and result.rows|length > 0 else false %}

    {% if should_fail in [true, 'true', 'True', 't', '1'] %}
      {% do exceptions.raise_compiler_error('demo_retry is configured to fail') %}
    {% endif %}
  {% endif %}

  {% do log('demo_retry completed successfully', info=true) %}
{% endmacro %}
