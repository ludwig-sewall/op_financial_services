with banking as (
  select * from {{ ref('int_customer_360__banking') }}
),

insurance as (
  select * from {{ ref('int_customer_360__insurance') }}
),

wealth as (
  select * from {{ ref('int_customer_360__wealth') }}
),

financials as (
  select * from {{ ref('int_customer_360__financials') }}
),

parties as (
  select party_key from banking
  union
  select party_key from insurance
  union
  select party_key from wealth
  union
  select party_key from financials
)

select
  parties.party_key as customer_id,
  {{ platform.anonymize('parties.party_key') }} as customer_id_hash,

  banking.banking_customer_id,
  banking.banking_status,
  banking.customer_type,
  coalesce(banking.account_count, 0)::integer as account_count,
  coalesce(banking.loan_count, 0)::integer as loan_count,
  {{ platform.money('coalesce(banking.loan_balance, 0)') }} as loan_balance,
  {{ platform.money('coalesce(banking.arrears_amount, 0)') }} as loan_arrears,

  insurance.insurance_customer_id,
  insurance.insurance_status,
  coalesce(insurance.active_policy_count, 0)::integer as active_policy_count,
  {{ platform.money('coalesce(insurance.annual_premium, 0)') }} as annual_premium,
  coalesce(insurance.open_claim_count, 0)::integer as open_claim_count,
  {{ platform.money('coalesce(insurance.paid_claims, 0)') }} as claims_paid,

  wealth.wealth_customer_id,
  wealth.wealth_status,
  coalesce(wealth.portfolio_count, 0)::integer as portfolio_count,
  {{ platform.money('coalesce(wealth.assets_under_management, 0)') }} as assets_under_management,
  {{ platform.money('coalesce(wealth.wealth_fees_12m, 0)') }} as wealth_fees_12m,

  {{ platform.money('coalesce(financials.total_revenue, 0)') }} as total_revenue,
  {{ platform.money('coalesce(financials.total_cost, 0)') }} as total_cost,
  {{ platform.money('coalesce(financials.total_profit, 0)') }} as total_profit,
  coalesce(financials.profit_months, 0)::integer as profit_months,
  financials.profit_band,

  (
    case when banking.party_key is not null then 1 else 0 end
    + case when insurance.party_key is not null then 1 else 0 end
    + case when wealth.party_key is not null then 1 else 0 end
  )::integer as domain_count,

  -- Outcome label for the churn model: the party left during the year (banking customer_exits).
  banking.exit_date is not null as has_churn,
  banking.exit_reason as churn_reason,

  {{ platform.as_of_date() }} as as_of_date
from parties
left join banking
  on parties.party_key = banking.party_key
left join insurance
  on parties.party_key = insurance.party_key
left join wealth
  on parties.party_key = wealth.party_key
left join financials
  on parties.party_key = financials.party_key
