# 🏗️ Modern Data Warehouse & Analytics Platform

**Author:** Robel Ermiyas Moges • **Year:** 2025  
**Architecture Overview:** [View Architecture](./Docs/ARCHITECTURE.md)  

---

## 📘 Overview

Welcome to the **Modern Data Warehouse & Analytics Platform** repository — a production-ready data engineering solution built on **Snowflake**, leveraging the **Medallion Architecture** (Bronze, Silver, Gold).  
This project demonstrates **enterprise-scale data management**, **modular ELT**, and **automated orchestration** with **dbt**, **Apache Airflow**, and **Terraform**.

---

## 🏛️ Medallion Architecture

The platform follows the **three-layer Medallion Design**, ensuring a scalable, governed, and high-performance data flow.

| Layer | Description |
|-------|--------------|
| 🟦 **Bronze Layer** | Ingests raw data from **AWS S3** into **Snowflake** using external stages and full-load ingestion patterns. |
| 🟩 **Silver Layer** | Cleanses, standardizes, and validates data using **dbt** with **incremental models**. |
| 🟨 **Gold Layer** | Builds **business-ready** models such as **star schemas**, **fact tables**, and **analytic marts**. |
| ⚙️ **Orchestration** | Managed with **Apache Airflow** for automated pipeline scheduling, monitoring, and observability. |

---

## 🧱 Architecture Diagram

![System Architecture](./Docs/High-level-architecture.svg)

---

## 🎯 Key Objectives

- **Performance:** Incremental transformations for optimized processing.  
- **Maintainability:** Modular dbt models with source-controlled SQL.  
- **Data Quality:** Automated testing and documentation pipelines.  
- **Scalability:** Cloud-native design using Snowflake and AWS S3.  
- **Observability:** Integrated monitoring and lineage tracking.

---

## 🚀 Enterprise Features

| Capability | Description |
|-------------|-------------|
| **☁️ Cloud-Native Integration** | Full Snowflake–AWS interoperability. |
| **🛠️ Infrastructure as Code** | Automated provisioning using **Terraform**. |
| **🔁 Orchestration** | End-to-end workflow automation with **Airflow DAGs**. |
| **🧪 Data Quality Framework** | Comprehensive dbt test coverage and validation. |
| **🔐 Security & Governance** | Role-based access and data lineage enforcement. |
| **📈 Monitoring & Alerts** | Real-time health dashboards and notifications. |

---

## 💡 Business Value

| Use Case | Business Impact | Implementation |
|-----------|----------------|----------------|
| **Customer 360°** | Unified CRM + ERP customer view | `dim_customers`, `int_unified_customers` |
| **Sales Analytics** | Real-time sales KPIs and trends | `mart_sales_performance` |
| **Customer Segmentation** | Personalized marketing & retention | `mart_customer_segmentation` |
| **Product Analytics** | Category & inventory optimization | `dim_products`, `mart_sales_trends` |

---

## ⚙️ Technology Stack

| Component | Tool | Purpose |
|------------|------|---------|
| **Data Warehouse** | ❄️ Snowflake | Central compute & storage |
| **Transformations** | 🐍 dbt | Modular SQL transformations |
| **Orchestration** | 🌪️ Apache Airflow | Workflow scheduling |
| **Storage** | ☁️ AWS S3 | Raw data lake layer |
| **Infrastructure** | 🧩 Terraform | IaC for Snowflake & Airflow |
| **Monitoring** | 📊 Grafana & Slack | Real-time observability |

---

## 📁 Repository Structure

