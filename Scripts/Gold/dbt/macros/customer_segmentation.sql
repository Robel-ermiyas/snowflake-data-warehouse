{% macro calculate_customer_segment(total_orders, total_spent) %}
  {#
  Purpose: Segment customers based on RFM (Recency, Frequency, Monetary) analysis
  Parameters:
    total_orders (integer): Customer's total number of orders
    total_spent (decimal): Customer's total lifetime spending
  Returns: Customer segment classification
  Usage: {{ calculate_customer_segment('total_orders', 'total_spent') }}
  Business Rules: 
    - VIP: 10+ orders OR $10,000+ spent
    - Regular: 5-9 orders OR $5,000-$9,999 spent
    - Occasional: 2-4 orders OR $1,000-$4,999 spent
    - New: 1 order OR <$1,000 spent
  #}
  case
    when {{ total_orders }} >= 10 or {{ total_spent }} >= 10000 then 'VIP'
    when {{ total_orders }} >= 5 or {{ total_spent }} >= 5000 then 'Regular'
    when {{ total_orders }} >= 2 or {{ total_spent }} >= 1000 then 'Occasional'
    else 'New'
  end
{% endmacro %}

{% macro calculate_value_segment(total_spent) %}
  {#
  Purpose: Classify customers based on monetary value for targeted marketing
  Parameters:
    total_spent (decimal): Customer's total lifetime spending
  Returns: Value segment classification
  Usage: {{ calculate_value_segment('total_spent') }}
  Business Rules:
    - High Value: $10,000+
    - Medium Value: $5,000 - $9,999
    - Low Value: $1,000 - $4,999
    - Minimal Value: <$1,000
  #}
  case
    when {{ total_spent }} >= 10000 then 'High Value'
    when {{ total_spent }} >= 5000 then 'Medium Value'
    when {{ total_spent }} >= 1000 then 'Low Value'
    else 'Minimal Value'
  end
{% endmacro %}

{% macro calculate_customer_lifetime(start_date, end_date = none) %}
  {#
  Purpose: Calculate customer lifetime in days for retention analysis
  Parameters:
    start_date (date): Customer acquisition date
    end_date (date): Optional end date (defaults to current date)
  Returns: Number of days as customer
  Usage: {{ calculate_customer_lifetime('first_order_date') }}
  Business Logic: Active customers show NULL end_date, churned customers have actual end_date
  #}
  datediff('day', 
    {{ start_date }}, 
    coalesce({{ end_date }}, current_date())
  )
{% endmacro %}
