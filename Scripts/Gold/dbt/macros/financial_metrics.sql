{% macro calculate_growth_rate(current_value, previous_value) %}
  {#
  Purpose: Calculate percentage growth rate between two periods
  Parameters:
    current_value (decimal): Current period value
    previous_value (decimal): Previous period value for comparison
  Returns: Growth rate percentage (decimal)
  Usage: {{ calculate_growth_rate('current_sales', 'previous_sales') }}
  Business Logic: Returns NULL when previous value is zero to avoid division errors
  #}
  case
    when {{ previous_value }} = 0 then null
    else ({{ current_value }} - {{ previous_value }}) / {{ previous_value }}
  end
{% endmacro %}

{% macro calculate_aov(total_sales, order_count) %}
  {#
  Purpose: Calculate Average Order Value (AOV) for e-commerce analytics
  Parameters:
    total_sales (decimal): Total sales revenue
    order_count (integer): Total number of orders
  Returns: Average value per order
  Usage: {{ calculate_aov('total_sales', 'order_count') }}
  Business Logic: Returns NULL when no orders to prevent division by zero
  #}
  {{ total_sales }} / nullif({{ order_count }}, 0)
{% endmacro %}

{% macro calculate_conversion_rate(conversions, opportunities) %}
  {#
  Purpose: Calculate conversion rate for marketing and sales funnel analysis
  Parameters:
    conversions (integer): Number of successful conversions
    opportunities (integer): Total number of opportunities
  Returns: Conversion rate percentage (decimal)
  Usage: {{ calculate_conversion_rate('purchases', 'visitors') }}
  Business Logic: Handles zero opportunities gracefully
  #}
  {{ conversions }} / nullif({{ opportunities }}, 0)
{% endmacro %}

{% macro calculate_roi(revenue, cost) %}
  {#
  Purpose: Calculate Return on Investment (ROI) for marketing campaigns
  Parameters:
    revenue (decimal): Revenue generated from investment
    cost (decimal): Cost of investment
  Returns: ROI percentage (decimal)
  Usage: {{ calculate_roi('campaign_revenue', 'campaign_cost') }}
  Business Logic: Negative ROI indicates loss, positive indicates profit
  #}
  case
    when {{ cost }} = 0 then null
    else ({{ revenue }} - {{ cost }}) / {{ cost }}
  end
{% endmacro %}
