WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_gameinfo') }}
)

SELECT * FROM source
