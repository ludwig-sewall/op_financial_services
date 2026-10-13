select
  party_key,
  month,
  revenue,
  cost,
  {{ platform.money('revenue - cost') }} as profit
from {{ ref('int_customer_months__coverage') }}
where is_complete
