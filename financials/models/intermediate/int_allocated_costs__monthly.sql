select
  party_key,
  cost_month,
  {{ platform.money('sum(cost)') }} as cost
from {{ ref('stg_financials__allocated_costs') }}
group by 1, 2
