{{
    config(
        materialized='incremental',
        unique_key='cid',
        alias='erp_cust_az12',
        tags=['silver', 'staging', 'erp']
    )
}}

with source_data as (
    select 
        cid,
        bdate,
        gen,
        current_timestamp() as dwh_create_date
    from {{ source('bronze', 'erp_cust_az12') }}
    {% if is_incremental() %}
    -- Conservative incremental approach for customer data
    where current_timestamp() >= (
        select dateadd(day, -7, max(dwh_create_date)) 
        from {{ this }}
    )
    {% endif %}
),

cleaned as (
    select
        -- Clean customer ID by removing 'NAS' prefix if present
        case
            when cid like 'NAS%' then substring(cid, 4, len(cid))
            else cid
        end as cid, 
        
        -- Validate birth dates (cannot be in future)
        case
            when bdate > current_date() then null
            else bdate
        end as bdate,
        
        -- Standardize gender values
        case
            when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
            when upper(trim(gen)) in ('M', 'MALE') then 'Male'
            else 'n/a'
        end as gen,
        
        dwh_create_date
        
    from source_data
)

select *
from cleaned
