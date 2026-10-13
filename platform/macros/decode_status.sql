{# Map raw status codes to published values; unknown codes pass through lower-cased. #}
{% macro decode_status(expr, mapping) -%}
  case lower(trim({{ expr }}))
  {%- for raw, clean in mapping.items() %}
    when '{{ raw | lower }}' then '{{ clean }}'
  {%- endfor %}
    else lower(trim({{ expr }}))
  end
{%- endmacro %}
