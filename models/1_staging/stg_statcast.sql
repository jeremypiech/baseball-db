{{ config(materialized = 'table') }}

with source as (
    select * from {{ source('raw', 'statcast') }}
)

select
    pitch_type
    , game_date
    , release_speed
    , release_pos_x
    , release_pos_z

    -- , player_name

    , batter as batter_id
    , pitcher as pitcher_id
    , events
    , description as pitch_desc

    -- , spin_dir
    -- , spin_rate_deprecated
    -- , break_angle_deprecated
    -- , break_length_deprecated

    , zone
    , des as pa_desc

    , case game_type
        when 'E' then 'Exhibition'
        when 'S' then 'Spring Training'
        when 'R' then 'Regular Season'
        when 'F' then 'Wild Card'
        when 'D' then 'Divisional Series'
        when 'L' then 'League Championship Series'
        when 'W' then 'World Series'
        end as game_type

    , stand as batter_stands
    , p_throws as pitcher_throws
    , home_team
    , away_team
    , type as pitch_result
    , hit_location
    , bb_type
    , balls
    , strikes
    , game_year
    , pfx_x
    , pfx_z
    , plate_x
    , plate_z
    , on_3b as on_3b_id
    , on_2b as on_2b_id
    , on_1b as on_1b_id
    , outs_when_up as outs
    , inning
    , inning_topbot
    , hc_x
    , hc_y

    -- , tfs_deprecated
    -- , tfs_zulu_deprecated

    , fielder_2 as catcher_id

    -- , umpire

    , sv_id
    , vx0
    , vy0
    , vz0
    , ax
    , ay
    , az
    , sz_top
    , sz_bot
    , hit_distance_sc
    , launch_speed
    , launch_angle
    , effective_speed
    , release_spin_rate
    , release_extension
    , game_pk as game_id

    -- , pitcher_1
    -- , fielder_2_1

    , fielder_3 as fielder_3_id
    , fielder_4 as fielder_4_id
    , fielder_5 as fielder_5_id
    , fielder_6 as fielder_6_id
    , fielder_7 as fielder_7_id
    , fielder_8 as fielder_8_id
    , fielder_9 as fielder_9_id
    , release_pos_y
    , estimated_ba_using_speedangle
    , estimated_woba_using_speedangle
    , woba_value
    , woba_denom
    , babip_value
    , iso_value

    , case launch_speed_angle
        when 1 then 'Weak'
        when 2 then 'Topped'
        when 3 then 'Under'
        when 4 then 'Flare'
        when 5 then 'Solid Contact'
        when 6 then 'Barrel'
        end as launch_speed_angle_type

    , at_bat_number as game_pa_number
    , pitch_number as pa_pitch_number
    , pitch_name
    , home_score
    , away_score
    , bat_score
    , fld_score
    , post_away_score
    , post_home_score
    , post_bat_score
    , post_fld_score
    , if_fielding_alignment
    , of_fielding_alignment
    , spin_axis
    , delta_home_win_exp
    , delta_run_exp
    , bat_speed
    , swing_length

    , {{ dbt_utils.generate_surrogate_key(['game_id', 'game_pa_number', 'pa_pitch_number']) }} as unique_id

from source
