WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_discreps') }}
)

SELECT * FROM source
