import datetime
import duckdb
import typing

from pathlib import Path

from baseball_db.constants import DATABASE_NAME


StrDate = typing.Union[str, datetime.date]


class Statcast:
    """Load Statcast data.
    
    Attributes
    ----------
    data_dir : pathlib.PosixPath
        Directory for downloaded files.
    """
    FIELD_DTYPES = {
        'pitch_type': 'VARCHAR',
        'game_date': 'DATE',
        'release_speed': 'DECIMAL(9, 4)',
        'release_pos_x': 'DECIMAL(9, 4)',
        'release_pos_z': 'DECIMAL(9, 4)',
        'player_name': 'VARCHAR',
        'batter': 'INTEGER',
        'pitcher': 'INTEGER',
        'events': 'VARCHAR',
        'description': 'VARCHAR',
        'spin_dir': 'VARCHAR',
        'spin_rate_deprecated': 'VARCHAR',
        'break_angle_deprecated': 'VARCHAR',
        'break_length_deprecated': 'VARCHAR',
        'zone': 'TINYINT',
        'des': 'VARCHAR',
        'game_type': 'VARCHAR',
        'stand': 'VARCHAR',
        'p_throws': 'VARCHAR',
        'home_team': 'VARCHAR',
        'away_team': 'VARCHAR',
        'type': 'VARCHAR',
        'hit_location': 'TINYINT',
        'bb_type': 'VARCHAR',
        'balls': 'TINYINT',
        'strikes': 'TINYINT',
        'game_year': 'SMALLINT',
        'pfx_x': 'DECIMAL(9, 4)',
        'pfx_z': 'DECIMAL(9, 4)',
        'plate_x': 'DECIMAL(9, 4)',
        'plate_z': 'DECIMAL(9, 4)',
        'on_3b': 'INTEGER',
        'on_2b': 'INTEGER',
        'on_1b': 'INTEGER',
        'outs_when_up': 'TINYINT',
        'inning': 'TINYINT',
        'inning_topbot': 'VARCHAR',
        'hc_x': 'DECIMAL(9, 4)',
        'hc_y': 'DECIMAL(9, 4)',
        'tfs_deprecated': 'VARCHAR',
        'tfs_zulu_deprecated': 'VARCHAR',
        'umpire': 'VARCHAR',
        'sv_id': 'VARCHAR',
        'vx0': 'DECIMAL(18, 15)',
        'vy0': 'DECIMAL(18, 15)',
        'vz0': 'DECIMAL(18, 15)',
        'ax': 'DECIMAL(18, 15)',
        'ay': 'DECIMAL(18, 15)',
        'az': 'DECIMAL(18, 15)',
        'sz_top': 'DECIMAL(9, 4)',
        'sz_bot': 'DECIMAL(9, 4)',
        'hit_distance_sc': 'INTEGER',
        'launch_speed': 'DECIMAL(9, 4)',
        'launch_angle': 'INTEGER',
        'effective_speed': 'DECIMAL(9, 4)',
        'release_spin_rate': 'INTEGER',
        'release_extension': 'DECIMAL(9, 4)',
        'game_pk': 'INTEGER',
        'fielder_2': 'INTEGER',
        'fielder_3': 'INTEGER',
        'fielder_4': 'INTEGER',
        'fielder_5': 'INTEGER',
        'fielder_6': 'INTEGER',
        'fielder_7': 'INTEGER',
        'fielder_8': 'INTEGER',
        'fielder_9': 'INTEGER',
        'release_pos_y': 'DECIMAL(9, 4)',
        'estimated_ba_using_speedangle': 'DECIMAL(9, 4)',
        'estimated_woba_using_speedangle': 'DECIMAL(9, 4)',
        'woba_value': 'DECIMAL(9, 4)',
        'woba_denom': 'SMALLINT',
        'babip_value': 'SMALLINT',
        'iso_value': 'SMALLINT',
        'launch_speed_angle': 'SMALLINT',
        'at_bat_number': 'SMALLINT',
        'pitch_number': 'SMALLINT',
        'pitch_name': 'VARCHAR',
        'home_score': 'SMALLINT',
        'away_score': 'SMALLINT',
        'bat_score': 'SMALLINT',
        'fld_score': 'SMALLINT',
        'post_away_score': 'SMALLINT',
        'post_home_score': 'SMALLINT',
        'post_bat_score': 'SMALLINT',
        'post_fld_score': 'SMALLINT',
        'if_fielding_alignment': 'VARCHAR',
        'of_fielding_alignment': 'VARCHAR',
        'spin_axis': 'SMALLINT',
        'delta_home_win_exp': 'DECIMAL(9, 4)',
        'delta_run_exp': 'DECIMAL(9, 4)',
        'bat_speed': 'DECIMAL(9, 4)',
        'swing_length': 'DECIMAL(9, 4)',
        'miss_distance': 'DECIMAL(9, 4)',
        'estimated_slg_using_speedangle': 'DECIMAL(9, 4)',
        'delta_pitcher_run_exp': 'DECIMAL(9, 4)',
        'hyper_speed': 'DECIMAL(9, 4)',
        'home_score_diff': 'TINYINT',
        'bat_score_diff': 'TINYINT',
        'home_win_exp': 'DECIMAL(9, 4)',
        'bat_win_exp': 'DECIMAL(9, 4)',
        'age_pit_legacy': 'TINYINT',
        'age_bat_legacy': 'TINYINT',
        'age_pit': 'TINYINT',
        'age_bat': 'TINYINT',
        'n_thruorder_pitcher': 'TINYINT',
        'n_priorpa_thisgame_player_at_bat': 'TINYINT',
        'pitcher_days_since_prev_game': 'SMALLINT',
        'batter_days_since_prev_game': 'SMALLINT',
        'pitcher_days_until_next_game': 'SMALLINT',
        'batter_days_until_next_game': 'SMALLINT',
        'api_break_z_with_gravity': 'DECIMAL(9, 4)',
        'api_break_x_arm': 'DECIMAL(9, 4)',
        'api_break_x_batter_in': 'DECIMAL(9, 4)',
        'arm_angle': 'DECIMAL(9, 4)',
        'attack_angle': 'DECIMAL(18, 15)',
        'attack_direction': 'DECIMAL(18, 15)',
        'swing_path_tilt': 'DECIMAL(18, 15)',
        'intercept_ball_minus_batter_pos_x_inches': 'DECIMAL(18, 15)',
        'intercept_ball_minus_batter_pos_y_inches': 'DECIMAL(18, 15)',
    }

    def __init__(self, data_dir: str = 'data') -> None:
        self.data_dir = Path(data_dir) / 'statcast'
        self.data_dir.mkdir(parents=True, exist_ok=True)

    def create_table(self) -> None:
        """Create the raw.statcast table."""
        fields_sql = ",\n".join([f"{field} {dtype}" for field, dtype in self.FIELD_DTYPES.items()])

        sql = f"""
            CREATE TABLE IF NOT EXISTS raw.statcast (
                {fields_sql},
                PRIMARY KEY (game_pk, at_bat_number, pitch_number)
            );
        """

        con = duckdb.connect(DATABASE_NAME)
        con.execute(sql)
        con.close()

    def load(self, years: int | list[int]) -> None:
        """Load Statcast CSVs into raw.statcast table.
        
        If there the primary key (game_pk, at_bat_number, pitch_number) already
        exists in the table, the old record is deleted and the new record is
        inserted.

        Parameters
        ----------
        years: int or list of ints
            Seasons of CSVs to load. Each season should have its own folder
            of CSVs in the data directory.
        """
        years = [years] if isinstance(years, int) else years

        con = duckdb.connect(DATABASE_NAME)

        for year in years:
            filepaths = sorted(self.data_dir.glob(f'**/{year}/*.csv'))
            filepaths = [str(p) for p in filepaths]

            sql = f"""
                CREATE TABLE raw.temp_statcast AS

                    SELECT *
                    FROM read_csv(
                        {filepaths},
                        header = true,
                        union_by_name = true,
                        types = {self.FIELD_DTYPES}
                    );
            """
            con.execute(sql)

            con.execute("""
                ALTER TABLE raw.temp_statcast
                ADD PRIMARY KEY (game_pk, at_bat_number, pitch_number);
            """)
            
            con.execute("""
                INSERT OR REPLACE INTO raw.statcast
                SELECT * FROM raw.temp_statcast;
            """)

            con.execute("DROP TABLE raw.temp_statcast;")

        con.close()
