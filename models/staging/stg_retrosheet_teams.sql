WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_teams') }}
)

SELECT
    ---------- primary
    team AS team_id,

    city,
    nickname,

    ---------- attributes
    league,
    first AS first_season,
    last AS last_season

FROM source
