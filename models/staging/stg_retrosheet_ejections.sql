WITH source AS (
    SELECT * FROM {{ source('raw', 'retrosheet_ejections') }}
)

SELECT DISTINCT
    /* There is one duplicate record in the source data:
       game_id: BSN192204250, ejectee_id: mitcf101 */

    ---------- primary
    {{ dbt_utils.generate_surrogate_key(['gameid', 'ejectee']) }} AS unique_key,

    gameid AS game_id,

    STRPTIME(date, '%m/%d/%Y')::DATE AS game_date,
    COALESCE(dh, 1) AS date_game_number,

    ejectee AS ejectee_id,
    ejecteename AS ejectee_name,
    job AS ejectee_role,

    ---------- foreign keys
    team AS team_id,
    umpire AS umpire_id,

    ---------- attributes
    umpirename AS umpire_name,
    inning,
    reason

FROM source
