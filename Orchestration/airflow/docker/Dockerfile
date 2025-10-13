FROM apache/airflow:2.7.1

USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install dbt and Snowflake provider
RUN pip install --no-cache-dir \
    dbt-snowflake==1.5.0 \
    apache-airflow-providers-snowflake==3.3.0

# Create dbt profiles directory
RUN mkdir -p /opt/airflow/dbt/silver /opt/airflow/dbt/gold
