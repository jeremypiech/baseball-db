WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_plays') }}
)

SELECT * FROM source
