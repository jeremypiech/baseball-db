WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_fielding') }}
)

SELECT * FROM source
