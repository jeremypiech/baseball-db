WITH statcast AS (
    SELECT * FROM {{ ref('stg_statcast') }}
)

SELECT
    *,

    ROUND(
        ATAN(
            (hc_x - 125.42)
            / (198.27 - hc_y)
        )
        * 180
        / PI()
        * 0.75,

        2
    )::DECIMAL(18, 2)
        AS spray_angle

FROM statcast
WHERE pitch_result_desc = 'hit_into_play'
