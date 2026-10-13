select
  banking_customer_id,
  account_count,
  loan_count,
  loan_balance
from {{ ref('fct_banking_holdings') }}
where account_count < 0
   or loan_count < 0
