select
  party_key,
  month,
  case
    when revenue is null and unpriced_postings > 0 then 'unpriced_revenue'
    when revenue is null then 'missing_revenue'
    else 'missing_cost'
  end as gap_type
from {{ ref('int_customer_months__coverage') }}
where not is_complete
