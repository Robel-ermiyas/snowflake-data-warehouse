{{
    config(
        materialized='view'
    )
}}

/*
Unified Customers Intermediate Model
Purpose: Create single customer view by combining CRM and ERP data sources
Business Use: Customer data unification, single source of truth for customer attributes
Refresh: View-based for real-time customer data access
*/

with silver_customers as (
    select * from {{ ref('stg_customers') }}
),

erp_customers as (
    select * from {{ ref('stg_erp_customers') }}
),

erp_locations as (
    select * from {{ ref('stg_erp_locations') }}
)

-- Unify customer data from multiple source systems
select
    sc.cst_id as customer_id,
    sc.cst_key as customer_number,
    sc.cst_firstname as first_name,
    sc.cst_lastname as last_name,
    el.cntry as country,
    sc.cst_marital_status as marital_status,
    -- Gender unification: prefer CRM data, fallback to ERP
    case 
        when sc.cst_gndr != 'n/a' then sc.cst_gndr
        else coalesce(ec.gen, 'n/a')
    end as gender,
    ec.bdate as birthdate,
    sc.cst_create_date as create_date
from silver_customers sc
left join erp_customers ec on sc.cst_key = ec.cid
left join erp_locations el on sc.cst_key = el.cid
