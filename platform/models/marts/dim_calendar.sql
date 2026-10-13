with days as (

    {{ platform.date_spine('2024-01-01', '2026-12-31') }}

)

select
  date_day,
  {{ platform.month_start('date_day') }} as month_start,
  cast(extract(year from date_day) as integer) as calendar_year,
  cast(extract(quarter from date_day) as integer) as calendar_quarter,
  cast(extract(month from date_day) as integer) as calendar_month,
  date_day <= {{ platform.as_of_date() }} as is_reported,
  date_day = {{ platform.as_of_date() }} as is_as_of_date
from days
