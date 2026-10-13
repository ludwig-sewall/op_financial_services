select
  portfolios.portfolio_id,
  portfolios.wealth_customer_id,
  portfolios.portfolio_name,
  portfolios.portfolio_status,
  portfolios.risk_profile,
  portfolios.opened_date,
  portfolios.market_value,
  coalesce(activity.trade_count, 0)::integer as trade_count_12m,
  {{ platform.money('coalesce(activity.fees_12m, 0)') }} as fees_12m,
  {{ platform.safe_divide('activity.fees_12m', 'portfolios.market_value', 6) }} as fee_yield
from {{ ref('stg_wealth__portfolios') }} as portfolios
left join {{ ref('int_wealth_portfolios__activity') }} as activity
  on portfolios.portfolio_id = activity.portfolio_id
