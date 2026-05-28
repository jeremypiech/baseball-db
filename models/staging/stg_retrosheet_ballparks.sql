WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_ballparks') }}
)

SELECT
    ---------- primary
    parkid AS park_id,

    name AS ballpark_name,
    aka AS other_names,

    ---------- attributes
    league,
    city,
    state,

    STRPTIME("start", '%m/%d/%Y')::DATE AS first_game,
    STRPTIME("end", '%m/%d/%Y')::DATE AS last_game,

    notes

FROM source
