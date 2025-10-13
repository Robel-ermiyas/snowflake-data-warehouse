{{
    config(
        materialized='incremental',
        unique_key='product_key'
    )
}}

with silver_products as (
    select * from {{ ref('stg_products') }}
),

erp_categories as (
    select * from {{ ref('stg_erp_categories') }}
),

enriched_products as (
    select
        row_number() over (order by sp.prd_start_dt, sp.prd_key) as product_key,
        sp.prd_id as product_id,
        sp.prd_key as product_number,
        sp.prd_nm as product_name,
        sp.cat_id as category_id,
        ec.cat as category,
        ec.subcat as subcategory,
        ec.maintenance as maintenance,
        sp.prd_cost as cost,
        sp.prd_line as product_line,
        sp.prd_start_dt as start_date,
        sp.prd_end_dt as end_date,
        current_timestamp() as dwh_created_at
    from silver_products sp
    left join erp_categories ec on sp.cat_id = ec.id
    where sp.prd_end_dt is null
    {% if is_incremental() %}
    and sp.prd_start_dt >= (
        select dateadd(day, -30, max(start_date)) 
        from {{ this }}
    )
    {% endif %}
)

select * from enriched_products
