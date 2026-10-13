select
  banking_customer_id,
  count(*)::integer as loan_count,
  {{ platform.money('sum(balance)') }} as loan_balance
from {{ ref('stg_banking__loans') }}
where loan_status = 'outstanding'
group by 1
