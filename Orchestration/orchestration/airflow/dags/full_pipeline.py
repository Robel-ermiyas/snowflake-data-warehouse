"""
Full Data Pipeline
Purpose: Orchestrate end-to-end data flow from S3 to business metrics
Schedule: Daily at 2:00 AM UTC
Dependencies: S3 availability, Snowflake connectivity
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator

default_args = {
    'owner': 'data_engineering',
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'retries': 1,
    'retry_delay': timedelta(minutes=10)
}

with DAG(
    'full_data_pipeline',
    default_args=default_args,
    description='End-to-end data pipeline from S3 to business metrics',
    schedule_interval='0 2 * * *',  # Daily at 2:00 AM UTC
    catchup=False,
    tags=['end-to-end', 'orchestration']
) as dag:

    start_pipeline = DummyOperator(task_id='start_pipeline')

    # Trigger bronze layer pipeline
    trigger_bronze = TriggerDagRunOperator(
        task_id='trigger_bronze_pipeline',
        trigger_dag_id='bronze_data_pipeline',
        wait_for_completion=True
    )

    # Trigger silver layer pipeline
    trigger_silver = TriggerDagRunOperator(
        task_id='trigger_silver_pipeline',
        trigger_dag_id='silver_data_pipeline',
        wait_for_completion=True
    )

    # Trigger gold layer pipeline
    trigger_gold = TriggerDagRunOperator(
        task_id='trigger_gold_pipeline',
        trigger_dag_id='gold_data_pipeline',
        wait_for_completion=True
    )

    end_pipeline = DummyOperator(task_id='end_pipeline')

    # Define complete pipeline flow
    start_pipeline >> trigger_bronze >> trigger_silver >> trigger_gold >> end_pipeline
