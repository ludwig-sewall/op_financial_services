{#
  Reconciliation: the column total on this model must match a column total on another model
  (same project or another project via cross-project ref). Optional filters on either side.

    data_tests:
      - platform.sums_match:
          arguments:
            compare_model: ref('fct_billing_invoices')
            compare_column: amount_due
#}
{% test sums_match(model, column_name, compare_model, compare_column, where_clause=none, compare_where=none, tolerance=0.01) %}
with model_total as (
  select coalesce(sum({{ column_name }}), 0) as total
  from {{ model }}
  {% if where_clause %}where {{ where_clause }}{% endif %}
),

compare_total as (
  select coalesce(sum({{ compare_column }}), 0) as total
  from {{ compare_model }}
  {% if compare_where %}where {{ compare_where }}{% endif %}
)

select
  model_total.total as model_total,
  compare_total.total as compare_total
from model_total
cross join compare_total
where abs(model_total.total - compare_total.total) > {{ tolerance }}
{% endtest %}
