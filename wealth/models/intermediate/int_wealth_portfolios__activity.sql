select
  portfolio_id,
  sum(trade_count)::integer as trade_count,
  {{ platform.money('sum(fees)') }} as fees_12m,
  max(trade_month) as last_trade_month
from {{ ref('int_wealth_trades__monthly_by_portfolio') }}
group by 1
