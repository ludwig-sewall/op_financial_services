select
  wealth_customer_id
from {{ ref('fct_wealth_holdings') }}
where portfolio_count < 0
   or assets_under_management < 0
