with source as (

    select * from {{ source('banking', 'customers') }}

),

renamed as (

    select
        banking_customer_id::varchar as banking_customer_id,
        party_key::varchar as party_key,
        case
            when customer_status = 'A' then 'active'
            when customer_status = 'I' then 'inactive'
            when customer_status = 'C' then 'closed'
            -- Workshop: add a branch for 'F' → 'frozen'
            else customer_status
        end::varchar as customer_status,
        full_name::varchar as full_name,
        customer_type::varchar as customer_type,
        customer_since::date as customer_since,
        loaded_at::timestamp as loaded_at
    from source

)

select * from renamed
