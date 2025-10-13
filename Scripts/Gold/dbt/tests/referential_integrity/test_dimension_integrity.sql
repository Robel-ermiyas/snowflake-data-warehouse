/*
Dimension Integrity Test: Unique Key Validation
Purpose: Ensure dimension tables maintain unique primary keys
Business Impact: Prevents duplicate records in analytical models
Test Frequency: Daily as part of data quality checks
*/

-- Test for duplicate customer keys
select
    customer_key,
    count(*) as duplicate_count
from {{ ref('dim_customers') }}
group by customer_key
having count(*) > 1

/*
Expected Result: 0 duplicate keys
Failure Action: Investigate customer deduplication logic
*/

-- Test for duplicate product keys  
select
    product_key,
    count(*) as duplicate_count
from {{ ref('dim_products') }}
group by product_key
having count(*) > 1

/*
Expected Result: 0 duplicate keys
Failure Action: Investigate product versioning logic
*/

-- Test for date dimension coverage
select
    min(date) as earliest_date,
    max(date) as latest_date
from {{ ref('dim_dates') }}

/*
Expected Result: Date range covers all fact table dates
Failure Action: Extend date dimension range if needed
*/
