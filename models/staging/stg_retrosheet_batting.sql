WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_batting') }}
)

SELECT * FROM source
