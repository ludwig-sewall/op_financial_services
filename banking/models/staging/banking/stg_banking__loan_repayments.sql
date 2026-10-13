with source as (

    select * from {{ source('banking', 'loan_repayments') }}

),

renamed as (

    select
        repayment_id::varchar as repayment_id,
        loan_id::varchar as loan_id,
        due_date::date as due_date,
        paid_date::date as paid_date,
        {{ platform.money('amount_due') }} as amount_due,
        {{ platform.money('amount_paid') }} as amount_paid
    from source

)

select * from renamed
