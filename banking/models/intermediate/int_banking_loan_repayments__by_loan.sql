with due as (

    select *
    from {{ ref('stg_banking__loan_repayments') }}
    where due_date <= {{ platform.as_of_date() }}

)

select
  loan_id,
  count(*)::integer as instalments_due,
  sum(case when paid_date is null then 1 else 0 end)::integer as instalments_missed,
  sum(case when paid_date > due_date then 1 else 0 end)::integer as instalments_late,
  {{ platform.money('sum(amount_due - amount_paid)') }} as arrears_amount,
  max(case when paid_date is null then {{ platform.days_between('due_date', platform.as_of_date()) }} else 0 end)::integer as days_past_due
from due
group by 1
