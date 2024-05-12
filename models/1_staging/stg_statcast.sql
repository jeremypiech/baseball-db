with source as (
    select * from {{ source('raw', 'statcast') }}
)

select * from source
