{#- Templated test: add a model to the list and it is covered. -#}
{%- set public_models = [
    'dim_insurance_customers',
    'dim_insurance_policies',
    'fct_insurance_holdings',
    'fct_insurance_claims',
    'fct_insurance_product_loss_ratio'
] -%}

{%- for model_name in public_models %}
select
  '{{ model_name }}' as model_name,
  count(*) as row_count
from {{ ref(model_name) }}
having count(*) = 0
{% if not loop.last %}union all{% endif %}
{%- endfor %}
