select
  insurance_customer_id,
  party_key,
  customer_status
from {{ ref('stg_insurance__customers') }}
