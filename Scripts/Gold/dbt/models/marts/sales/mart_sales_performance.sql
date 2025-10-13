{{
    config(
        materialized='table'
    )
}}

/*
Sales Performance Mart
Purpose: Aggregate sales metrics for business performance reporting
Business Use: Sales dashboards, performance monitoring, regional analysis
Refresh: Daily full refresh to ensure consistent metrics
*/

with sales_facts as (
    -- Aggregate sales data by key business dimensions
    select
        fs.order_date,
        dc.country,
        dp.product_line,
        dp.category,
        sum(fs.sales_amount) as total_sales,
        sum(fs.quantity) as total_quantity,
        count(distinct fs.order_number) as order_count,
        count(distinct fs.customer_key) as customer_count
    from {{ ref('fct_sales') }} fs
    join {{ ref('dim_customers') }} dc on fs.customer_key = dc.customer_key
    join {{ ref('dim_products') }} dp on fs.product_key = dp.product_key
    group by 1,2,3,4
),

performance_metrics as (
    -- Calculate derived performance indicators
    select
        order_date,
        country,
        product_line,
        category,
        total_sales,
        total_quantity,
        order_count,
        customer_count,
        -- Average Order Value (AOV) - key e-commerce metric
        total_sales / nullif(order_count, 0) as avg_order_value,
        -- Revenue per customer - customer value indicator
        total_sales / nullif(customer_count, 0) as revenue_per_customer
    from sales_facts
)

select * from performance_metrics
