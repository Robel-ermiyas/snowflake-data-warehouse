-- Test to ensure customer IDs are unique in the silver layer
-- This test validates data quality after transformations

with customer_counts as (
  select 
    cst_id,
    count(*) as record_count
  from {{ ref('stg_customers') }}
  group by cst_id
),

duplicate_customers as (
  select 
    cst_id,
    record_count
  from customer_counts
  where record_count > 1
)

select 
  count(*) as duplicate_count
from duplicate_customers
