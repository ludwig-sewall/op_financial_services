with source as (

    select * from {{ source('wealth', 'portfolios') }}

),

renamed as (

    select
        portfolio_id::varchar as portfolio_id,
        client_id::varchar as wealth_customer_id,
        lower(portfolio_status) as portfolio_status,
        {{ platform.money('market_value') }} as market_value,
        portfolio_name::varchar as portfolio_name,
        risk_profile::varchar as risk_profile,
        opened_date::date as opened_date
    from source

)

select * from renamed
