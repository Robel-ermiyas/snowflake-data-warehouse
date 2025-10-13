/*
Referential Integrity Test: Fact Sales Foreign Keys
Purpose: Ensure all fact table records have valid dimension references
Business Impact: Prevents orphaned records in sales reporting
Test Frequency: Daily as part of data quality checks
*/

-- Test for orphaned product keys in fact sales
select 
    count(*) as orphaned_product_records
from {{ ref('fct_sales') }} fs
left join {{ ref('dim_products') }} dp on fs.product_key = dp.product_key
where dp.product_key is null
and fs.product_key is not null

/*
Expected Result: 0 orphaned records
Failure Action: Investigate missing product dimension records
*/

-- Test for orphaned customer keys in fact sales
select 
    count(*) as orphaned_customer_records
from {{ ref('fct_sales') }} fs
left join {{ ref('dim_customers') }} dc on fs.customer_key = dc.customer_key
where dc.customer_key is null
and fs.customer_key is not null

/*
Expected Result: 0 orphaned records  
Failure Action: Investigate missing customer dimension records
*/

-- Test for future-dated sales orders (data quality check)
select
    count(*) as future_dated_orders
from {{ ref('fct_sales') }}
where order_date > current_date()

/*
Expected Result: 0 future-dated orders
Failure Action: Investigate data ingestion timing issues
*/
