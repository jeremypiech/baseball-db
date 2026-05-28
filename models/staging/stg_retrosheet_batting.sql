WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_batting') }}
),

renamed AS (

    SELECT
        ---------- primary
        {{ dbt_utils.generate_surrogate_key(['gid', 'id', 'team', 'stattype', 'b_seq']) }}
            AS unique_key,

        gid AS game_id,
        id AS player_id,
        team AS team_id,
        stattype AS stat_type,

        b_lp AS lineup_pos,
        b_seq AS app_seq,

        STRPTIME(date, '%Y%m%d')::DATE AS game_date,
        IF(number = 0, 1, number) AS date_game_number,
        gametype AS game_type,

        ---------- foreign keys
        opp AS opp_team_id,
        site AS park_id,

        ---------- attributes
        b_pa AS pa,
        b_ab AS ab,
        b_r AS r,
        b_h AS h,
        b_d AS d,
        b_t AS t,
        b_hr AS hr,
        b_rbi AS rbi,
        b_sh AS sh,
        b_sf AS sf,
        b_hbp AS hbp,
        b_w AS bb,
        b_iw AS ibb,
        b_k AS k,
        b_sb AS sb,
        b_cs AS cs,
        b_gdp AS gdp,
        b_xi AS xi,
        b_roe AS roe,

        IF(dh = 1, TRUE, FALSE) AS is_dh,
        IF(ph = 1, TRUE, FALSE) AS is_ph,
        IF(pr = 1, TRUE, FALSE) AS is_pr,

        win AS team_win,
        loss AS team_loss,
        tie AS team_tie,

        IF(LOWER(vishome) = 'v', 'vis', 'home') AS vis_home,

        ---------- metadata
        IF(LOWER(box) = 'y', TRUE, FALSE) AS has_box_score,
        pbp AS pbp_source

    FROM source
),

deduped AS (
    SELECT
        unique_key,

        ANY_VALUE(game_id) AS game_id,
        ANY_VALUE(player_id) AS player_id,
        ANY_VALUE(team_id) AS team_id,
        ANY_VALUE(stat_type) AS stat_type,
        ANY_VALUE(lineup_pos) AS lineup_pos,
        ANY_VALUE(app_seq) AS app_seq,
        ANY_VALUE(game_date) AS game_date,
        ANY_VALUE(date_game_number) AS date_game_number,
        ANY_VALUE(game_type) AS game_type,
        ANY_VALUE(opp_team_id) AS opp_team_id,
        ANY_VALUE(park_id) AS park_id,

        MAX(pa) AS pa,
        MAX(ab) AS ab,
        MAX(r) AS r,
        MAX(h) AS h,
        MAX(d) AS d,
        MAX(t) AS t,
        MAX(hr) AS hr,
        MAX(rbi) AS rbi,
        MAX(sh) AS sh,
        MAX(sf) AS sf,
        MAX(hbp) AS hbp,
        MAX(bb) AS bb,
        MAX(ibb) AS ibb,
        MAX(k) AS k,
        MAX(sb) AS sb,
        MAX(cs) AS cs,
        MAX(gdp) AS gdp,
        MAX(xi) AS xi,
        MAX(roe) AS roe,
        MAX(is_dh) AS is_dh,
        MAX(is_ph) AS is_ph,
        MAX(is_pr) AS is_pr,

        ANY_VALUE(team_win) AS team_win,
        ANY_VALUE(team_loss) AS team_loss,
        ANY_VALUE(team_tie) AS team_tie,
        ANY_VALUE(vis_home) AS vis_home,
        ANY_VALUE(has_box_score) AS has_box_score,
        ANY_VALUE(pbp_source) AS pbp_source

    FROM renamed
    GROUP BY 1
)

SELECT *
FROM deduped
