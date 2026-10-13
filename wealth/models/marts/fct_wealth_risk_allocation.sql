select
  risk_profile,
  count(*)::integer as open_portfolios,
  {{ platform.money('sum(market_value)') }} as assets_under_management,
  {{ platform.safe_divide('sum(market_value)', 'sum(sum(market_value)) over ()') }} as share_of_aum
from {{ ref('dim_wealth_portfolios') }}
where portfolio_status = 'open'
group by 1
