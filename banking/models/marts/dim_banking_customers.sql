select
  customers.banking_customer_id,
  customers.party_key,
  customers.customer_status,
  customers.customer_type,
  customers.customer_since,
  exits.exit_date,
  exits.exit_reason
from {{ ref('stg_banking__customers') }} as customers
left join {{ ref('stg_banking__customer_exits') }} as exits
  on customers.banking_customer_id = exits.banking_customer_id
