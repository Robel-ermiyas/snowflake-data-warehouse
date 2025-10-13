{{
    config(
        materialized='incremental',
        unique_key='order_number'
    )
}}

with silver_sales as (
    select * from {{ ref('stg_sales') }}
),

dim_products as (
    select * from {{ ref('dim_products') }}
),

dim_customers as (
    select * from {{ ref('dim_customers') }}
),

fact_sales as (
    select
        ss.sls_ord_num as order_number,
        dp.product_key,
        dc.customer_key,
        ss.sls_order_dt as order_date,
        ss.sls_ship_dt as shipping_date,
        ss.sls_due_dt as due_date,
        ss.sls_sales as sales_amount,
        ss.sls_quantity as quantity,
        ss.sls_price as price,
        current_timestamp() as dwh_created_at
    from silver_sales ss
    left join dim_products dp on ss.sls_prd_key = dp.product_number
    left join dim_customers dc on ss.sls_cust_id = dc.customer_id
    {% if is_incremental() %}
    where ss.sls_order_dt >= (
        select dateadd(day, -7, max(order_date)) 
        from {{ this }}
    )
    {% endif %}
)

select * from fact_sales
