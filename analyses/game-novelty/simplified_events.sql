WITH stg_retrosheet_plays AS (
    SELECT * FROM dev.stg_retrosheet_plays
),

simplified_event AS (
    SELECT
        *,

        REGEXP_EXTRACT(event, '^([\w\d\(\)]+)[\/\.]?', 1, 'i') AS first_event_part,

        CASE
            WHEN first_event_part LIKE 'FC%' THEN 'FC'
            WHEN first_event_part LIKE '%E%' THEN REGEXP_EXTRACT(first_event_part, '(E\d)', 1, 'i')
            WHEN
                first_event_part LIKE 'CS%'
                THEN REGEXP_EXTRACT(first_event_part, '^([\w\d]+)\(?', 1, 'i')
            WHEN
                first_event_part LIKE 'PO%'
                THEN REGEXP_EXTRACT(first_event_part, '^([\w\d]+)\(?', 1, 'i')
            ELSE first_event_part
        END AS basic_event,

        MAX(basic_event = '99') OVER (PARTITION BY game_id) AS has_unknown_event

    FROM stg_retrosheet_plays
),

filtered AS (
    SELECT *
    FROM simplified_event
    WHERE pbp_source = 'full'
        AND game_type NOT IN ('allstar', 'exhibition')
        AND event NOT LIKE 'NP%'
        AND NOT has_unknown_event
),

categorized_events AS (
    SELECT
        game_id,
        play_number,

        game_date,
        YEAR(game_date) AS season,

        event,
        first_event_part,
        basic_event,

        sh,
        fc,
        roe,
        other_out,
        gdp,
        other_dp,

        CASE
            WHEN single = 1 THEN '1B'
            WHEN double = 1 THEN '2B'
            WHEN triple = 1 THEN '3B'
            WHEN hr = 1 THEN 'HR'
            WHEN
                sh = 1
                THEN IF(
                        basic_event = 'FC',
                        'FC' || ';' || IF(outs_pre < outs_post, 'O', 'NO'),
                        basic_event
                    )
            WHEN sf = 1 THEN 'SF' || basic_event
            WHEN hbp = 1 THEN 'HBP'
            WHEN ibb = 1 THEN 'IBB'
            WHEN bb = 1 THEN 'BB'
            WHEN k_safe = 1 THEN 'K;B-1'
            WHEN k = 1 THEN 'K'
            WHEN xi = 1 THEN 'XI'
            WHEN roe = 1 THEN basic_event
            WHEN fc = 1 THEN 'FC' || ';' || IF(outs_pre < outs_post, 'O', 'NO')
            WHEN other_out = 1 THEN basic_event
            WHEN other_no_out = 1 THEN 'OTHER'
            ELSE basic_event
        END AS event_type

    FROM filtered
)

SELECT
    *,
    MIN(game_date) OVER (PARTITION BY game_id) AS game_start_date,
    ROW_NUMBER() OVER (PARTITION BY game_id ORDER BY play_number) AS event_index
FROM categorized_events
QUALIFY event_index <= 60
;
