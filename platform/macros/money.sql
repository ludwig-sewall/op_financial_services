{# Currency amounts: two decimals, fixed precision, so contracts line up across projects. #}
{% macro money(expr) -%}
  cast(round(cast({{ expr }} as numeric(18, 4)), 2) as numeric(18, 2))
{%- endmacro %}
