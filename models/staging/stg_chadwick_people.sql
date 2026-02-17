with source as (
    select * from {{ source('raw', 'chadwick_people') }}
)

select * from source
