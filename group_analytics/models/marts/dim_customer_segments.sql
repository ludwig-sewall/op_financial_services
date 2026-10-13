select
  customer_id,
  case
    when assets_under_management >= 1000000 or loan_balance >= 1000000 then 'private'
    when assets_under_management >= 100000 or loan_balance >= 250000 then 'affluent'
    else 'mass'
  end as value_segment,
  banking_customer_id is not null and insurance_customer_id is null as is_insurance_prospect,
  banking_customer_id is not null and wealth_customer_id is null and loan_balance < 250000
    and total_profit > 5000 as is_wealth_prospect,
  loan_arrears > 0 or coalesce(banking_status, '') = 'frozen' as is_credit_watch,
  case
    when has_churn then 'exit_review'
    when loan_arrears > 0 or coalesce(banking_status, '') = 'frozen' then 'collections_contact'
    when banking_customer_id is not null and wealth_customer_id is null and total_profit > 5000
      and loan_balance < 250000 then 'introduce_wealth'
    when banking_customer_id is not null and insurance_customer_id is null then 'offer_insurance'
    else 'retain'
  end as next_best_action
from {{ ref('dim_customer_360') }}
