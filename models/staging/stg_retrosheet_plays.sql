WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_plays') }}
)

SELECT
    ---------- primary
    {{ dbt_utils.generate_surrogate_key(['gid', 'pn']) }} AS unique_key,

    gid AS game_id,
    pn AS play_number,

    STRPTIME(date, '%Y%m%d')::DATE AS game_date,
    gametype AS game_type,

    event,
    inning,
    IF(top_bot = 0, 'top', 'bot') AS top_bot,
    IF(vis_home = 0, 'vis', 'home') AS vis_home_at_bat,

    score_v AS vis_score,
    score_h AS home_score,

    ---------- foreign keys
    site AS park_id,

    batteam AS bat_team_id,
    pitteam AS pitch_team_id,

    batter AS batter_id,
    pitcher AS pitcher_id,

    ----- baserunners
    br1_pre AS br_1b_pre_player_id,
    br2_pre AS br_2b_pre_player_id,
    br3_pre AS br_3b_pre_player_id,

    br1_post AS br_1b_post_player_id,
    br2_post AS br_2b_post_player_id,
    br3_post AS br_3b_post_player_id,

    lob_id1 AS lob_1b_player_id,
    lob_id2 AS lob_2b_player_id,
    lob_id3 AS lob_3b_player_id,

    run_b AS run_bat_player_id,
    run1 AS run_1b_player_id,
    run2 AS run_2b_player_id,
    run3 AS run_3b_player_id,

    ----- batting lineup
    l1 AS l1_player_id,
    l2 AS l2_player_id,
    l3 AS l3_player_id,
    l4 AS l4_player_id,
    l5 AS l5_player_id,
    l6 AS l6_player_id,
    l7 AS l7_player_id,
    l8 AS l8_player_id,
    l9 AS l9_player_id,

    ----- pitcher responsibility
    pr1_pre AS pr_1b_pre_player_id,
    pr2_pre AS pr_2b_pre_player_id,
    pr3_pre AS pr_3b_pre_player_id,

    pr1_post AS pr_1b_post_player_id,
    pr2_post AS pr_2b_post_player_id,
    pr3_post AS pr_3b_post_player_id,

    prun_b AS prun_bat_player_id,
    prun1 AS prun_1b_player_id,
    prun2 AS prun_2b_player_id,
    prun3 AS prun_3b_player_id,

    ----- fielders
    f2 AS f2_player_id,
    f3 AS f3_player_id,
    f4 AS f4_player_id,
    f5 AS f5_player_id,
    f6 AS f6_player_id,
    f7 AS f7_player_id,
    f8 AS f8_player_id,
    f9 AS f9_player_id,

    ----- umpires
    umphome AS ump_home_id,
    ump1b AS ump_1b_id,
    ump2b AS ump_2b_id,
    ump3b AS ump_3b_id,
    umplf AS ump_lf_id,
    umprf AS ump_rf_id,

    ---------- attributes
    ----- batter
    lp AS batter_lineup_pos,
    bat_f AS batter_field_pos,
    bathand AS batter_hand,

    ----- pitcher
    pithand AS pitcher_hand,

    ----- balls and strikes
    balls,
    strikes,
    count,
    nump AS pa_pitches,
    pitches AS pitch_seq,

    outs_pre,
    outs_post,

    ----- play result
    pa,
    ab,

    single,
    double,
    triple,
    hr,

    sh,
    sf,

    hbp,
    walk AS bb,
    iw AS ibb,

    k,
    k_safe,

    xi,
    roe,
    fc,

    othout AS other_out,
    noout AS other_no_out,

    gdp,
    othdp AS other_dp,
    tp,

    fle,

    wp,
    pb,
    bk,

    oa,

    ----- runs
    ur_b AS ur_bat,
    ur1 AS ur_1b,
    ur2 AS ur_2b,
    ur3 AS ur_3b,

    rbi_b AS rbi_bat,
    rbi1 AS rbi_1b,
    rbi2 AS rbi_2b,
    rbi3 AS rbi_3b,

    runs,
    rbi,
    er,
    tur AS team_unearned_runs,

    ----- batted ball
    hittype AS hit_type,
    loc,
    bip,
    bunt,
    ground,
    fly,
    line,

    ----- baserunning
    di,

    sb2 AS sb_2b,
    sb3 AS sb_3b,
    sbh AS sb_home,

    cs2 AS cs_2b,
    cs3 AS cs_3b,
    csh AS cs_home,

    pko1 AS po_att_1b,
    pko2 AS po_att_2b,
    pko3 AS po_att_3b,

    ----- fielding positions
    NULLIF(batout1, 0) AS bat_out1_field_pos,
    NULLIF(batout2, 0) AS bat_out2_field_pos,
    NULLIF(batout3, 0) AS bat_out3_field_pos,

    NULLIF(brout_b, 0) AS br_out_bat_field_pos,
    NULLIF(brout1, 0) AS br_out_1b_field_pos,
    NULLIF(brout2, 0) AS br_out_2b_field_pos,
    NULLIF(brout3, 0) AS br_out_3b_field_pos,

    lf1 AS l1_field_pos,
    lf2 AS l2_field_pos,
    lf3 AS l3_field_pos,
    lf4 AS l4_field_pos,
    lf5 AS l5_field_pos,
    lf6 AS l6_field_pos,
    lf7 AS l7_field_pos,
    lf8 AS l8_field_pos,
    lf9 AS l9_field_pos,

    ----- fielding
    e1,
    e2,
    e3,
    e4,
    e5,
    e6,
    e7,
    e8,
    e9,

    po0,
    po1,
    po2,
    po3,
    po4,
    po5,
    po6,
    po7,
    po8,
    po9,

    a1,
    a2,
    a3,
    a4,
    a5,
    a6,
    a7,
    a8,
    a9,

    fseq,
    firstf AS first_fielder_pos,

    dpopp AS dp_opp,
    "pivot" AS dp_pivot,

    ---------- metadata
    pbp AS pbp_source

FROM source
