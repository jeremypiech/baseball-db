with source as (
    select * from {{ source('raw', 'retrosheet_games') }}
)

select * from source
