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

    {{ dbt_utils.generate_surrogate_key(['game_pk', 'at_bat_number', 'pitch_number']) }}
        AS unique_key,

    pitch_type,
    game_date,
    release_speed,
    release_pos_x,
    release_pos_z,

    batter AS batter_id,
    pitcher AS pitcher_id,
    events,
    description AS pitch_result_desc,

    zone,

    des AS pa_desc,

    CASE game_type
        WHEN 'E' THEN 'Exhibition'
        WHEN 'S' THEN 'Spring Training'
        WHEN 'R' THEN 'Regular Season'
        WHEN 'F' THEN 'Wild Card'
        WHEN 'D' THEN 'Divisional Series'
        WHEN 'L' THEN 'League Championship Series'
        WHEN 'W' THEN 'World Series'
    END AS game_type,

    stand AS batter_stands,
    p_throws AS pitcher_throws,

    home_team,
    away_team,

    type AS pitch_result,

    hit_location,
    bb_type,
    balls,
    strikes,
    game_year,
    pfx_x,
    pfx_z,
    plate_x,
    plate_z,

    on_3b AS on_3b_id,
    on_2b AS on_2b_id,
    on_1b AS on_1b_id,
    outs_when_up AS outs,

    inning,
    inning_topbot,
    hc_x,
    hc_y,
    sv_id,
    vx0,
    vy0,
    vz0,
    ax,
    ay,
    az,
    sz_top,
    sz_bot,
    hit_distance_sc,
    launch_speed,
    launch_angle,
    effective_speed,
    release_spin_rate,
    release_extension,

    game_pk AS game_id,
    fielder_2 AS fielder_2_id,
    fielder_3 AS fielder_3_id,
    fielder_4 AS fielder_4_id,
    fielder_5 AS fielder_5_id,
    fielder_6 AS fielder_6_id,
    fielder_7 AS fielder_7_id,
    fielder_8 AS fielder_8_id,
    fielder_9 AS fielder_9_id,

    release_pos_y,
    estimated_ba_using_speedangle,
    estimated_woba_using_speedangle,
    woba_value,
    woba_denom,
    babip_value,
    iso_value,

    CASE launch_speed_angle
        WHEN 1 THEN 'Weak'
        WHEN 2 THEN 'Topped'
        WHEN 3 THEN 'Under'
        WHEN 4 THEN 'Flare'
        WHEN 5 THEN 'Solid Contact'
        WHEN 6 THEN 'Barrel'
    END AS launch_speed_angle_type,

    at_bat_number AS game_pa_number,
    pitch_number AS pa_pitch_number,

    pitch_name,
    home_score,
    away_score,
    bat_score,
    fld_score,
    post_away_score,
    post_home_score,
    post_bat_score,
    post_fld_score,
    if_fielding_alignment,
    of_fielding_alignment,
    spin_axis,
    delta_home_win_exp,
    delta_run_exp,
    bat_speed,
    swing_length,
    estimated_slg_using_speedangle,
    delta_pitcher_run_exp,
    hyper_speed,
    home_score_diff,
    bat_score_diff,
    bat_score_diff,
    home_win_exp,
    bat_win_exp,
    n_thruorder_pitcher,
    n_priorpa_thisgame_player_at_bat,
    batter_days_since_prev_game,
    pitcher_days_until_next_game,
    batter_days_until_next_game,
    api_break_z_with_gravity,
    api_break_x_arm,
    api_break_x_batter_in,
    arm_angle,
    attack_angle,
    attack_direction,
    swing_path_tilt,
    intercept_ball_minus_batter_pos_x_inches,
    intercept_ball_minus_batter_pos_y_inches

FROM source
