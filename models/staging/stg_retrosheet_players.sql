WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_allplayers') }}
)

SELECT * FROM source
