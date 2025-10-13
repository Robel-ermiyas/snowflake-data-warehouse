# Business Glossary - Gold Layer

## 📋 Overview
This document defines the business terms, metrics, and dimensions used in the Gold layer of the data warehouse. It serves as the single source of truth for business definitions.

## 🎯 Purpose
- Standardize metric definitions across the project
- Provide business context for data models
- Enable consistent terminology for analytics
- Support data quality initiatives

---

## 📊 Core Dimensions

### Customer Dimension (`dim_customers`)
**Business Definition**: Unified view of customers combining CRM and ERP system data

| Field | Business Definition | Source System | Business Rules |
|-------|-------------------|---------------|----------------|
| `customer_key` | Unique identifier for customer dimension | Generated | SHA-256 hash of customer_id + create_date |
| `customer_id` | Natural key from CRM system | CRM | Primary customer identifier |
| `customer_number` | Business customer number | CRM/ERP | Used for system integration |
| `country` | Customer geographic location | ERP | Standardized country names |
| `customer_segment` | Behavioral classification | Calculated | RFM-based: VIP, Regular, Occasional, New |
| `value_segment` | Monetary value classification | Calculated | Spending-based: High, Medium, Low, Minimal Value |

### Product Dimension (`dim_products`)
**Business Definition**: Complete product catalog with category hierarchy

| Field | Business Definition | Source System | Business Rules |
|-------|-------------------|---------------|----------------|
| `product_key` | Unique identifier for product dimension | Generated | SHA-256 hash of product_id + product_key + start_date |
| `product_line` | Business product category | CRM | Mountain, Road, Touring, Other Sales |
| `category` | Product main category | ERP | Maps to ERP category hierarchy |
| `maintenance` | Product maintenance indicator | ERP | High/Medium/Low maintenance requirements |

### Date Dimension (`dim_dates`)
**Business Definition**: Calendar dimension for time-based analysis

| Field | Business Definition | Business Rules |
|-------|-------------------|----------------|
| `date_key` | Unique identifier for date dimension | Sequential integer |
| `day_type` | Weekday/Weekend classification | Weekend: Saturday & Sunday |
| `holiday_flag` | Business holiday indicator | Christmas, New Year recognized |

---

## 📈 Key Business Metrics

### Sales Performance Metrics

#### Average Order Value (AOV)
**Formula**: `Total Sales Revenue / Number of Orders`  
**Business Purpose**: Measure average transaction value to understand customer spending patterns  
**Usage**: E-commerce performance, pricing strategy evaluation  
**Calculation**: `{{ calculate_aov('total_sales', 'order_count') }}`

#### Sales Growth Rate
**Formula**: `(Current Period Sales - Previous Period Sales) / Previous Period Sales`  
**Business Purpose**: Track revenue growth trends over time  
**Usage**: Performance tracking, forecasting  
**Calculation**: `{{ calculate_growth_rate('current_sales', 'previous_sales') }}`

#### Customer Lifetime Value (LTV)
**Formula**: `Total Customer Revenue / Number of Customers`  
**Business Purpose**: Measure long-term customer value for retention strategies  
**Usage**: Customer acquisition cost justification, retention programs

### Marketing Metrics

#### Customer Acquisition Cost (CAC)
**Formula**: `Total Marketing Spend / New Customers Acquired`  
**Business Purpose**: Measure efficiency of customer acquisition efforts  
**Usage**: Marketing ROI analysis, budget allocation

#### Conversion Rate
**Formula**: `Conversions / Opportunities`  
**Business Purpose**: Measure effectiveness of sales and marketing funnels  
**Usage**: Funnel optimization, campaign performance

---

## 🏷️ Customer Segmentation Framework

### RFM Segmentation Model
**Purpose**: Classify customers based on behavior for targeted marketing

#### Frequency Segments
- **VIP**: 10+ orders (Most engaged customers)
- **Regular**: 5-9 orders (Loyal repeat customers)
- **Occasional**: 2-4 orders (Developing relationship)
- **New**: 1 order (Newly acquired customers)

#### Value Segments
- **High Value**: $10,000+ total spending
- **Medium Value**: $5,000 - $9,999 total spending
- **Low Value**: $1,000 - $4,999 total spending
- **Minimal Value**: <$1,000 total spending

---

## 🔄 Refresh Cadence

| Model | Refresh Frequency | Business Reason |
|-------|------------------|-----------------|
| Core Dimensions | Incremental (Daily) | Real-time customer and product updates |
| Fact Tables | Incremental (Daily) | New transaction processing |
| Business Marts | Full Refresh (Daily) | Consistent aggregated metrics |
| Date Dimension | Static (Annual) | Calendar doesn't change frequently |

---

## 🎯 Business Use Cases

### Sales Analysis
- **Performance Tracking**: Monitor sales by product line and region
- **Trend Analysis**: Identify growth patterns and seasonal trends
- **Forecasting**: Predict future sales based on historical data

### Customer Analytics
- **Customer Segmentation**: Target campaigns based on behavior
- **Acquisition Analysis**: Measure marketing channel effectiveness
- **Retention Programs**: Identify at-risk customers for intervention

### Financial Reporting
- **Revenue Reporting**: Accurate financial performance measurement
- **ROI Analysis**: Marketing and sales investment returns
- **Budget Planning**: Data-driven budget allocation

---

## 🔍 Data Quality Standards

### Referential Integrity
- All fact table records must have valid dimension references
- No orphaned customer or product records allowed
- Date dimension must cover all fact table dates

### Business Logic Validation
- No negative sales amounts permitted
- Quantity and price must match sales amount calculations
- Customer segments must follow defined business rules

### Temporal Consistency
- No future-dated orders allowed
- Acquisition dates cannot be in the future
- Reasonable date ranges for all temporal data

---
© 2025 Robel Ermiyas