```
snowflake-data-warehouse/
├── datasets/                           
│   ├── source_crm /
|   |    |- csv files  
│   ├── source_erp  
│   |   |- csv files                
│      
├── docs/                            # 📚 Comprehensive documentation
│   ├── ARCHITECTURE.md              # System architecture and design
│   ├── High-level-Architecture.md   # Overview of the Medallion architecture
│   └── diagrams/                    # Architecture visuals and illustrations
│       ├── High-level-architecture.svg
│       └── Data-flow-diagram.png
│
├── orchestration/                   # ⚙️ Pipeline orchestration & IaC
│   ├── airflow/                     # Apache Airflow orchestration layer
│   │   ├── dags/                    # Pipeline DAGs (Bronze → Silver → Gold)
│   │   │   ├── bronze_pipeline.py
│   │   │   ├── silver_pipeline.py
│   │   │   ├── gold_pipeline.py
│   │   │   ├── full_pipeline.py
│   │   │   └── monitoring/          # Data quality & reliability checks
│   │   ├── plugins/                 # Custom Airflow operators
│   │   │   ├── snowflake_operators.py
│   │   │   └── dbt_operators.py
│   │   ├── config/                  # Airflow configuration templates
│   │   │   ├── airflow.cfg.example
│   │   │   └── variables.json
│   │   └── docker/                  # Dockerized Airflow setup
│   │       ├── Dockerfile
│   │       ├── docker-compose.yml
│   │       └── requirements.txt
│   ├── monitoring/                  # System observability & alerting
│   │   ├── dashboards/
│   │   │   ├── pipeline_health.json
│   │   │   └── data_quality.json
│   │   ├── alerts/
│   │   │   ├── slack_notifications.py
│   │   │   └── email_templates.py
│   │   └── scripts/
│   │       ├── health_checks.py
│   │       └── backup_scripts.py
│   └── terraform/                   # Infrastructure as Code (IaC)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── scripts/                         # 🪶 Data transformation & processing layers
│   ├── bronze/                      # 🟦 Bronze Layer — Raw data ingestion
│   │   ├── 00_strategy_documentation.md  # Strategy documentation
│   │   ├── 01_file_formats.sql           # Snowflake file formats
│   │   ├── 02_external_stages.sql        # S3 stage configurations
│   │   ├── 03_table_ddl.sql              # Raw table definitions
│   │   ├── 04_load_procedure.sql         # Data ingestion logic
│   │   ├── 05_validation_procedures.sql  # Data validation scripts
│   │   └── 06_execution_script.sql       # Bronze layer execution
│   │
│   ├── silver/                     # 🟩 Silver Layer — Data cleaning & modeling
│   │   └── dbt/
│   │       ├── dbt_project.yml
│   │       ├── packages.yml
│   │       ├── models/
│   │       │   ├── staging/
│   │       │   │   ├── crm/
│   │       │   │   │   ├── stg_customers.sql
│   │       │   │   │   ├── stg_products.sql
│   │       │   │   │   ├── stg_sales.sql
│   │       │   │   │   └── schema.yml
│   │       │   │   ├── erp/
│   │       │   │   │   ├── stg_erp_customers.sql
│   │       │   │   │   ├── stg_erp_locations.sql
│   │       │   │   │   ├── stg_erp_categories.sql
│   │       │   │   │   └── schema.yml
│   │       ├── macros/
│   │       │   ├── incremental_strategy.sql
│   │       │   ├── utils.sql
│   │       │   └── schema.yml
│   │       ├── tests/
│   │       │   └── data_quality/
│   │       └── config/
│   │
│   ├── gold/                       # 🟨 Gold Layer — Business-ready analytics
│   │   └── dbt/
│   │       ├── dbt_project.yml
│   │       ├── packages.yml
│   │       ├── models/
│   │       │   ├── marts/
│   │       │   │   ├── core/
│   │       │   │   │   ├── dim_customers.sql
│   │       │   │   │   ├── dim_products.sql
│   │       │   │   │   ├── dim_dates.sql
│   │       │   │   │   ├── fct_sales.sql
│   │       │   │   │   └── schema.yml
│   │       │   │   ├── sales/
│   │       │   │   │   ├── mart_sales_performance.sql
│   │       │   │   │   ├── mart_sales_trends.sql
│   │       │   │   │   └── schema.yml
│   │       │   │   └── marketing/
│   │       │   │       ├── mart_customer_segmentation.sql
│   │       │   │       ├── mart_customer_acquisition.sql
│   │       │   │       └── schema.yml
│   │       │   └── staging/
│   │       │       └── int_unified_customers.sql
│   │       ├── macros/
│   │       │   ├── surrogate_keys.sql
│   │       │   ├── customer_segmentation.sql
│   │       │   ├── financial_metrics.sql
│   │       │   └── schema.yml
│   │       ├── tests/
│   │       │   ├── referential_integrity/
│   │       │   └── business_logic/
│   │       └── config/
│
├── config/                         # ⚙️ Configuration templates
│   ├── terraform.tfvars.example     # Terraform variables
│   ├── environment.example          # Environment variables
│   └── dbt-profiles.example         # dbt connection profiles
│
└── README.md                        # 🧭 Project overview and documentation
```

