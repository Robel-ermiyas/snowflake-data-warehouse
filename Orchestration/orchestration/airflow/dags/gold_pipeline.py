"""
Gold Layer Data Pipeline
Purpose: Create business-ready metrics and dimensions from silver layer
Schedule: Daily at 2:30 AM UTC (after silver completion)
Dependencies: Silver layer data availability
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash_operator import BashOperator

default_args = {
    'owner': 'data_engineering',
    'depends_on_past': True,  # Wait for silver layer completion
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'retries': 2,
    'retry_delay': timedelta(minutes=5)
}

with DAG(
    'gold_data_pipeline',
    default_args=default_args,
    description='Create business metrics and dimensions from silver layer',
    schedule_interval='30 2 * * *',  # Daily at 2:30 AM UTC
    catchup=False,
    tags=['gold', 'dbt', 'business-metrics']
) as dag:

    # Task to run dbt gold layer models
    run_gold_models = BashOperator(
        task_id='run_gold_models',
        bash_command='cd /opt/airflow/dbt/gold && dbt run --models tag:gold',
        env={
            'DBT_PROFILES_DIR': '/opt/airflow/dbt/gold',
            'DBT_PROFILE': 'gold_layer'
        }
    )

    # Task to run dbt tests on gold layer
    test_gold_models = BashOperator(
        task_id='test_gold_models',
        bash_command='cd /opt/airflow/dbt/gold && dbt test --models tag:gold',
        env={
            'DBT_PROFILES_DIR': '/opt/airflow/dbt/gold',
            'DBT_PROFILE': 'gold_layer'
        }
    )

    # Task to validate business metrics
    validate_business_metrics = BashOperator(
        task_id='validate_business_metrics',
        bash_command='cd /opt/airflow/dbt/gold && python scripts/validate_metrics.py'
    )

    # Define task dependencies
    run_gold_models >> test_gold_models >> validate_business_metrics
