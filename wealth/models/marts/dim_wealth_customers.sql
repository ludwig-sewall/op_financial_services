select
  wealth_customer_id,
  party_key,
  client_status
from {{ ref('stg_wealth__clients') }}
