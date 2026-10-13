with profitability as (
  select party_key, month as activity_month, revenue, cost, profit
  from {{ ref('op_financials', 'fct_customer_profitability_monthly') }}
),

banking as (
  select * from {{ ref('int_customer_monthly__banking') }}
),

insurance as (
  select * from {{ ref('int_customer_monthly__insurance') }}
),

wealth as (
  select * from {{ ref('int_customer_monthly__wealth') }}
),

party_months as (
  select party_key, activity_month from profitability
  union
  select party_key, activity_month from banking
  union
  select party_key, activity_month from insurance
  union
  select party_key, activity_month from wealth
)

select
  party_months.party_key || '|' || cast(party_months.activity_month as varchar) as customer_month_id,
  party_months.party_key as customer_id,
  party_months.activity_month,
  {{ platform.money('coalesce(profitability.revenue, 0)') }} as revenue,
  {{ platform.money('coalesce(profitability.cost, 0)') }} as cost,
  {{ platform.money('coalesce(profitability.profit, 0)') }} as profit,
  {{ platform.money('coalesce(banking.banking_net_flow, 0)') }} as banking_net_flow,
  coalesce(banking.banking_transactions, 0)::integer as banking_transactions,
  coalesce(insurance.claims_reported, 0)::integer as claims_reported,
  {{ platform.money('coalesce(insurance.claims_paid, 0)') }} as claims_paid,
  {{ platform.money('coalesce(wealth.net_investment, 0)') }} as wealth_net_investment,
  {{ platform.money('coalesce(wealth.wealth_fees, 0)') }} as wealth_fees
from party_months
left join profitability
  on party_months.party_key = profitability.party_key
 and party_months.activity_month = profitability.activity_month
left join banking
  on party_months.party_key = banking.party_key
 and party_months.activity_month = banking.activity_month
left join insurance
  on party_months.party_key = insurance.party_key
 and party_months.activity_month = insurance.activity_month
left join wealth
  on party_months.party_key = wealth.party_key
 and party_months.activity_month = wealth.activity_month
