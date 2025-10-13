{{
    config(
        materialized='table'
    )
}}

/*
Customer Segmentation Mart
Purpose: Segment customers based on behavior and value for targeted marketing
Business Use: Customer lifecycle management, personalized marketing, retention strategies
Refresh: Weekly full refresh to capture customer behavior changes
*/

with customer_orders as (
    -- Aggregate customer order behavior and spending patterns
    select
        dc.customer_key,
        dc.country,
        dc.gender,
        min(fs.order_date) as first_order_date,
        max(fs.order_date) as last_order_date,
        count(distinct fs.order_number) as total_orders,
        sum(fs.sales_amount) as total_spent
    from {{ ref('fct_sales') }} fs
    join {{ ref('dim_customers') }} dc on fs.customer_key = dc.customer_key
    group by 1,2,3
),

customer_segments as (
    -- Apply segmentation logic based on RFM (Recency, Frequency, Monetary) analysis
    select
        customer_key,
        country,
        gender,
        first_order_date,
        last_order_date,
        total_orders,
        total_spent,
        -- Frequency-based segmentation: orders count
        case
            when total_orders >= 10 then 'VIP'
            when total_orders >= 5 then 'Regular'
            when total_orders >= 2 then 'Occasional'
            else 'New'
        end as customer_segment,
        -- Value-based segmentation: total spending
        case
            when total_spent >= 10000 then 'High Value'
            when total_spent >= 5000 then 'Medium Value'
            when total_spent >= 1000 then 'Low Value'
            else 'Minimal Value'
        end as value_segment
    from customer_orders
)

select * from customer_segments
