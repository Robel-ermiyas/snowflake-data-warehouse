{% macro incremental_strategy() %}
  {{
    return(adapter.dispatch('incremental_strategy', 'silver_layer')())
  }}
{% endmacro %}

{% macro default__incremental_strategy() %}
  {# Default incremental strategy for databases that don't have a specific implementation #}
  {{ return('delete+insert') }}
{% endmacro %}

{% macro snowflake__incremental_strategy() %}
  {# Snowflake supports merge strategy for incremental models #}
  {{ return('merge') }}
{% endmacro %}

{% macro get_incremental_where_clause(column_name = 'loaded_at', lookback_days = 7) %}
  {#
    Macro to generate consistent incremental WHERE clauses across models
    Usage: {{ get_incremental_where_clause('created_date', 30) }}
  #}
  {% if is_incremental() %}
    where {{ column_name }} >= (
      select dateadd(day, -{{ lookback_days }}, coalesce(max({{ column_name }}), '1900-01-01'::timestamp)) 
      from {{ this }}
      where {{ column_name }} is not null
    )
  {% endif %}
{% endmacro %}

{% macro incremental_filter(column_name, default_lookback_days = 7) %}
  {#
    Simplified macro for incremental filtering
    Usage: {{ incremental_filter('order_date') }}
  #}
  {% if is_incremental() %}
    and {{ column_name }} >= dateadd(day, -{{ default_lookback_days }}, current_date)
  {% endif %}
{% endmacro %}

{% macro handle_schema_changes() %}
  {#
    Macro to handle schema changes in incremental models
    This provides better control over how dbt handles new columns
  #}
  {{ 
    config(
      on_schema_change='append_new_columns'
    )
  }}
{% endmacro %}
