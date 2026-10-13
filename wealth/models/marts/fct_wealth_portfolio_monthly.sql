select
  monthly.portfolio_id || '|' || cast(monthly.trade_month as varchar) as portfolio_month_id,
  monthly.portfolio_id,
  portfolios.wealth_customer_id,
  monthly.trade_month,
  monthly.trade_count,
  monthly.buy_amount,
  monthly.sell_amount,
  {{ platform.money('monthly.buy_amount - monthly.sell_amount') }} as net_investment,
  monthly.fees
from {{ ref('int_wealth_trades__monthly_by_portfolio') }} as monthly
inner join {{ ref('dim_wealth_portfolios') }} as portfolios
  on monthly.portfolio_id = portfolios.portfolio_id
