with source as (

    select * from {{ source('banking', 'transactions') }}

),

renamed as (

    select
        transaction_id::varchar as transaction_id,
        account_id::varchar as account_id,
        transaction_date::date as transaction_date,
        transaction_type::varchar as transaction_type,
        channel::varchar as channel,
        {{ platform.money('amount') }} as amount
    from source

)

select * from renamed
