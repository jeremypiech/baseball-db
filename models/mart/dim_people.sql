WITH stg_chadwick_people AS (
    SELECT * FROM {{ ref('stg_chadwick_people') }}
)

SELECT
    ---------- primary
    chadwick_unique_id,
    chadwick_person_id,

    ---------- foreign keys
    retrosheet_id,
    mlbam_id,
    bbref_id,
    bbref_minors_id,
    fangraphs_id,
    npb_id,
    sr_nfl_id,
    sr_nba_id,
    sr_nhl_id,
    wikidata_id,

    ---------- attributes
    first_name,
    last_name,
    given_name,
    suffix_name,
    matrilineal_name,
    nickname,

    birth_year,
    birth_month,
    birth_day,
    death_year,
    death_month,
    death_day,

    pro_played_first_season,
    pro_played_last_season,
    mlb_played_first_season,
    mlb_played_last_season,
    col_played_first_season,
    col_played_last_season,

    pro_managed_first_season,
    pro_managed_last_season,
    mlb_managed_first_season,
    mlb_managed_last_season,
    col_managed_first_season,
    col_managed_last_season,

    pro_umpired_first_season,
    pro_umpired_last_season,
    mlb_umpired_first_season,
    mlb_umpired_last_season

FROM stg_chadwick_people
