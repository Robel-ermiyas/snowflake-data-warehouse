"""
Silver Layer Data Pipeline
Purpose: Transform bronze raw data into cleaned silver layer using dbt
Schedule: Daily at 2:15 AM UTC (after bronze completion)
Dependencies: Bronze layer data availability
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash_operator import BashOperator

default_args = {
    'owner': 'data_engineering',
    'depends_on_past': True,  # Wait for bronze layer completion
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'retries': 2,
    'retry_delay': timedelta(minutes=5)
}

with DAG(
    'silver_data_pipeline',
    default_args=default_args,
    description='Transform bronze data to silver layer using dbt',
    schedule_interval='15 2 * * *',  # Daily at 2:15 AM UTC
    catchup=False,
    tags=['silver', 'dbt', 'transformation']
) as dag:

    # Task to run dbt silver layer models
    run_silver_models = BashOperator(
        task_id='run_silver_models',
        bash_command='cd /opt/airflow/dbt/silver && dbt run --models tag:silver',
        env={
            'DBT_PROFILES_DIR': '/opt/airflow/dbt/silver',
            'DBT_PROFILE': 'silver_layer'
        }
    )

    # Task to run dbt tests on silver layer
    test_silver_models = BashOperator(
        task_id='test_silver_models',
        bash_command='cd /opt/airflow/dbt/silver && dbt test --models tag:silver',
        env={
            'DBT_PROFILES_DIR': '/opt/airflow/dbt/silver',
            'DBT_PROFILE': 'silver_layer'
        }
    )

    # Task to generate documentation
    generate_docs = BashOperator(
        task_id='generate_documentation',
        bash_command='cd /opt/airflow/dbt/silver && dbt docs generate',
        env={
            'DBT_PROFILES_DIR': '/opt/airflow/dbt/silver',
            'DBT_PROFILE': 'silver_layer'
        }
    )

    # Define task dependencies
    run_silver_models >> test_silver_models >> generate_docs
