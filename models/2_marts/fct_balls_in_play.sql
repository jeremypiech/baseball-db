with statcast as (
    select * from {{ ref('stg_statcast') }}
)

select
    *
    , round(
        atan(
            (hc_x - 125.42)
            / (198.27 - hc_y)
        )
        * 180 / pi() * 0.75
        
        , 2)
        :: decimal(18, 2)
        as spray_angle

from statcast
where pitch_result_desc = 'hit_into_play'
