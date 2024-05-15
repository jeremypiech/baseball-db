with source as (
    select * from {{ source('raw', 'retrosheet_rosters') }}
)

, ranks as (
    select
        *

        , case bats
            when 'B' then 3
            when 'L' then 2
            when 'R' then 1
            else 0
            end
            as bats_rank

        , case throws
            when 'B' then 3
            when 'L' then 2
            when 'R' then 1
            else 0
            end
            as throws_rank

    from source
)

select
    player_id
    , team_id
    , position
    , year

    , any_value(last_name) as last_name
    , any_value(first_name) as last_name
    , arg_max(bats, bats_rank) as bats
    , arg_max(throws, throws_rank) as throws

    , {{ dbt_utils.generate_surrogate_key(['player_id', 'team_id', 'year', 'position']) }} as unique_id
    
from ranks
group by 1,2,3,4
