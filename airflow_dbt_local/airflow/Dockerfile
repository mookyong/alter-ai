FROM apache/airflow:3.0.0-python3.11

COPY requirements.txt /requirements.txt

USER airflow

RUN pip install --no-cache-dir -r /requirements.txt \
    && python -m venv /home/airflow/dbt_venv \
    && /home/airflow/dbt_venv/bin/pip install --no-cache-dir dbt-core==1.9.10 dbt-postgres==1.9.1
