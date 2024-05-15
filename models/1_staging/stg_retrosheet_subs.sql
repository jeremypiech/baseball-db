with source as (
    select * from {{ source('raw', 'retrosheet_subs') }}
)

select
    game_id
    , inn_ct
    , bat_home_id = 1 as is_bat_home
    , sub_id
    , sub_home_id = 1 as is_sub_home
    , sub_lineup_id
    , sub_fld_cd
    , removed_id
    , removed_fld_cd
    , event_id
    , {{ dbt_utils.generate_surrogate_key(['game_id', 'event_id', 'sub_id', 'sub_fld_cd']) }} as unique_id
from source
