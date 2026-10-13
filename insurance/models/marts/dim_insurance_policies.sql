select
  policies.policy_id,
  policies.insurance_customer_id,
  policies.product_name,
  policies.policy_status,
  policies.start_date,
  policies.annual_premium,
  policies.sum_insured,
  coalesce(claims.claim_count, 0)::integer as claim_count,
  coalesce(claims.open_claim_count, 0)::integer as open_claim_count,
  {{ platform.money('coalesce(claims.paid_claims, 0)') }} as paid_claims,
  {{ platform.money('coalesce(claims.incurred_claims, 0)') }} as incurred_claims,
  {{ platform.safe_divide('claims.incurred_claims', 'policies.annual_premium') }} as loss_ratio
from {{ ref('stg_insurance__policies') }} as policies
left join {{ ref('int_insurance_claims__by_policy') }} as claims
  on policies.policy_id = claims.policy_id
