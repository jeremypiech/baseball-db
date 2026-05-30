{{ config(materialized = 'table') }}

WITH source AS (
    SELECT * FROM {{ source('raw', 'statcast') }}
)

SELECT
    /*
    Removes the player name and deprecated fields.
        - player_name
        - spin_dir
        - spin_rate_deprecated
        - break_angle_deprecated
        - break_length_deprecated
        - tfs_deprecated
        - tfs_zulu_deprecated
        - umpire
    */

    ---------- primary
    {{ dbt_utils.generate_surrogate_key(['game_pk', 'at_bat_number', 'pitch_number']) }}
        AS unique_key,

    game_pk AS game_id,
    at_bat_number AS game_pa_number,
    pitch_number AS pa_pitch_number,

    game_date,
    home_team,
    away_team,

    description AS pitch_result_desc,
    des AS gameday_desc,
    events AS pa_event,

    ---------- foreign keys
    batter AS batter_id,
    pitcher AS pitcher_id,

    fielder_2 AS fielder_2_id,
    fielder_3 AS fielder_3_id,
    fielder_4 AS fielder_4_id,
    fielder_5 AS fielder_5_id,
    fielder_6 AS fielder_6_id,
    fielder_7 AS fielder_7_id,
    fielder_8 AS fielder_8_id,
    fielder_9 AS fielder_9_id,

    on_1b AS on_1b_id,
    on_2b AS on_2b_id,
    on_3b AS on_3b_id,

    ---------- attributes
    ----- game
    game_year AS season,

    CASE game_type
        WHEN 'E' THEN 'Exhibition'
        WHEN 'S' THEN 'Spring Training'
        WHEN 'R' THEN 'Regular Season'
        WHEN 'F' THEN 'Wild Card'
        WHEN 'D' THEN 'Divisional Series'
        WHEN 'L' THEN 'League Championship Series'
        WHEN 'W' THEN 'World Series'
    END AS game_type,

    ----- situation
    inning,
    inning_topbot,
    outs_when_up AS outs,
    balls,
    strikes,

    home_score,
    away_score,
    home_score_diff,
    post_home_score,
    post_away_score,

    bat_score,
    fld_score,
    bat_score_diff,
    post_bat_score,
    post_fld_score,

    ----- pitcher
    p_throws AS pitcher_throws,

    age_pit,
    age_pit_legacy,

    n_thruorder_pitcher,
    pitcher_days_since_prev_game,
    pitcher_days_until_next_game,

    ----- batter
    stand AS batter_stands,

    age_bat,
    age_bat_legacy,

    sz_top,
    sz_bot,

    n_priorpa_thisgame_player_at_bat,
    batter_days_since_prev_game,
    batter_days_until_next_game,

    ----- pitch
    pitch_name,
    pitch_type,

    release_speed,
    release_pos_x,
    release_pos_y,
    release_pos_z,
    release_spin_rate,
    release_extension,

    effective_speed,

    vx0,
    vy0,
    vz0,

    ax,
    ay,
    az,

    pfx_x,
    pfx_z,

    plate_x,
    plate_z,

    arm_angle,
    api_break_x_arm,
    api_break_x_batter_in,
    api_break_z_with_gravity,
    spin_axis,

    zone AS zone_loc,
    type AS pitch_result,

    ----- swing
    bat_speed,
    swing_length,
    hyper_speed,
    attack_angle,
    attack_direction,
    swing_path_tilt,
    intercept_ball_minus_batter_pos_x_inches,
    intercept_ball_minus_batter_pos_y_inches,

    ----- batted ball
    bb_type,
    hit_location,
    hc_x,
    hc_y,

    hit_distance_sc,
    launch_speed,
    launch_angle,

    estimated_ba_using_speedangle,
    estimated_slg_using_speedangle,
    estimated_woba_using_speedangle,

    CASE launch_speed_angle
        WHEN 1 THEN 'Weak'
        WHEN 2 THEN 'Topped'
        WHEN 3 THEN 'Under'
        WHEN 4 THEN 'Flare'
        WHEN 5 THEN 'Solid Contact'
        WHEN 6 THEN 'Barrel'
    END AS launch_speed_angle_type,

    ----- fielding
    if_fielding_alignment,
    of_fielding_alignment,

    ----- play result
    woba_value,
    woba_denom,
    babip_value,
    iso_value,

    ----- win expectancy
    home_win_exp,
    bat_win_exp,
    delta_home_win_exp,

    delta_run_exp,
    delta_pitcher_run_exp,

    ----- other
    sv_id,

    ----- booleans
    pa_event IS NOT NULL AS is_pa_event

FROM source
