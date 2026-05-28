WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_teamstats') }}
)

SELECT
    ---------- primary
    {{ dbt_utils.generate_surrogate_key(['gid', 'team', 'stattype']) }} AS unique_key,

    gid AS game_id,
    team AS team_id,
    stattype AS stat_type,

    STRPTIME(date, '%Y%m%d')::DATE AS game_date,
    IF(number = 0, 1, number) AS date_game_number,
    gametype AS game_type,

    ---------- foreign keys
    ----- fielding position
    start_f1 AS f1_starter_id,
    start_f2 AS f2_starter_id,
    start_f3 AS f3_starter_id,
    start_f4 AS f4_starter_id,
    start_f5 AS f5_starter_id,
    start_f6 AS f6_starter_id,
    start_f7 AS f7_starter_id,
    start_f8 AS f8_starter_id,
    start_f9 AS f9_starter_id,
    start_f10 AS f10_starter_id,

    ----- lineup
    start_l1 AS l1_starter_id,
    start_l2 AS l2_starter_id,
    start_l3 AS l3_starter_id,
    start_l4 AS l4_starter_id,
    start_l5 AS l5_starter_id,
    start_l6 AS l6_starter_id,
    start_l7 AS l7_starter_id,
    start_l8 AS l8_starter_id,
    start_l9 AS l9_starter_id,

    ----- other
    mgr AS manager_id,
    site AS park_id,

    ---------- attributes
    ----- line score
    inn1::INTEGER AS inn1_runs,
    inn2::INTEGER AS inn2_runs,
    inn3::INTEGER AS inn3_runs,
    inn4::INTEGER AS inn4_runs,
    inn5::INTEGER AS inn5_runs,
    inn6::INTEGER AS inn6_runs,
    inn7::INTEGER AS inn7_runs,
    inn8::INTEGER AS inn8_runs,
    inn9::INTEGER AS inn9_runs,
    inn10::INTEGER AS inn10_runs,
    inn11::INTEGER AS inn11_runs,
    inn12::INTEGER AS inn12_runs,
    inn13::INTEGER AS inn13_runs,
    inn14::INTEGER AS inn14_runs,
    inn15::INTEGER AS inn15_runs,
    inn16::INTEGER AS inn16_runs,
    inn17::INTEGER AS inn17_runs,
    inn18::INTEGER AS inn18_runs,
    inn19::INTEGER AS inn19_runs,
    inn20::INTEGER AS inn20_runs,
    inn21::INTEGER AS inn21_runs,
    inn22::INTEGER AS inn22_runs,
    inn23::INTEGER AS inn23_runs,
    inn24::INTEGER AS inn24_runs,
    inn25::INTEGER AS inn25_runs,
    inn26::INTEGER AS inn26_runs,
    inn27::INTEGER AS inn27_runs,
    inn28::INTEGER AS inn28_runs,

    ----- batting
    b_pa,
    b_ab,
    b_r,
    b_h,
    b_d,
    b_t,
    b_hr,
    b_rbi,
    b_sh,
    b_sf,
    b_hbp,
    b_w AS b_bb,
    b_iw AS b_ibb,
    b_k,
    b_sb,
    b_cs,
    b_gdp,
    b_xi,
    b_roe,
    lob AS b_lob,

    ----- pitching
    p_ipouts AS p_outs_recorded,
    p_noout AS p_no_out_inning_bf,
    p_bfp AS p_bf,
    p_h,
    p_d,
    p_t,
    p_hr,
    p_r,
    p_er,
    p_w AS p_bb,
    p_iw AS p_ibb,
    p_k,
    p_hbp,
    p_wp,
    p_bk,
    p_sh,
    p_sf,
    p_sb,
    p_cs,
    p_pb,

    ----- defense
    d_po,
    d_a,
    d_e,
    d_dp,
    d_tp,
    d_pb,
    d_wp,
    d_sb,
    d_cs,

    ----- team
    win AS team_win,
    loss AS team_loss,
    tie AS team_tie,

    IF(LOWER(vishome) = 'v', 'vis', 'home') AS vis_home,

    ---------- metadata
    IF(LOWER(box) = 'y', TRUE, FALSE) AS has_box_score,
    pbp AS pbp_source

FROM source
