{#- Templated test: add a model to the list and it is covered. -#}
{%- set public_models = [
    'dim_calendar',
    'dim_calendar_months'
] -%}

{%- for model_name in public_models %}
select
  '{{ model_name }}' as model_name,
  count(*) as row_count
from {{ ref(model_name) }}
having count(*) = 0
{% if not loop.last %}union all{% endif %}
{%- endfor %}
