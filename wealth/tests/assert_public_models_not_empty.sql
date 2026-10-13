{#- Templated test: add a model to the list and it is covered. -#}
{%- set public_models = [
    'dim_wealth_customers',
    'dim_wealth_portfolios',
    'fct_wealth_holdings',
    'fct_wealth_portfolio_monthly',
    'fct_wealth_risk_allocation'
] -%}

{%- for model_name in public_models %}
select
  '{{ model_name }}' as model_name,
  count(*) as row_count
from {{ ref(model_name) }}
having count(*) = 0
{% if not loop.last %}union all{% endif %}
{%- endfor %}
