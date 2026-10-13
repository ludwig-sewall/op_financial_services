with claims as (

    select
      insurance_customer_id,
      sum(open_claim_count) as open_claim_count,
      sum(paid_claims) as paid_claims
    from {{ ref('op_insurance', 'dim_insurance_policies') }}
    group by 1

)

select
  customers.party_key,
  customers.insurance_customer_id,
  customers.customer_status as insurance_status,
  holdings.active_policy_count,
  holdings.annual_premium,
  claims.open_claim_count,
  claims.paid_claims
from {{ ref('op_insurance', 'dim_insurance_customers') }} as customers
left join {{ ref('op_insurance', 'fct_insurance_holdings') }} as holdings
  on customers.insurance_customer_id = holdings.insurance_customer_id
left join claims
  on customers.insurance_customer_id = claims.insurance_customer_id
