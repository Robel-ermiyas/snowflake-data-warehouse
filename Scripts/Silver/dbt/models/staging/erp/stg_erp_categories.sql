{{
    config(
        materialized='incremental',
        unique_key='id',
        alias='erp_px_cat_g1v2',
        tags=['silver', 'staging', 'erp']
    )
}}

select 
    id,
    cat,
    subcat,
    maintenance,
    current_timestamp() as dwh_create_date
from {{ source('bronze', 'erp_px_cat_g1v2') }}
{% if is_incremental() %}
-- Simple incremental logic for category data
where current_timestamp() >= (
    select dateadd(day, -30, max(dwh_create_date)) 
    from {{ this }}
)
{% endif %}
