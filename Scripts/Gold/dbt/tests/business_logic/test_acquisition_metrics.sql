/*
Business Logic Test: Customer Acquisition Metrics
Purpose: Validate customer acquisition calculations and cohort analysis
Business Impact: Ensures accurate marketing performance measurement
Test Frequency: Monthly aligned with marketing reporting cycles
*/

-- Test for acquisition month consistency
select
    count(*) as future_acquisition_count
from {{ ref('mart_customer_acquisition') }}
where acquisition_month > date_trunc('month', current_date())

/*
Expected Result: 0 future acquisition dates
Failure Action: Investigate customer creation date logic
*/

-- Test for reasonable first order values
select
    count(*) as extreme_aov_count
from {{ ref('mart_customer_acquisition') }}
where avg_first_order_value > 10000  -- Business threshold for extreme values

/*
Expected Result: Minimal extreme values (investigate outliers)
Failure Action: Review data quality for first orders
*/

-- Test for customer count consistency
select
    count(*) as negative_customer_count
from {{ ref('mart_customer_acquisition') }}
where new_customers < 0

/*
Expected Result: 0 negative customer counts
Failure Action: Investigate customer counting logic
*/
