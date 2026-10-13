select claim_id
from {{ ref('fct_insurance_claims') }}
where reported_date < loss_date
   or days_to_settle < 0
