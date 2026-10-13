select
  monthly.account_id || '|' || cast(monthly.transaction_month as varchar) as account_month_id,
  monthly.account_id,
  accounts.banking_customer_id,
  accounts.product_name,
  monthly.transaction_month,
  monthly.transaction_count,
  monthly.inflow,
  monthly.outflow,
  {{ platform.money('monthly.inflow - monthly.outflow') }} as net_flow
from {{ ref('int_banking_transactions__monthly_by_account') }} as monthly
inner join {{ ref('dim_banking_accounts') }} as accounts
  on monthly.account_id = accounts.account_id
