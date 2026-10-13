select
  account_id,
  {{ platform.month_start('transaction_date') }} as transaction_month,
  count(*)::integer as transaction_count,
  {{ platform.money("sum(case when transaction_type = 'credit' then amount else 0 end)") }} as inflow,
  {{ platform.money("sum(case when transaction_type = 'debit' then amount else 0 end)") }} as outflow
from {{ ref('stg_banking__transactions') }}
group by 1, 2
