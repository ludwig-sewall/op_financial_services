select
  month_start,
  {{ platform.add_months('month_start', 1) }} as next_month_start,
  min(calendar_year) as calendar_year,
  min(calendar_quarter) as calendar_quarter,
  count(*)::integer as days_in_month,
  max(case when is_reported then 1 else 0 end) = 1 as is_reported
from {{ ref('dim_calendar') }}
group by 1
