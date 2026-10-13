select
  insurance_customer_id,
  count(*)::integer as active_policy_count,
  {{ platform.money('sum(annual_premium)') }} as annual_premium
from {{ ref('stg_insurance__policies') }}
where policy_status = 'active'
group by 1
