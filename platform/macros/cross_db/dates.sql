{# Date helpers that compile on Snowflake and DuckDB (local testing). Differences return integer. #}

{% macro month_start(expr) -%}
  cast(date_trunc('month', {{ expr }}) as date)
{%- endmacro %}


{% macro add_months(expr, months) -%}
  {{ return(adapter.dispatch('add_months', 'platform')(expr, months)) }}
{%- endmacro %}

{% macro default__add_months(expr, months) -%}
  cast(dateadd(month, {{ months }}, {{ expr }}) as date)
{%- endmacro %}

{% macro duckdb__add_months(expr, months) -%}
  cast({{ expr }} + to_months(cast({{ months }} as integer)) as date)
{%- endmacro %}


{% macro days_between(start_expr, end_expr) -%}
  {{ return(adapter.dispatch('days_between', 'platform')(start_expr, end_expr)) }}
{%- endmacro %}

{% macro default__days_between(start_expr, end_expr) -%}
  cast(datediff(day, {{ start_expr }}, {{ end_expr }}) as integer)
{%- endmacro %}

{% macro duckdb__days_between(start_expr, end_expr) -%}
  cast(date_diff('day', cast({{ start_expr }} as date), cast({{ end_expr }} as date)) as integer)
{%- endmacro %}


{% macro minutes_between(start_expr, end_expr) -%}
  {{ return(adapter.dispatch('minutes_between', 'platform')(start_expr, end_expr)) }}
{%- endmacro %}

{% macro default__minutes_between(start_expr, end_expr) -%}
  cast(datediff(minute, {{ start_expr }}, {{ end_expr }}) as integer)
{%- endmacro %}

{% macro duckdb__minutes_between(start_expr, end_expr) -%}
  cast(date_diff('minute', cast({{ start_expr }} as timestamp), cast({{ end_expr }} as timestamp)) as integer)
{%- endmacro %}


{# One row per day between two dates (inclusive), column date_day. #}
{% macro date_spine(start_date, end_date) -%}
  {{ return(adapter.dispatch('date_spine', 'platform')(start_date, end_date)) }}
{%- endmacro %}

{% macro default__date_spine(start_date, end_date) -%}
  select date_day
  from (
    select cast(dateadd(day, row_number() over (order by seq4()) - 1, cast('{{ start_date }}' as date)) as date) as date_day
    from table(generator(rowcount => 4000))
  ) as days
  where date_day <= cast('{{ end_date }}' as date)
{%- endmacro %}

{% macro duckdb__date_spine(start_date, end_date) -%}
  select cast(range as date) as date_day
  from range(cast('{{ start_date }}' as date), cast('{{ end_date }}' as date) + interval 1 day, interval 1 day)
{%- endmacro %}
