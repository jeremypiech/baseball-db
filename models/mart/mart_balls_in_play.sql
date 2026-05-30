WITH fact_statcast_pitches AS (
    SELECT * FROM {{ ref('fact_statcast_pitches') }}
)

SELECT *
FROM fact_statcast_pitches
WHERE pitch_result_desc = 'hit_into_play'
    AND pa_event != 'home_run'
