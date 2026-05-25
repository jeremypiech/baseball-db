WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_pitching') }}
)

SELECT * FROM source
