{# Fails for dates after the shared reporting date. #}
{% test not_after_as_of(model, column_name) %}
select {{ column_name }}
from {{ model }}
where cast({{ column_name }} as date) > {{ platform.as_of_date() }}
{% endtest %}
