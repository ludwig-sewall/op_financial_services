select
  party_key,
  month,
  profit,
  {{ platform.money('sum(profit) over (partition by party_key order by month rows between 2 preceding and current row)') }} as trailing_3m_profit,
  {{ platform.money('sum(profit) over (partition by party_key order by month rows between 11 preceding and current row)') }} as trailing_12m_profit
from {{ ref('fct_customer_profitability_monthly') }}
