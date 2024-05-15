with source as (
    select * from {{ source('raw', 'chadwick_register') }}
)

select * from source
