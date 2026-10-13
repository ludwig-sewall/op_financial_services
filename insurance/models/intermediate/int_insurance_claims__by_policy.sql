select
  policy_id,
  count(*)::integer as claim_count,
  sum(case when claim_status = 'open' then 1 else 0 end)::integer as open_claim_count,
  {{ platform.money('sum(paid_amount)') }} as paid_claims,
  {{ platform.money('sum(paid_amount + open_reserve)') }} as incurred_claims
from {{ ref('int_insurance_claims__lifecycle') }}
group by 1
