{{
    config(
        materialized='table'
    )
}}

/*
Customer Acquisition Mart
Purpose: Track new customer acquisition metrics and initial value
Business Use: Marketing ROI analysis, acquisition channel performance, cohort analysis
Refresh: Monthly full refresh aligned with financial reporting cycles
*/

with customer_acquisition as (
    -- Measure new customer acquisition and initial purchasing behavior
    select
        date_trunc('month', dc.create_date) as acquisition_month,
        dc.country,
        count(distinct dc.customer_key) as new_customers,
        count(distinct fs.order_number) as first_orders,
        sum(fs.sales_amount) as first_month_revenue
    from {{ ref('dim_customers') }} dc
    left join {{ ref('fct_sales') }} fs 
        on dc.customer_key = fs.customer_key
        and date_trunc('month', fs.order_date) = date_trunc('month', dc.create_date)
    group by 1,2
),

acquisition_metrics as (
    -- Calculate acquisition efficiency and value metrics
    select
        acquisition_month,
        country,
        new_customers,
        first_orders,
        first_month_revenue,
        -- Average First Order Value - key acquisition metric
        first_month_revenue / nullif(new_customers, 0) as avg_first_order_value
    from customer_acquisition
)

select * from acquisition_metrics
