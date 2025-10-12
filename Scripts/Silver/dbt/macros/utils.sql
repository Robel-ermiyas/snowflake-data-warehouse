{% macro standardize_gender(gender_column) %}
  {#
    Standardize gender values across different source systems
    Usage: {{ standardize_gender('gender') }}
  #}
  case
    when upper(trim({{ gender_column }})) in ('M', 'MALE', '1') then 'Male'
    when upper(trim({{ gender_column }})) in ('F', 'FEMALE', '2') then 'Female'
    else 'Unknown'
  end
{% endmacro %}

{% macro clean_string(column_name) %}
  {#
    Clean and trim string columns, handle nulls
    Usage: {{ clean_string('first_name') }}
  #}
  coalesce(trim({{ column_name }}), '')
{% endmacro %}

{% macro handle_null_number(column_name, default_value = 0) %}
  {#
    Handle null values in numeric columns
    Usage: {{ handle_null_number('sales_amount', 0) }}
  #}
  coalesce({{ column_name }}, {{ default_value }})
{% endmacro %}

{% macro convert_int_to_date(date_column, format = 'YYYYMMDD') %}
  {#
    Convert integer dates (YYYYMMDD format) to proper date type
    Usage: {{ convert_int_to_date('order_date_int') }}
  #}
  case 
    when {{ date_column }} = 0 or length({{ date_column }}::varchar) != 8 then null
    else to_date({{ date_column }}::varchar, '{{ format }}')
  end
{% endmacro %}

{% macro validate_date_not_future(date_column) %}
  {#
    Validate that dates are not in the future, set to null if they are
    Usage: {{ validate_date_not_future('birth_date') }}
  #}
  case
    when {{ date_column }} > current_date() then null
    else {{ date_column }}
  end
{% endmacro %}

{% macro extract_date_part(column_name, date_part = 'year') %}
  {#
    Extract date parts from date columns
    Usage: {{ extract_date_part('order_date', 'month') }}
  #}
  date_part('{{ date_part }}', {{ column_name }})
{% endmacro %}

{% macro generate_surrogate_key(fields) %}
  {#
    Generate consistent surrogate keys across dimensions
    Usage: {{ generate_surrogate_key(['customer_id', 'order_date']) }}
  #}
  {{ dbt_utils.generate_surrogate_key(fields) }}
{% endmacro %}

{% macro deduplicate_records(unique_key, order_by = 'loaded_at desc') %}
  {#
    Macro to deduplicate records keeping the most recent
    Usage: 
      {{ deduplicate_records('customer_id', 'created_date desc') }}
  #}
  row_number() over (
    partition by {{ unique_key }} 
    order by {{ order_by }}
  ) as duplicate_rank
{% endmacro %}

{% macro business_days_between(start_date, end_date) %}
  {#
    Calculate business days between two dates (Mon-Fri)
    Usage: {{ business_days_between('order_date', 'ship_date') }}
  #}
  datediff('day', {{ start_date }}, {{ end_date }}) - 
  floor(datediff('week', {{ start_date }}, {{ end_date }})) * 2 -
  case 
    when dayofweek({{ start_date }}) = 0 then 1 
    when dayofweek({{ start_date }}) = 6 then 1 
    else 0 
  end +
  case 
    when dayofweek({{ end_date }}) = 0 then 1 
    when dayofweek({{ end_date }}) = 6 then 1 
    else 0 
  end
{% endmacro %}

{% macro log_model_start(model_name) %}
  {#
    Log model execution start for monitoring
    Usage: {{ log_model_start(this.name) }}
  #}
  {{ log("Starting model: " ~ model_name, info=true) }}
{% endmacro %}

{% macro log_model_end(model_name, row_count) %}
  {#
    Log model execution completion with row count
    Usage: {{ log_model_end(this.name, results.rows_affected) }}
  #}
  {{ log("Completed model: " ~ model_name ~ " - Rows processed: " ~ row_count, info=true) }}
{% endmacro %}
