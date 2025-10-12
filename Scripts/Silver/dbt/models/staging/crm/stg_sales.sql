{{
    config(
        materialized='incremental',
        unique_key='sls_ord_num',
        alias='crm_sales_details',
        tags=['silver', 'staging', 'crm']
    )
}}

with source_data as (
    select 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price,
        current_timestamp() as dwh_create_date
    from {{ source('bronze', 'crm_sales_details') }}
    {% if is_incremental() %}
    -- Incremental logic: process sales from last 30 days
    where try_to_date(sls_order_dt::varchar, 'YYYYMMDD') >= dateadd(day, -30, current_date)
    {% endif %}
),

cleaned as (
    select 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        
        -- Convert integer dates (YYYYMMDD format) to proper date type
        case 
            when sls_order_dt = 0 or length(sls_order_dt::varchar) != 8 then null
            else to_date(sls_order_dt::varchar, 'YYYYMMDD')
        end as sls_order_dt,
        
        case 
            when sls_ship_dt = 0 or length(sls_ship_dt::varchar) != 8 then null
            else to_date(sls_ship_dt::varchar, 'YYYYMMDD')
        end as sls_ship_dt,
        
        case 
            when sls_due_dt = 0 or length(sls_due_dt::varchar) != 8 then null
            else to_date(sls_due_dt::varchar, 'YYYYMMDD')
        end as sls_due_dt,
        
        -- Validate and recalculate sales amount if needed
        case 
            when sls_sales is null or sls_sales <= 0 
                or sls_sales != sls_quantity * abs(sls_price) 
                then sls_quantity * abs(sls_price)
            else sls_sales
        end as sls_sales,
        
        sls_quantity,
        
        -- Derive price if original value is invalid
        case 
            when sls_price is null or sls_price <= 0 
                then sls_sales / nullif(sls_quantity, 0)
            else sls_price
        end as sls_price,
        
        dwh_create_date
        
    from source_data
)

select *
from cleaned
