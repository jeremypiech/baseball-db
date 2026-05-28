WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_discreps') }}
)

SELECT
    ---------- primary
    id AS discrepancy_id,
    player AS player_id,

    year AS season,

    ---------- foreign keys
    game AS game_id,
    team AS team_id,
    "cross" AS related_discrepancy_id,

    ---------- attributes
    type AS discrepancy_type,
    code AS discrepancy_code,
    pos AS field_pos,
    cat AS stat_type,
    retro AS retrosheet_value,
    official AS official_value,
    notes,
    IF(accepted = 'Y', TRUE, FALSE) AS is_accepted

FROM source
