WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_pitching') }}
)

SELECT
    ---------- primary
    {{ dbt_utils.generate_surrogate_key(['gid', 'id', 'team', 'stattype', 'p_seq']) }}
        AS unique_key,

    gid AS game_id,
    id AS player_id,
    team AS team_id,
    stattype AS stat_type,
    p_seq AS app_seq,

    STRPTIME(date, '%Y%m%d')::DATE AS game_date,
    IF(number = 0, 1, number) AS date_game_number,
    gametype AS game_type,

    ---------- foreign keys
    opp AS opp_team_id,
    site AS park_id,

    ---------- attributes
    p_ipouts AS outs_recorded,
    p_noout AS no_out_inning_bf,
    p_bfp AS bf,

    p_h AS h,
    p_d AS d,
    p_t AS t,
    p_hr AS hr,
    p_r AS r,
    p_er AS er,
    p_w AS bb,
    p_iw AS ibb,
    p_k AS k,
    p_hbp AS hbp,
    p_wp AS wp,
    p_bk AS bk,
    p_sh AS sh,
    p_sf AS sf,
    p_sb AS sb,
    p_cs AS cs,
    p_pb AS pb,

    wp AS w,
    lp AS l,
    save AS sv,

    IF(gs = 1, TRUE, FALSE) AS is_gs,
    IF(gf = 1, TRUE, FALSE) AS is_gf,
    IF(cg = 1, TRUE, FALSE) AS is_cg,

    win AS team_win,
    loss AS team_loss,
    tie AS team_tie,

    IF(LOWER(vishome) = 'v', 'vis', 'home') AS vis_home,

    ---------- metadata
    IF(LOWER(box) = 'y', TRUE, FALSE) AS has_box_score,
    pbp AS pbp_source

FROM source
