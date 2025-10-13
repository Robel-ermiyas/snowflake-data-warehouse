/*
Business Logic Test: Sales Metrics Validation
Purpose: Validate business calculations and metric consistency
Business Impact: Ensures accurate financial and performance reporting
Test Frequency: Weekly to validate business rules
*/

-- Test for negative sales amounts (invalid business scenario)
select
    count(*) as negative_sales_count
from {{ ref('fct_sales') }}
where sales_amount < 0

/*
Expected Result: 0 negative sales amounts
Failure Action: Investigate data quality in source systems
*/

-- Test for quantity-price consistency
select
    count(*) as amount_mismatch_count
from {{ ref('fct_sales') }}
where abs(sales_amount - (quantity * price)) > 0.01  -- Allow for rounding differences

/*
Expected Result: 0 amount mismatches
Failure Action: Investigate sales amount calculation logic
*/

-- Test for valid customer segments in marketing mart
select
    count(*) as invalid_segment_count
from {{ ref('mart_customer_segmentation') }}
where customer_segment not in ('VIP', 'Regular', 'Occasional', 'New')
   or value_segment not in ('High Value', 'Medium Value', 'Low Value', 'Minimal Value')

/*
Expected Result: 0 invalid segments
Failure Action: Review customer segmentation business rules
*/
