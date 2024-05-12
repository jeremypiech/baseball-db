with source as (
    select * from {{ source('raw', 'retrosheet_subs') }}
)

select
    *
    , {{ dbt_utils.generate_surrogate_key(['game_id', 'sub_id', 'event_id']) }} as unique_id
from source
