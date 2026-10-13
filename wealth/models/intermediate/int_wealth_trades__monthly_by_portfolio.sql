select
  portfolio_id,
  {{ platform.month_start('trade_date') }} as trade_month,
  count(*)::integer as trade_count,
  {{ platform.money("sum(case when trade_side = 'buy' then amount else 0 end)") }} as buy_amount,
  {{ platform.money("sum(case when trade_side = 'sell' then amount else 0 end)") }} as sell_amount,
  {{ platform.money('sum(fee)') }} as fees
from {{ ref('stg_wealth__trades') }}
group by 1, 2
