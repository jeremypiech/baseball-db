WITH source AS (
    SELECT * FROM {{ source('raw', 'chadwick_people') }}
)

SELECT * FROM source
