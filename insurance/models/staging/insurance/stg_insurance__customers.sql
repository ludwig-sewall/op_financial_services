with source as (

    select * from {{ source('insurance', 'customers') }}

),

renamed as (

    select
        insurance_customer_id::varchar as insurance_customer_id,
        party_key::varchar as party_key,
        lower(customer_status) as customer_status,
        full_name::varchar as full_name,
        loaded_at::timestamp as loaded_at
    from source

)

select * from renamed
