WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_teamstats') }}
)

SELECT * FROM source
