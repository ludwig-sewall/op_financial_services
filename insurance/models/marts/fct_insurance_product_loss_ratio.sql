select
  product_name,
  count(*)::integer as policy_count,
  sum(case when policy_status = 'active' then 1 else 0 end)::integer as active_policy_count,
  {{ platform.money('sum(annual_premium)') }} as written_premium,
  {{ platform.money('sum(incurred_claims)') }} as incurred_claims,
  {{ platform.safe_divide('sum(incurred_claims)', 'sum(annual_premium)') }} as loss_ratio
from {{ ref('dim_insurance_policies') }}
group by 1
