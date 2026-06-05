{{ config(materialized = 'table') }}

WITH prep_statcast AS (
    SELECT * FROM {{ ref('prep_statcast') }}
),

batter_dates AS (
    SELECT DISTINCT
        batter_id,
        game_date
    FROM prep_statcast
),

stands AS (
    SELECT
        batter_id,
        batter_stands,

        COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY batter_id) AS stands_pct

    FROM prep_statcast
    GROUP BY 1, 2
    QUALIFY stands_pct > 0.1
),

batter_spine AS (
    SELECT
        batter_dates.batter_id,
        batter_dates.game_date,
        stands.batter_stands
    FROM batter_dates
    INNER JOIN stands
        ON batter_dates.batter_id = stands.batter_id
),

{% set launch_feature_funcs = [
    ['SUM(launch_speed)', 'launch_speed_sum'],
    ['SUM(launch_angle)', 'launch_angle_sum'],
    ['COUNT(*)', 'obs_count']
]%}

launch_features AS (
    SELECT
        batter_id,
        batter_stands,

        game_date,
        game_id,
        game_pa_number,

        {% for func, field_name in launch_feature_funcs %}
            {{ func }} OVER (
                PARTITION BY batter_id, batter_stands
                ORDER BY game_date, game_id, game_pa_number
                ROWS BETWEEN 99 PRECEDING AND CURRENT ROW
            ) AS {{ field_name }},
        {% endfor %}

        launch_speed_sum / obs_count AS last_100_avg_launch_speed,
        launch_angle_sum / obs_count AS last_100_avg_launch_angle

    FROM prep_statcast
    WHERE launch_speed IS NOT NULL
        AND launch_angle IS NOT NULL

    /* Get the last observation for each batter date */
    QUALIFY ROW_NUMBER() OVER (PARTITION BY batter_id, batter_stands, game_date ORDER BY game_id DESC, game_pa_number DESC) = 1
),

{% set spray_feature_funcs = [
    ['SUM(IF(spray_angle < -15, 1, 0))', 'spray_left_count'],
    ['SUM(IF(-15 < spray_angle AND spray_angle < 15, 1, 0))', 'spray_center_count'],
    ['SUM(IF(15 < spray_angle, 1, 0))', 'spray_right_count'],
    ['COUNT(*)', 'obs_count']
]%}

spray_features AS (
    SELECT
        batter_id,
        batter_stands,
        bb_type = 'ground_ball' AS is_ground_ball,

        game_date,
        game_pa_number,

        {% for func, field_name in spray_feature_funcs %}
            {{ func }} OVER (
                PARTITION BY batter_id, is_ground_ball
                ORDER BY game_date, game_id, game_pa_number
                ROWS BETWEEN 99 PRECEDING AND CURRENT ROW
            ) AS {{ field_name }},
        {% endfor %}

        spray_left_count / obs_count AS last_100_spray_left_pct,
        spray_center_count / obs_count AS last_100_spray_center_pct,
        spray_right_count / obs_count AS last_100_spray_right_pct

    FROM prep_statcast
    WHERE hc_x IS NOT NULL
        AND hc_y IS NOT NULL

    /* Get the last observation for each batter date */
    QUALIFY ROW_NUMBER() OVER (PARTITION BY batter_id, is_ground_ball, batter_stands, game_date ORDER BY game_id DESC, game_pa_number DESC) = 1
),

joined_features AS (
    SELECT
        batter_spine.batter_id,
        batter_spine.game_date,
        batter_spine.batter_stands,

        launch_features.obs_count AS launch_obs_count,
        launch_features.last_100_avg_launch_speed,
        launch_features.last_100_avg_launch_angle,

        air_spray.obs_count AS air_obs_count,
        air_spray.last_100_spray_left_pct AS last_100_air_spray_left_pct,
        air_spray.last_100_spray_center_pct AS last_100_air_spray_center_pct,
        air_spray.last_100_spray_right_pct AS last_100_air_spray_right_pct,

        ground_spray.obs_count AS ground_obs_count,
        ground_spray.last_100_spray_left_pct AS last_100_ground_spray_left_pct,
        ground_spray.last_100_spray_center_pct AS last_100_ground_spray_center_pct,
        ground_spray.last_100_spray_right_pct AS last_100_ground_spray_right_pct

    FROM batter_spine
    LEFT JOIN launch_features
        ON batter_spine.batter_id = launch_features.batter_id
        AND batter_spine.game_date = launch_features.game_date
        AND batter_spine.batter_stands = launch_features.batter_stands
    LEFT JOIN spray_features AS air_spray
        ON batter_spine.batter_id = air_spray.batter_id
        AND batter_spine.game_date = air_spray.game_date
        AND batter_spine.batter_stands = air_spray.batter_stands
        AND NOT air_spray.is_ground_ball
    LEFT JOIN spray_features AS ground_spray
        ON batter_spine.batter_id = ground_spray.batter_id
        AND batter_spine.game_date = ground_spray.game_date
        AND batter_spine.batter_stands = ground_spray.batter_stands
        AND ground_spray.is_ground_ball
),

{% set final_fields = [
    'launch_obs_count',
    'last_100_avg_launch_speed',
    'last_100_avg_launch_angle',
    'air_obs_count',
    'last_100_air_spray_left_pct',
    'last_100_air_spray_center_pct',
    'last_100_air_spray_right_pct',
    'ground_obs_count',
    'last_100_ground_spray_left_pct',
    'last_100_ground_spray_center_pct',
    'last_100_ground_spray_right_pct'
]%}

filled_nulls AS (
    SELECT
        batter_id,
        game_date,
        batter_stands,

        {% for field in final_fields %}
            COALESCE(
                {{ field }},
                LAG({{ field }} IGNORE NULLS) OVER (PARTITION BY batter_id, batter_stands ORDER BY game_date)
            ) AS {{ field }}
            {%- if not loop.last -%} , {%- endif %}
        {% endfor %}

    FROM joined_features

),

final AS (
    SELECT
        batter_id,
        game_date,
        batter_stands,

        launch_obs_count,
        last_100_avg_launch_speed,
        last_100_avg_launch_angle,

        air_obs_count,
        last_100_air_spray_left_pct,
        last_100_air_spray_center_pct,
        last_100_air_spray_right_pct,

        ground_obs_count,
        last_100_ground_spray_left_pct,
        last_100_ground_spray_center_pct,
        last_100_ground_spray_right_pct
    
    FROM filled_nulls
)

SELECT *
FROM final
