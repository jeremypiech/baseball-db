with source as (
    select * from {{ source('raw', 'retrosheet_games') }}
)

select
    game_id
    , strptime(game_dt, '%Y%m%d') :: date as game_date
    , game_ct as game_date_count
    -- , game_dy
    , nullif(start_game_tm, '0') as start_time
    , dh_fl = 'T' as has_dh
    , daynight_park_cd
    , away_team_id
    , home_team_id
    , park_id
    , away_start_pit_id
    , home_start_pit_id
    , base4_ump_id
    , base1_ump_id
    , base2_ump_id
    , base3_ump_id
    , lf_ump_id
    , rf_ump_id
    , attend_park_ct as attendance
    -- , scorer_record_id
    -- , translator_record_id
    -- , inputter_record_id
    -- , input_record_ts
    -- , edit_record_ts
    -- , method_record_cd
    -- , pitches_record_cd
    , nullif(temp_park_ct, 0) as temperature
    , wind_direction_park_cd
    , nullif(wind_speed_park_ct, -1) as wind_speed_mph
    , field_park_cd
    , precip_park_cd
    , sky_park_cd
    , minutes_game_ct as gametime_min
    , inn_ct as innings
    , away_score_ct as away_score
    , home_score_ct as home_score
    , away_hits_ct as away_hits
    , home_hits_ct as home_hits
    , away_err_ct as away_err
    , home_err_ct as home_err
    , away_lob_ct as away_lob
    , home_lob_ct as home_lob
    , win_pit_id
    , lose_pit_id
    , save_pit_id
    , gwrbi_bat_id
    , away_lineup1_bat_id
    , away_lineup1_fld_cd
    , away_lineup2_bat_id
    , away_lineup2_fld_cd
    , away_lineup3_bat_id
    , away_lineup3_fld_cd
    , away_lineup4_bat_id
    , away_lineup4_fld_cd
    , away_lineup5_bat_id
    , away_lineup5_fld_cd
    , away_lineup6_bat_id
    , away_lineup6_fld_cd
    , away_lineup7_bat_id
    , away_lineup7_fld_cd
    , away_lineup8_bat_id
    , away_lineup8_fld_cd
    , away_lineup9_bat_id
    , away_lineup9_fld_cd
    , home_lineup1_bat_id
    , home_lineup1_fld_cd
    , home_lineup2_bat_id
    , home_lineup2_fld_cd
    , home_lineup3_bat_id
    , home_lineup3_fld_cd
    , home_lineup4_bat_id
    , home_lineup4_fld_cd
    , home_lineup5_bat_id
    , home_lineup5_fld_cd
    , home_lineup6_bat_id
    , home_lineup6_fld_cd
    , home_lineup7_bat_id
    , home_lineup7_fld_cd
    , home_lineup8_bat_id
    , home_lineup8_fld_cd
    , home_lineup9_bat_id
    , home_lineup9_fld_cd
    , away_finish_pit_id
    , home_finish_pit_id

from source
