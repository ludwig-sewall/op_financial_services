select
  customers.banking_customer_id,
  coalesce(accounts.account_count, 0)::integer as account_count,
  coalesce(loans.loan_count, 0)::integer as loan_count,
  {{ platform.money('coalesce(loans.loan_balance, 0)') }} as loan_balance
from {{ ref('dim_banking_customers') }} as customers
left join {{ ref('int_banking_accounts__open_by_customer') }} as accounts
  on customers.banking_customer_id = accounts.banking_customer_id
left join {{ ref('int_banking_loans__outstanding_by_customer') }} as loans
  on customers.banking_customer_id = loans.banking_customer_id
