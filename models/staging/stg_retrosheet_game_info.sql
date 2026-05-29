WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_gameinfo') }}
)

SELECT
    ---------- primary
    gid AS game_id,
    visteam AS vis_team_id,
    hometeam AS home_team_id,

    vruns AS vis_score,
    hruns AS home_score,

    season,
    STRPTIME(date, '%Y%m%d')::DATE AS game_date,
    IF(number = 0, 1, number) AS date_game_number,
    gametype AS game_type,

    ---------- foreign keys
    wteam AS win_team_id,
    lteam AS loss_team_id,

    wp AS win_pitcher_id,
    lp AS loss_pitcher_id,
    save AS save_pitcher_id,

    site AS park_id,

    ----- umpires
    NULLIF(umphome, '(none)') AS ump_home_id,
    NULLIF(ump1b, '(none)') AS ump_1b_id,
    NULLIF(ump2b, '(none)') AS ump_2b_id,
    NULLIF(ump3b, '(none)') AS ump_3b_id,
    NULLIF(umplf, '(none)') AS ump_lf_id,
    NULLIF(umprf, '(none)') AS ump_rf_id,

    ----- official scorer
    oscorer AS official_scorer_id,

    ---------- attributes
    IF(LOWER(forfeit) = 'y', TRUE, FALSE) AS is_forfeit,
    COALESCE(usedh, FALSE) AS has_dh,
    COALESCE(htbf, FALSE) AS has_home_bats_first,
    COALESCE(innings, 9) AS scheduled_innings,
    STRPTIME(suspend, '%Y%m%d')::DATE AS suspended_game_completion_date,
    tiebreaker,

    ----- game conditions
    timeofgame AS time_of_game,
    attendance,
    NULLIF(starttime, '0:00PM') AS start_time,
    daynight AS day_night,
    NULLIF(fieldcond, 'unknown') AS field_cond,
    NULLIF(precip, 'unknown') AS precip,
    NULLIF(sky, 'unknown') AS sky,
    NULLIF(temp, 'unknown')::INTEGER AS temperature,
    NULLIF(winddir, 'unknown') AS wind_dir,
    NULLIF(NULLIF(windspeed, 'unknown'), '-1')::INTEGER AS wind_speed,

    ---------- metadata
    IF(batteries = 'p', 'pitchers', batteries) AS batteries_known,
    IF(LOWER(box) = 'y', TRUE, FALSE) AS has_box_score,
    IF(LOWER(line) = 'y', TRUE, FALSE) AS has_line_score,
    IF(LOWER(lineups) = 'y', TRUE, FALSE) AS has_lineups_known,
    pbp AS pbp_account

FROM source
