with source as (

    select * from {{ source('banking', 'customer_exits') }}

),

renamed as (

    select
        exit_id::varchar as exit_id,
        banking_customer_id::varchar as banking_customer_id,
        exit_date::date as exit_date,
        exit_reason::varchar as exit_reason
    from source

)

select * from renamed
