with loans as (

    select
      banking_customer_id,
      sum(arrears_amount) as arrears_amount,
      max(case when is_in_arrears then 1 else 0 end) = 1 as is_in_arrears
    from {{ ref('op_banking', 'fct_banking_loan_performance') }}
    group by 1

)

select
  customers.party_key,
  customers.banking_customer_id,
  customers.customer_status as banking_status,
  customers.customer_type,
  customers.exit_date,
  customers.exit_reason,
  holdings.account_count,
  holdings.loan_count,
  holdings.loan_balance,
  loans.arrears_amount,
  loans.is_in_arrears
from {{ ref('op_banking', 'dim_banking_customers') }} as customers
left join {{ ref('op_banking', 'fct_banking_holdings') }} as holdings
  on customers.banking_customer_id = holdings.banking_customer_id
left join loans
  on customers.banking_customer_id = loans.banking_customer_id
