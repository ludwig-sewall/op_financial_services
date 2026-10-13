with source as (

    select * from {{ source('financials', 'revenue_transactions') }}

),

renamed as (

    select
        transaction_id::varchar as transaction_id,
        party_key::varchar as party_key,
        month::date as revenue_month,
        {{ platform.money('amount') }} as amount,
        loaded_at::timestamp as loaded_at
    from source

)

select * from renamed
