select
  party_key,
  count(*)::integer as profit_months,
  {{ platform.money('sum(revenue)') }} as total_revenue,
  {{ platform.money('sum(cost)') }} as total_cost,
  {{ platform.money('sum(profit)') }} as total_profit,
  {{ platform.safe_divide('sum(profit)', 'sum(revenue)') }} as profit_margin,
  case
    when sum(profit) < 0 then 'loss_making'
    when sum(profit) < 10000 then 'low'
    when sum(profit) < 50000 then 'medium'
    else 'high'
  end as profit_band
from {{ ref('fct_customer_profitability_monthly') }}
group by 1
