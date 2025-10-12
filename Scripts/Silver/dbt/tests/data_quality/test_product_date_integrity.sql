-- Test to validate product date relationships
-- Ensures product start/end dates make logical sense

with product_date_checks as (
  select 
    prd_id,
    prd_start_dt,
    prd_end_dt,
    -- Check for invalid date ranges
    case when prd_end_dt < prd_start_dt then 1 else 0 end as invalid_date_range,
    -- Check for products with end dates in the past that shouldn't be active
    case when prd_end_dt < current_date() then 1 else 0 end as ended_product,
    -- Check for missing start dates
    case when prd_start_dt is null then 1 else 0 end as missing_start_date
  from {{ ref('stg_products') }}
),

date_issues as (
  select 
    count(*) as total_products,
    sum(invalid_date_range) as invalid_ranges,
    sum(ended_product) as ended_products,
    sum(missing_start_date) as missing_start_dates
  from product_date_checks
)

select 
  total_products,
  invalid_ranges,
  ended_products,
  missing_start_dates
from date_issues
where invalid_ranges > 0 or missing_start_dates > 0
