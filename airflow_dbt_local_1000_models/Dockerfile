FROM apache/airflow:3.0.0

USER root
COPY requirements-airflow.txt /requirements-airflow.txt
RUN chown airflow:0 /requirements-airflow.txt

USER airflow
RUN pip install --no-cache-dir aenum deprecation msgpack virtualenv openlineage-integration-common
RUN pip install --no-cache-dir --no-deps astronomer-cosmos==1.14.2
RUN pip install --no-cache-dir dbt-postgres==1.10.0
