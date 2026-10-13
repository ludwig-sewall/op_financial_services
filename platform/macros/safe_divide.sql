{# Ratio that returns null instead of failing when the denominator is zero or null. #}
{% macro safe_divide(numerator, denominator, scale=4) -%}
  cast(
    case
      when {{ denominator }} is null or {{ denominator }} = 0 then null
      else cast({{ numerator }} as numeric(38, 10)) / cast({{ denominator }} as numeric(38, 10))
    end
  as numeric(18, {{ scale }}))
{%- endmacro %}
