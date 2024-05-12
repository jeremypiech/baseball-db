with source as (
    select * from {{ source('raw', 'retrosheet_rosters') }}
)

select
    *
    , {{ dbt_utils.generate_surrogate_key(['player_id', 'team_id', 'position']) }} as unique_id
from source
