select
  loans.loan_id,
  loans.banking_customer_id,
  loans.product_name,
  loans.loan_status,
  loans.balance as outstanding_balance,
  loans.interest_rate,
  loans.monthly_payment,
  coalesce(repayments.instalments_due, 0)::integer as instalments_due,
  coalesce(repayments.instalments_missed, 0)::integer as instalments_missed,
  coalesce(repayments.instalments_late, 0)::integer as instalments_late,
  {{ platform.money('coalesce(repayments.arrears_amount, 0)') }} as arrears_amount,
  case
    when coalesce(repayments.days_past_due, 0) = 0 then 'current'
    when repayments.days_past_due <= 30 then '1-30'
    when repayments.days_past_due <= 90 then '31-90'
    else '90+'
  end as delinquency_bucket,
  coalesce(repayments.instalments_missed, 0) > 0 as is_in_arrears
from {{ ref('stg_banking__loans') }} as loans
left join {{ ref('int_banking_loan_repayments__by_loan') }} as repayments
  on loans.loan_id = repayments.loan_id
