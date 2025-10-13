{{
    config(
        materialized='table',
        unique_key='date_key'
    )
}}

with date_spine as (
    select
        dateadd(day, seq4(), '2000-01-01') as date
    from table(generator(rowcount => 10000))
),

enriched_dates as (
    select
        date,
        year(date) as year,
        month(date) as month,
        day(date) as day,
        dayofweek(date) as day_of_week,
        weekofyear(date) as week_of_year,
        quarter(date) as quarter,
        date_trunc('month', date) as first_day_of_month,
        last_day(date) as last_day_of_month,
        case 
            when dayofweek(date) in (1,7) then 'Weekend'
            else 'Weekday'
        end as day_type,
        case 
            when month(date) = 12 and day(date) = 25 then 'Christmas'
            when month(date) = 1 and day(date) = 1 then 'New Year'
            else 'Normal'
        end as holiday_flag
    from date_spine
)

select
    row_number() over (order by date) as date_key,
    *
from enriched_dates
where date <= current_date()
