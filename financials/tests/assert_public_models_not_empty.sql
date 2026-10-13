{#- Templated test: add a model to the list and it is covered. -#}
{%- set public_models = [
    'fct_customer_profitability_monthly',
    'fct_customer_profitability_trailing',
    'fct_customer_profitability_summary',
    'fct_profitability_data_gaps',
    'fct_customer_revenue_forecast'
] -%}

{%- for model_name in public_models %}
select
  '{{ model_name }}' as model_name,
  count(*) as row_count
from {{ ref(model_name) }}
having count(*) = 0
{% if not loop.last %}union all{% endif %}
{%- endfor %}
