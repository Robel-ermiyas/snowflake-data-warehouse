# 🏗️ Modern Data Warehouse & Analytics Platform

**Author:** Robel Ermiyas Moges • **Year:** 2025  
**Architecture:** [View Diagram](./Docs/High-level-architecture.svg)  

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
modern-data-warehouse/
├── bronze/               # Raw data ingestion
├── silver/dbt/           # Cleansing and staging
├── gold/dbt/             # Business marts and analytics
├── orchestration/        # Airflow DAGs, Terraform IaC
├── docs/                 # Architecture & deployment docs
├── scripts/              # Utility scripts
└── config/               # Environment and profile configs
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
git clone https://github.com/your-org/modern-data-warehouse.git
cd modern-data-warehouse

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

## 🔮 Roadmap

| Phase | Focus | Status |
|--------|--------|---------|
| **Phase 1: Foundation** | Medallion architecture, orchestration | ✅ Complete |
| **Phase 2: Enhancement (Q3-Q4 2024)** | Real-time ingestion, ML models, cost optimization | 🔄 In Progress |
| **Phase 3: Optimization (2025)** | Predictive analytics, NLP queries, data marketplace | 🧠 Planned |

---

## 🤝 Contributing

We welcome contributions!  
Please read the **[CONTRIBUTING.md](./docs/CONTRIBUTING.md)** before submitting a PR.

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

Licensed under the **MIT License**. See the [LICENSE](./LICENSE) file for details.

---

## 📞 Contact & Resources

- 📘 **Documentation:** [`/docs`](./docs/)  
- 🐛 **Issues:** [GitHub Issues](../../issues)  
- 💬 **Discussions:** [GitHub Discussions](../../discussions)

---

## 👥 Acknowledgments

Built with ❤️ by **Robel Ermiyas Moges (2025)** and the Data Engineering Team.  

Special thanks to:
- **dbt Labs** — for the transformation framework  
- **Apache Airflow** — for powerful orchestration  
- **Snowflake** — for scalable cloud warehousing  
- **AWS** — for reliable data lake infrastructure  

> *“Data is the new oil — but only if you can refine it.”*  
> — *Modern Data Refinement at Scale* 🚀
