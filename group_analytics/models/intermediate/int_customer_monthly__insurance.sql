select
  customers.party_key,
  claims.reported_month as activity_month,
  count(*) as claims_reported,
  sum(claims.paid_amount) as claims_paid
from {{ ref('op_insurance', 'fct_insurance_claims') }} as claims
inner join {{ ref('op_insurance', 'dim_insurance_customers') }} as customers
  on claims.insurance_customer_id = customers.insurance_customer_id
group by 1, 2
