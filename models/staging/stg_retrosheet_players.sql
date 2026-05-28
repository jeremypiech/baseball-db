WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_allplayers') }}
)

SELECT
    ---------- primary
    {{ dbt_utils.generate_surrogate_key(['id', 'team', 'season']) }} AS unique_key,

    id AS player_id,
    team AS team_id,
    season,

    first AS first_name,
    last AS last_name,

    bat AS bats,
    throw AS throws,

    ----------- attributes
    g,
    g_p,
    g_sp,
    g_rp,
    g_c,
    g_1b,
    g_2b,
    g_3b,
    g_ss,
    g_lf,
    g_cf,
    g_rf,
    g_of,
    g_dh,
    g_ph,
    g_pr,

    first_g AS first_game_date,
    last_g AS last_game_date

FROM source
