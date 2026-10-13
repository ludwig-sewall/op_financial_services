select
  customers.insurance_customer_id,
  coalesce(active.active_policy_count, 0)::integer as active_policy_count,
  {{ platform.money('coalesce(active.annual_premium, 0)') }} as annual_premium
from {{ ref('dim_insurance_customers') }} as customers
left join {{ ref('int_insurance_policies__active_by_customer') }} as active
  on customers.insurance_customer_id = active.insurance_customer_id
