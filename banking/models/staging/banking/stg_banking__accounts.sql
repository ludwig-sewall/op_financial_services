with source as (

    select * from {{ source('banking', 'accounts') }}

),

renamed as (

    select
        account_id::varchar as account_id,
        banking_customer_id::varchar as banking_customer_id,
        lower(account_status) as account_status,
        product_name::varchar as product_name,
        opened_date::date as opened_date,
        currency::varchar as currency
    from source

)

select * from renamed
