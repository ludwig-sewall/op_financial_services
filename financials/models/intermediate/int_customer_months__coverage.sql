select
  coalesce(revenue.party_key, cost.party_key) as party_key,
  coalesce(revenue.revenue_month, cost.cost_month) as month,
  revenue.revenue,
  cost.cost,
  coalesce(revenue.unpriced_postings, 0) as unpriced_postings,
  revenue.revenue is not null and cost.cost is not null as is_complete
from {{ ref('int_revenue_transactions__monthly') }} as revenue
full outer join {{ ref('int_allocated_costs__monthly') }} as cost
  on revenue.party_key = cost.party_key
 and revenue.revenue_month = cost.cost_month
