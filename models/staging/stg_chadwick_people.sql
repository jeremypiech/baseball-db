WITH source AS (
    SELECT * FROM {{ source('raw', 'chadwick_people') }}
)

SELECT
    ---------- primary
    key_uuid AS chadwick_unique_id,
    key_person AS chadwick_person_id,

    ---------- foreign keys
    key_retro AS retrosheet_id,
    key_mlbam AS mlbam_id,
    key_bbref AS bbref_id,
    key_bbref_minors AS bbref_minors_id,
    key_fangraphs AS fangraphs_id,
    key_npb AS npb_id,
    key_sr_nfl AS sr_nfl_id,
    key_sr_nba AS sr_nba_id,
    key_sr_nhl AS sr_nhl_id,
    key_wikidata AS wikidata_id,

    ---------- attributes
    name_first AS first_name,
    name_last AS last_name,
    name_given AS given_name,
    name_suffix AS suffix_name,
    name_matrilineal AS matrilineal_name,
    name_nick AS nickname,

    birth_year,
    birth_month,
    birth_day,
    death_year,
    death_month,
    death_day,

    pro_played_first AS pro_played_first_season,
    pro_played_last AS pro_played_last_season,
    mlb_played_first AS mlb_played_first_season,
    mlb_played_last AS mlb_played_last_season,
    col_played_first AS col_played_first_season,
    col_played_last AS col_played_last_season,

    pro_managed_first AS pro_managed_first_season,
    pro_managed_last AS pro_managed_last_season,
    mlb_managed_first AS mlb_managed_first_season,
    mlb_managed_last AS mlb_managed_last_season,
    col_managed_first AS col_managed_first_season,
    col_managed_last AS col_managed_last_season,

    pro_umpired_first AS pro_umpired_first_season,
    pro_umpired_last AS pro_umpired_last_season,
    mlb_umpired_first AS mlb_umpired_first_season,
    mlb_umpired_last AS mlb_umpired_last_season

FROM source
