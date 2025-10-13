{{
    config(
        materialized='table'
    )
}}

/*
Sales Trends Mart
Purpose: Analyze sales trends and growth patterns over time
Business Use: Trend analysis, forecasting, seasonal pattern identification
Refresh: Monthly full refresh to capture complete trend cycles
*/

with monthly_sales as (
    -- Aggregate sales to monthly level with previous period comparison
    select
        dd.year,
        dd.month,
        dp.product_line,
        sum(fs.sales_amount) as monthly_sales,
        sum(fs.quantity) as monthly_quantity,
        -- Previous month sales for growth calculation
        lag(sum(fs.sales_amount)) over (
            partition by dp.product_line 
            order by dd.year, dd.month
        ) as prev_month_sales
    from {{ ref('fct_sales') }} fs
    join {{ ref('dim_dates') }} dd on fs.order_date = dd.date
    join {{ ref('dim_products') }} dp on fs.product_key = dp.product_key
    group by 1,2,3
),

sales_trends as (
    -- Calculate growth metrics and trend indicators
    select
        year,
        month,
        product_line,
        monthly_sales,
        monthly_quantity,
        prev_month_sales,
        -- Absolute sales growth (current month vs previous month)
        monthly_sales - prev_month_sales as sales_growth,
        -- Percentage growth rate for trend analysis
        (monthly_sales - prev_month_sales) / nullif(prev_month_sales, 0) as sales_growth_pct
    from monthly_sales
)

select * from sales_trends
