with source as (

    select * from {{ source('insurance', 'claims') }}

),

renamed as (

    select
        claim_id::varchar as claim_id,
        policy_id::varchar as policy_id,
        loss_date::date as loss_date,
        reported_date::date as reported_date,
        claim_status::varchar as claim_status,
        {{ platform.money('claimed_amount') }} as claimed_amount,
        {{ platform.money('paid_amount') }} as paid_amount,
        settled_date::date as settled_date
    from source

)

select * from renamed
