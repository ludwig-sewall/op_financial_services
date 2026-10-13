with checks as (

    select 'safe_divide zero denominator' as check_name, {{ platform.safe_divide('10', '0') }} is null as passed
    union all
    select 'safe_divide null denominator', {{ platform.safe_divide('10', 'null') }} is null
    union all
    select 'safe_divide ratio', {{ platform.safe_divide('1', '4') }} = 0.25
    union all
    select 'money rounds half up', {{ platform.money('12.345') }} = 12.35
    union all
    select 'decode known code', {{ platform.decode_status("' A '", {'A': 'active'}) }} = 'active'
    union all
    select 'decode unknown code passes through', {{ platform.decode_status("'X'", {'A': 'active'}) }} = 'x'
    union all
    select 'anonymize is deterministic', {{ platform.anonymize("'P-1001'") }} = {{ platform.anonymize("'P-1001'") }}
    union all
    select 'anonymize hides the value', {{ platform.anonymize("'P-1001'") }} != 'P-1001'

)

select check_name from checks where not passed
