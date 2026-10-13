with source as (

    select * from {{ source('wealth', 'trades') }}

),

renamed as (

    select
        trade_id::varchar as trade_id,
        portfolio_id::varchar as portfolio_id,
        trade_date::date as trade_date,
        trade_side::varchar as trade_side,
        {{ platform.money('amount') }} as amount,
        {{ platform.money('fee') }} as fee
    from source

)

select * from renamed
