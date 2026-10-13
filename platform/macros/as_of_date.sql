{# Reporting date shared by every project. Override with --vars '{as_of_date: 2026-06-30}'. #}
{% macro as_of_date() -%}
  cast('{{ var("as_of_date", "2026-03-31") }}' as date)
{%- endmacro %}
