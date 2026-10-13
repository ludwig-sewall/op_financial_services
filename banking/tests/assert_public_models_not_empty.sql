{#- Templated test: add a model to the list and it is covered. -#}
{%- set public_models = [
    'dim_banking_customers',
    'dim_banking_accounts',
    'fct_banking_holdings',
    'fct_banking_account_monthly',
    'fct_banking_loan_performance'
] -%}

{%- for model_name in public_models %}
select
  '{{ model_name }}' as model_name,
  count(*) as row_count
from {{ ref(model_name) }}
having count(*) = 0
{% if not loop.last %}union all{% endif %}
{%- endfor %}
