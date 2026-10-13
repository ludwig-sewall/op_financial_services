select
  party_key,
  revenue_month,
  {{ platform.money('sum(amount)') }} as revenue,
  sum(case when amount is null then 1 else 0 end)::integer as unpriced_postings
from {{ ref('stg_financials__revenue_transactions') }}
group by 1, 2
