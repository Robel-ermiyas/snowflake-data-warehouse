{{
    config(
        materialized='incremental',
        unique_key='prd_id',
        alias='crm_prd_info',
        tags=['silver', 'staging', 'crm']
    )
}}

with source_data as (
    select 
        prd_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt,
        current_timestamp() as dwh_create_date
    from {{ source('bronze', 'crm_prd_info') }}
    {% if is_incremental() %}
    -- Incremental logic: process recent product updates
    where prd_start_dt >= (
        select dateadd(day, -30, max(prd_start_dt)) 
        from {{ this }}
        where prd_start_dt is not null
    )
    {% endif %}
),

transformed as (
    select 
        prd_id,
        
        -- Extract category ID from composite product key (first 5 characters)
        replace(substring(prd_key, 1, 5), '-', '_') as cat_id,
        
        -- Extract clean product key (remaining characters after position 7)
        substring(prd_key, 7, len(prd_key)) as prd_key,
        
        prd_nm,
        
        -- Handle null costs by defaulting to 0
        coalesce(prd_cost, 0) as prd_cost,
        
        -- Map product line codes to descriptive values
        case 
            when upper(trim(prd_line)) = 'M' then 'Mountain'
            when upper(trim(prd_line)) = 'R' then 'Road'
            when upper(trim(prd_line)) = 'S' then 'Other Sales'
            when upper(trim(prd_line)) = 'T' then 'Touring'
            else 'n/a'
        end as prd_line,
        
        -- Ensure date formatting
        cast(prd_start_dt as date) as prd_start_dt,
        
        -- Calculate end date as day before next product version starts
        cast(
            lead(prd_start_dt) over (
                partition by prd_key 
                order by prd_start_dt
            ) - 1 
            as date
        ) as prd_end_dt,
        
        dwh_create_date
        
    from source_data
)

select *
from transformed
