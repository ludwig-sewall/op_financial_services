select
  claim_id,
  policy_id,
  loss_date,
  reported_date,
  {{ platform.month_start('reported_date') }} as reported_month,
  claim_status,
  claimed_amount,
  paid_amount,
  settled_date,
  {{ platform.days_between('loss_date', 'reported_date') }} as days_to_report,
  case when settled_date is not null then {{ platform.days_between('reported_date', 'settled_date') }} end as days_to_settle,
  case when claim_status = 'open' then claimed_amount else 0 end as open_reserve
from {{ ref('stg_insurance__claims') }}
