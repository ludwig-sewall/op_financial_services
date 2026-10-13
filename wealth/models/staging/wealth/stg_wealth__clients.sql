with source as (

    select * from {{ source('wealth', 'clients') }}

),

renamed as (

    select
        client_id::varchar as wealth_customer_id,
        party_key::varchar as party_key,
        lower(client_status) as client_status,
        full_name::varchar as full_name,
        loaded_at::timestamp as loaded_at
    from source

)

select * from renamed
