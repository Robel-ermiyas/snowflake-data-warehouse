-- Generic relationship test template
-- This can be extended for specific model relationships

{% test relationship(model, column_name, to, field) %}
  {#
    Test that values in a column exist in another table's field
    Usage: 
      - name: stg_sales
        columns:
          - name: sls_cust_id
            tests:
              - relationships:
                  to: ref('stg_customers')
                  field: cst_id
  #}
  select 
    {{ column_name }} 
  from {{ model }} 
  where {{ column_name }} is not null 
    and {{ column_name }} not in (select {{ field }} from {{ to }})
{% endtest %}
