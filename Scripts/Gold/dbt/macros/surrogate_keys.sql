{% macro generate_surrogate_key(field_list) %}
  {#
  Purpose: Generate consistent SHA-based surrogate keys for dimension tables
  Parameters:
    field_list (list): List of fields to use for key generation
  Returns: SHA-256 hash of concatenated field values
  Usage: {{ generate_surrogate_key(['customer_id', 'create_date']) }}
  Business Value: Ensures consistent primary keys across the data warehouse
  #}
  {{ return(dbt_utils.generate_surrogate_key(field_list)) }}
{% endmacro %}

{% macro generate_customer_key(customer_id, create_date) %}
  {#
  Purpose: Generate customer-specific surrogate key with business logic
  Parameters:
    customer_id (string): Natural key from source system
    create_date (date): Customer creation date for versioning
  Returns: Consistent customer key for dimension table
  Usage: {{ generate_customer_key('cst_id', 'cst_create_date') }}
  Business Logic: Combines customer ID with creation date for SCD Type 2 support
  #}
  {{ generate_surrogate_key(['customer_id', 'create_date']) }}
{% endmacro %}

{% macro generate_product_key(product_id, product_key, start_date) %}
  {#
  Purpose: Generate product surrogate key supporting slowly changing dimensions
  Parameters:
    product_id (string): Product identifier
    product_key (string): Business product key
    start_date (date): Product effective start date
  Returns: Unique product key for dimension table
  Usage: {{ generate_product_key('prd_id', 'prd_key', 'prd_start_dt') }}
  Business Logic: Supports product versioning and historical tracking
  #}
  {{ generate_surrogate_key(['product_id', 'product_key', 'start_date']) }}
{% endmacro %}
