WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_ejections') }}
)

SELECT * FROM source
