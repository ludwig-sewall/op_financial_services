with fees as (

    select
      wealth_customer_id,
      sum(fees_12m) as wealth_fees_12m
    from {{ ref('op_wealth', 'dim_wealth_portfolios') }}
    group by 1

)

select
  clients.party_key,
  clients.wealth_customer_id,
  clients.client_status as wealth_status,
  holdings.portfolio_count,
  holdings.assets_under_management,
  fees.wealth_fees_12m
from {{ ref('op_wealth', 'dim_wealth_customers') }} as clients
left join {{ ref('op_wealth', 'fct_wealth_holdings') }} as holdings
  on clients.wealth_customer_id = holdings.wealth_customer_id
left join fees
  on clients.wealth_customer_id = fees.wealth_customer_id
