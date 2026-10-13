with source as (

    select * from {{ source('insurance', 'policies') }}

),

renamed as (

    select
        policy_id::varchar as policy_id,
        insurance_customer_id::varchar as insurance_customer_id,
        lower(policy_status) as policy_status,
        {{ platform.money('annual_premium') }} as annual_premium,
        product_name::varchar as product_name,
        start_date::date as start_date,
        {{ platform.money('sum_insured') }} as sum_insured
    from source

)

select * from renamed