---

## 🚀 Quick Start

### Prerequisites
- Snowflake Account (ACCOUNTADMIN privileges)
- AWS Account with S3 Access
- Terraform ≥ v1.0
- Docker & Docker Compose
- Python ≥ 3.8

### Deployment Steps

```bash
# 1. Clone Repository
git clone https://github.com/Robel-ermiyas/snowflake-data-warehouse.git
cd snowflake-data-warehouse

# 2. Configure Environment
cp config/environment.example .env
# Edit .env with Snowflake and AWS credentials

# 3. Deploy Infrastructure
cd orchestration/terraform/
terraform init
terraform apply -var-file="../../config/terraform.tfvars"

# 4. Start Airflow Orchestration
cd ../airflow/docker/
docker-compose up -d
```

Access Airflow at **http://localhost:8080** and trigger `full_pipeline`.

---

## 📊 Data Model Design

**Star Schema Components**
- Dimensions: `dim_customers`, `dim_products`, `dim_dates`
- Facts: `fct_sales`
- Marts: `mart_sales_performance`, `mart_customer_segmentation`

**Core Business KPIs**
- **Average Order Value (AOV)** — Revenue per transaction  
- **Customer Lifetime Value (LTV)** — Profitability per customer  
- **Sales Growth Rate** — Month-over-month performance  
- **Customer Acquisition Cost (CAC)** — Marketing efficiency  

---

## 🔐 Security & Governance

**Role-Based Access**
| Role | Responsibility |
|------|----------------|
| `ROBEL_LOADER` | Bronze ingestion |
| `ROBEL_TRANSFORMER` | Transformations |
| `ROBEL_ANALYST` | Reporting access |
| `ROBEL_PIPELINE` | Pipeline orchestration |

**Data Protection**
- AES-256 encryption at rest  
- TLS 1.2+ in transit  
- Network-restricted Snowflake access policies  
- Comprehensive query & access audit logs  

---

## 📈 Monitoring & Operations

| Metric | Target |
|---------|--------|
| Pipeline Reliability | 99.9% uptime |
| Data Freshness | < 4 hours |
| Data Quality | 99.5% test pass rate |
| Query Performance | < 30 seconds |

**Alerting Channels**
- Slack: Real-time incident alerts  
- Email: Daily data quality summaries  
- Grafana: Performance dashboards  

---


## 🤝 Contributing
We welcome contributions!  

**Development Flow**
1. Fork the repository  
2. Create a feature branch  
3. Commit and push changes  
4. Open a Pull Request  

**Coding Standards**
- Follow dbt + SQL style guides  
- Include unit and integration tests  
- Update documentation for new modules  

---

## 📄 License

Licensed under the **MIT License**. 

---

## 📞 Contact & Resources

- 📘 **Documentation:** [`/docs`](./docs/)  
- 🐛 **Issues:** [GitHub Issues](../../issues)  
- 💬 **Discussions:** [GitHub Discussions](../../discussions)

## ☕ Stay Connected

Let’s connect! 

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/robel-ermiyas)

---
---

## 👥 Acknowledgments

Built by **Robel Ermiyas Moges (2025)** 

Special thanks to:
- **dbt Labs** — for the transformation framework  
- **Apache Airflow** — for powerful orchestration  
- **Snowflake** — for scalable cloud warehousing  
- **AWS** — for reliable data lake infrastructure  

> *“Data is the new oil — but only if you can refine it.”*  
> — *Modern Data Refinement at Scale* 🚀
