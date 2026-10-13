select
  wealth_customer_id,
  count(*)::integer as portfolio_count,
  {{ platform.money('sum(market_value)') }} as assets_under_management
from {{ ref('stg_wealth__portfolios') }}
where portfolio_status = 'open'
group by 1
