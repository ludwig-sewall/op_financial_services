select
  claims.claim_id,
  claims.policy_id,
  policies.insurance_customer_id,
  policies.product_name,
  claims.loss_date,
  claims.reported_date,
  claims.reported_month,
  claims.claim_status,
  claims.claimed_amount,
  claims.paid_amount,
  claims.open_reserve,
  claims.days_to_report,
  claims.days_to_settle
from {{ ref('int_insurance_claims__lifecycle') }} as claims
inner join {{ ref('stg_insurance__policies') }} as policies
  on claims.policy_id = policies.policy_id
