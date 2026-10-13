select
  clients.party_key,
  monthly.trade_month as activity_month,
  sum(monthly.net_investment) as net_investment,
  sum(monthly.fees) as wealth_fees
from {{ ref('op_wealth', 'fct_wealth_portfolio_monthly') }} as monthly
inner join {{ ref('op_wealth', 'dim_wealth_customers') }} as clients
  on monthly.wealth_customer_id = clients.wealth_customer_id
group by 1, 2
