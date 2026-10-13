-- Each row is one macro check; the test fails if any check is false.
with checks as (

    select 'add_months end of month' as check_name,
      {{ platform.add_months("cast('2026-01-31' as date)", 1) }} = cast('2026-02-28' as date) as passed
    union all
    select 'add_months negative',
      {{ platform.add_months("cast('2026-03-15' as date)", -12) }} = cast('2025-03-15' as date)
    union all
    select 'month_start',
      {{ platform.month_start("cast('2026-03-31' as date)") }} = cast('2026-03-01' as date)
    union all
    select 'days_between',
      {{ platform.days_between("cast('2026-03-01' as date)", "cast('2026-03-31' as date)") }} = 30
    union all
    select 'minutes_between',
      {{ platform.minutes_between("cast('2026-03-01 08:00:00' as timestamp)", "cast('2026-03-01 09:30:00' as timestamp)") }} = 90
    union all
    select 'as_of_date', {{ platform.as_of_date() }} = cast('2026-03-31' as date)

)

select check_name from checks where not passed
