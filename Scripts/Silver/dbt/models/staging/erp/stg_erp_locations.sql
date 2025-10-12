{{
    config(
        materialized='incremental',
        unique_key='cid',
        alias='erp_loc_a101',
        tags=['silver', 'staging', 'erp']
    )
}}

with source_data as (
    select 
        cid,
        cntry,
        current_timestamp() as dwh_create_date
    from {{ source('bronze', 'erp_loc_a101') }}
    {% if is_incremental() %}
    -- Conservative incremental approach for location data
    where current_timestamp() >= (
        select dateadd(day, -30, max(dwh_create_date)) 
        from {{ this }}
    )
    {% endif %}
),

cleaned as (
    select
        -- Clean customer ID by removing hyphens
        replace(cid, '-', '') as cid,
        
        -- Standardize country codes to full country names
        case
            when trim(cntry) = 'DE' then 'Germany'
            when trim(cntry) in ('US', 'USA') then 'United States'
            when trim(cntry) = '' or cntry is null then 'n/a'
            else trim(cntry)
        end as cntry,
        
        dwh_create_date
        
    from source_data
)

select *
from cleaned
