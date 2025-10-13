{{
    config(
        materialized='incremental',
        unique_key='customer_key'
    )
}}

with silver_customers as (
    select * from {{ ref('stg_customers') }}
),

erp_customers as (
    select * from {{ ref('stg_erp_customers') }}
),

erp_locations as (
    select * from {{ ref('stg_erp_locations') }}
),

unified_customers as (
    select
        row_number() over (order by sc.cst_id) as customer_key,
        sc.cst_id as customer_id,
        sc.cst_key as customer_number,
        sc.cst_firstname as first_name,
        sc.cst_lastname as last_name,
        el.cntry as country,
        sc.cst_marital_status as marital_status,
        case 
            when sc.cst_gndr != 'n/a' then sc.cst_gndr
            else coalesce(ec.gen, 'n/a')
        end as gender,
        ec.bdate as birthdate,
        sc.cst_create_date as create_date,
        current_timestamp() as dwh_created_at
    from silver_customers sc
    left join erp_customers ec on sc.cst_key = ec.cid
    left join erp_locations el on sc.cst_key = el.cid
    {% if is_incremental() %}
    where sc.cst_create_date >= (
        select dateadd(day, -7, max(create_date)) 
        from {{ this }}
    )
    {% endif %}
)

select * from unified_customers
