{# Fails for rows where the column is below zero. Nulls pass (pair with not_null if needed). #}
{% test non_negative(model, column_name) %}
select {{ column_name }}
from {{ model }}
where {{ column_name }} < 0
{% endtest %}
