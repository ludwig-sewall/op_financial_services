-- 2024-01-01 .. 2026-12-31 is 1,096 days (2024 is a leap year).
select count(*) as day_count
from {{ ref('dim_calendar') }}
having count(*) != 1096
