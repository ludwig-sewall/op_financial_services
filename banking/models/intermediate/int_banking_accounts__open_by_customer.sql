select
  banking_customer_id,
  count(*)::integer as account_count
from {{ ref('stg_banking__accounts') }}
where account_status = 'open'
group by 1
