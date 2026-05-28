WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_fielding') }}
),

renamed AS (
    SELECT
        ---------- primary
        {{ dbt_utils.generate_surrogate_key(['gid', 'id', 'team', 'stattype', 'd_pos', 'd_seq']) }}
            AS unique_key,

        gid AS game_id,
        id AS player_id,
        team AS team_id,
        stattype AS stat_type,
        d_pos AS pos,
        d_seq AS pos_seq,

        STRPTIME(date, '%Y%m%d')::DATE AS game_date,
        IF(number = 0, 1, number) AS date_game_number,
        gametype AS game_type,

        ---------- foreign keys
        opp AS opp_team_id,
        site AS park_id,

        ---------- attributes
        d_ifouts AS outs_played,
        d_po AS po,
        d_a AS a,
        d_e AS e,
        d_dp AS dp,
        d_tp AS tp,
        d_pb AS pb,
        d_wp AS wp,
        d_sb AS sb,
        d_cs AS cs,
        d_gs AS gs,

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
        ANY_VALUE(pos) AS pos,
        ANY_VALUE(pos_seq) AS pos_seq,
        ANY_VALUE(game_date) AS game_date,
        ANY_VALUE(date_game_number) AS date_game_number,
        ANY_VALUE(game_type) AS game_type,
        ANY_VALUE(opp_team_id) AS opp_team_id,
        ANY_VALUE(park_id) AS park_id,

        MAX(outs_played) AS outs_played,
        MAX(po) AS po,
        MAX(a) AS a,
        MAX(e) AS e,
        MAX(dp) AS dp,
        MAX(tp) AS tp,
        MAX(pb) AS pb,
        MAX(wp) AS wp,
        MAX(sb) AS sb,
        MAX(cs) AS cs,
        MAX(gs) AS gs,

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
