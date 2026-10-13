select
  account_id,
  banking_customer_id,
  product_name,
  account_status,
  opened_date,
  currency,
  account_status = 'open' as is_open
from {{ ref('stg_banking__accounts') }}
