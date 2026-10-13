with source as (

    select * from {{ source('banking', 'loans') }}

),

renamed as (

    select
        loan_id::varchar as loan_id,
        banking_customer_id::varchar as banking_customer_id,
        lower(loan_status) as loan_status,
        {{ platform.money('balance') }} as balance,
        product_name::varchar as product_name,
        interest_rate::numeric(18, 4) as interest_rate,
        origination_date::date as origination_date,
        {{ platform.money('monthly_payment') }} as monthly_payment
    from source

)

select * from renamed
