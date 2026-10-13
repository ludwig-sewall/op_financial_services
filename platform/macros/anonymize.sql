{# One-way hash for identifiers and names. Snowflake uses sha2; other adapters use md5. #}
{% macro anonymize(expr) -%}
  {{ return(adapter.dispatch('anonymize', 'platform')(expr)) }}
{%- endmacro %}

{% macro default__anonymize(expr) -%}
  md5(cast({{ expr }} as varchar))
{%- endmacro %}

{% macro snowflake__anonymize(expr) -%}
  sha2(cast({{ expr }} as varchar))
{%- endmacro %}
