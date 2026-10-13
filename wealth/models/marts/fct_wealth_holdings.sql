select
  clients.wealth_customer_id,
  coalesce(open_portfolios.portfolio_count, 0)::integer as portfolio_count,
  {{ platform.money('coalesce(open_portfolios.assets_under_management, 0)') }} as assets_under_management
from {{ ref('dim_wealth_customers') }} as clients
left join {{ ref('int_wealth_portfolios__open_by_customer') }} as open_portfolios
  on clients.wealth_customer_id = open_portfolios.wealth_customer_id
