with source as (

    select * from {{ source('financials', 'allocated_costs') }}

),

renamed as (

    select
        allocation_id::varchar as allocation_id,
        party_key::varchar as party_key,
        month::date as cost_month,
        {{ platform.money('cost') }} as cost
    from source

)

select * from renamed
