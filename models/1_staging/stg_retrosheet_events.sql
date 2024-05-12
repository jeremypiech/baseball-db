with source as (
    select * from {{ source('raw', 'retrosheet_events') }}
)

select
    *    
    , {{ dbt_utils.generate_surrogate_key(['game_id', 'event_id']) }} as unique_id
from source
