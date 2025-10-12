{{
    config(
        materialized='incremental',
        unique_key='cst_id',
        alias='crm_cust_info',
        tags=['silver', 'staging', 'crm']
    )
}}

with source_data as (
    select 
        cst_id,
        cst_key,
        cst_first_name as cst_firstname,  -- Map to silver column name
        cst_last_name as cst_lastname,    -- Map to silver column name  
        cst_marital_status,
        cst_gndr,
        cst_create_date,
        current_timestamp() as dwh_create_date
    from {{ source('bronze', 'crm_cust_info') }}
    {% if is_incremental() %}
    -- Incremental logic: process records from last 7 days to catch updates
    where cst_create_date >= (
        select dateadd(day, -7, max(cst_create_date)) 
        from {{ this }}
        where cst_create_date is not null
    )
    {% endif %}
),

-- Deduplicate customers, keeping most recent record per customer
deduplicated as (
    select *,
        row_number() over (
            partition by cst_id 
            order by cst_create_date desc
        ) as duplicate_rank
    from source_data
    where cst_id is not null  -- Ensure primary key exists
),

cleaned as (
    select 
        cst_id,
        cst_key,
        -- Clean and standardize name fields
        trim(cst_firstname) as cst_firstname,
        trim(cst_lastname) as cst_lastname,
        
        -- Standardize marital status codes to readable values
        case 
            when upper(trim(cst_marital_status)) = 'S' then 'Single'
            when upper(trim(cst_marital_status)) = 'M' then 'Married'
            else 'n/a'
        end as cst_marital_status,
        
        -- Standardize gender codes to readable values  
        case 
            when upper(trim(cst_gndr)) = 'F' then 'Female'
            when upper(trim(cst_gndr)) = 'M' then 'Male'
            else 'n/a'
        end as cst_gndr,
        
        cst_create_date,
        dwh_create_date
        
    from deduplicated
    where duplicate_rank = 1  -- Keep only the most recent record per customer
)

select *
from cleaned
