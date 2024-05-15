with source as (
    select * from {{ source('raw', 'retrosheet_events') }}
)

select
    game_id
    , away_team_id
    , inn_ct as inning
    , bat_home_id = 1 as is_bat_home
    , outs_ct as outs
    , balls_ct as balls
    , strikes_ct as strikes
    , pitch_seq_tx
    , away_score_ct as away_score
    , home_score_ct as home_score
    , bat_id
    , bat_hand_cd
    , resp_bat_id
    , resp_bat_hand_cd
    , pit_id
    , pit_hand_cd
    , resp_pit_id
    , resp_pit_hand_cd
    , pos2_fld_id
    , pos3_fld_id
    , pos4_fld_id
    , pos5_fld_id
    , pos6_fld_id
    , pos7_fld_id
    , pos8_fld_id
    , pos9_fld_id
    , base1_run_id
    , base2_run_id
    , base3_run_id
    , event_tx
    , leadoff_fl = 'T' as is_leadoff
    , ph_fl = 'T' as is_ph
    , bat_fld_cd
    , bat_lineup_id
    , event_cd
    , bat_event_fl = 'T' as is_bat_event
    , ab_fl = 'T' as is_ab
    , h_cd
    , sh_fl = 'T' as is_sh
    , sf_fl = 'T' as is_sf
    , event_outs_ct
    , dp_fl = 'T' as is_dp
    , tp_fl = 'T' as is_tp
    , rbi_ct as rbi
    , wp_fl = 'T' as is_wp
    , pb_fl = 'T' as is_pb
    , fld_cd
    , battedball_cd
    , bunt_fl = 'T' as is_bunt
    , foul_fl = 'T' as is_foul
    , battedball_loc_tx
    , err_ct as errors
    , err1_fld_cd
    , err1_cd
    , err2_fld_cd
    , err2_cd
    , err3_fld_cd
    , err3_cd
    , bat_dest_id as bat_dest
    , run1_dest_id as run1_dest
    , run2_dest_id as run2_dest
    , run3_dest_id as run3_dest
    , bat_play_tx
    , run1_play_tx
    , run2_play_tx
    , run3_play_tx
    , run1_sb_fl = 'T' as is_run1_sb
    , run2_sb_fl = 'T' as is_run2_sb
    , run3_sb_fl = 'T' as is_run3_sb
    , run1_cs_fl = 'T' as is_run1_cs
    , run2_cs_fl = 'T' as is_run2_cs
    , run3_cs_fl = 'T' as is_run3_cs
    , run1_pk_fl = 'T' as is_run1_pk
    , run2_pk_fl = 'T' as is_run2_pk
    , run3_pk_fl = 'T' as is_run3_pk
    , run1_resp_pit_id
    , run2_resp_pit_id
    , run3_resp_pit_id
    , game_new_fl = 'T' as is_game_new
    , game_end_fl = 'T' as is_game_end
    , pr_run1_fl = 'T' as is_pr_run1
    , pr_run2_fl = 'T' as is_pr_run2
    , pr_run3_fl = 'T' as is_pr_run3
    , removed_for_pr_run1_id
    , removed_for_pr_run2_id
    , removed_for_pr_run3_id
    , removed_for_ph_bat_id
    , removed_for_ph_bat_fld_cd
    , po1_fld_cd
    , po2_fld_cd
    , po3_fld_cd
    , ass1_fld_cd
    , ass2_fld_cd
    , ass3_fld_cd
    , ass4_fld_cd
    , ass5_fld_cd
    , event_id
    , home_team_id
    , bat_team_id
    , fld_team_id
    , bat_last_id
    , inn_new_fl = 'T' as is_inn_new
    , inn_end_fl = 'T' as is_inn_end
    , start_bat_score_ct as start_bat_score
    , start_fld_score_ct as start_fld_score
    , inn_runs_ct as inn_runs
    , game_pa_ct as game_pa
    , inn_pa_ct as inn_pa
    , pa_new_fl = 'T' as is_pa_new
    , pa_trunc_fl = 'T' as is_pa_trunc
    , start_bases_cd
    , end_bases_cd
    , bat_start_fl = 'T' as is_bat_start
    , resp_bat_start_fl = 'T' as is_resp_bat_start
    , bat_on_deck_id
    , bat_in_hold_id
    , pit_start_fl = 'T' as is_pit_start
    , resp_pit_start_fl = 'T' as is_resp_pit_start
    , run1_fld_cd
    , run1_lineup_cd
    , run1_origin_event_id
    , run2_fld_cd
    , run2_lineup_cd
    , run2_origin_event_id
    , run3_fld_cd
    , run3_lineup_cd
    , run3_origin_event_id
    , run1_resp_cat_id
    , run2_resp_cat_id
    , run3_resp_cat_id
    , pa_ball_ct as pa_ball
    , pa_called_ball_ct as pa_called_balls
    , pa_intent_ball_ct as pa_intent_balls
    , pa_pitchout_ball_ct as pa_pitchout_balls
    , pa_hitbatter_ball_ct as pa_hitbatter_balls
    , pa_other_ball_ct as pa_other_balls
    , pa_strike_ct as pa_strikes
    , pa_called_strike_ct as pa_called_strikes
    , pa_swingmiss_strike_ct as pa_swingmiss_strikes
    , pa_foul_strike_ct as pa_foul_strikes
    , pa_inplay_strike_ct as pa_inplay_strikes
    , pa_other_strike_ct as pa_other_strikes
    , event_runs_ct as event_runs
    , fld_id
    , base2_force_fl = 'T' as is_base2_force
    , base3_force_fl = 'T' as is_base3_force
    , base4_force_fl = 'T' as is_base4_force
    , bat_safe_err_fl = 'T' as is_bat_safe_err
    , bat_fate_id
    , run1_fate_id
    , run2_fate_id
    , run3_fate_id
    , fate_runs_ct as fate_runs
    , ass6_fld_cd
    , ass7_fld_cd
    , ass8_fld_cd
    , ass9_fld_cd
    , ass10_fld_cd
    , unknown_out_exc_fl = 'T' as is_unknown_out_exc
    , uncertain_play_exc_fl = 'T' as is_uncertain_play_exc
    , count_tx 
    , {{ dbt_utils.generate_surrogate_key(['game_id', 'event_id']) }} as unique_id
from source
