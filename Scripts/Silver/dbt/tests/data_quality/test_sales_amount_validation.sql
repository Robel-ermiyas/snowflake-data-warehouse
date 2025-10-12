-- Test to validate sales amount business rules
-- Ensures sales data meets quality standards

with sales_validation as (
  select 
    sls_ord_num,
    sls_sales,
    sls_quantity,
    sls_price,
    -- Check for negative sales amounts
    case when sls_sales < 0 then 1 else 0 end as has_negative_sales,
    -- Check for quantity/price/sales consistency
    case when abs(sls_sales - (sls_quantity * sls_price)) > 0.01 then 1 else 0 end as amount_mismatch,
    -- Check for missing required fields
    case when sls_ord_num is null then 1 else 0 end as missing_order_number
  from {{ ref('stg_sales') }}
),

validation_summary as (
  select 
    count(*) as total_records,
    sum(has_negative_sales) as negative_sales_count,
    sum(amount_mismatch) as amount_mismatch_count,
    sum(missing_order_number) as missing_order_number_count
  from sales_validation
)

select 
  total_records,
  negative_sales_count,
  amount_mismatch_count,
  missing_order_number_count
from validation_summary
where negative_sales_count > 0 
   or amount_mismatch_count > 0
   or missing_order_number_count > 0
