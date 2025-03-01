import datetime
import duckdb
import os
import requests
import typing

from pathlib import Path

from baseball_db.utils import date_range


DATABASE_NAME = os.getenv('BASEBALL_DB_NAME', 'baseball.db')
StrDate = typing.Union[str, datetime.date]


class Statcast:
    """Extract and load Statcast data.
    
    Attributes
    ----------
    raw_dir : pathlib.PosixPath
        Directory for downloaded files.
    """
    DEFAULT_URL_PARAMS = {
        'all': 'true',
        'hfPT': '',
        'hfAB': '',
        'hfBBT': '',
        'hfPR': '',
        'hfZ': '',
        'stadium': '',
        'hfBBL': '',
        'hfNewZones': '',
        'hfGT': 'R|PO|S|',
        'hfSea': '',
        'hfC': '',
        'hfSit': '',
        'hfOuts': '',
        'opponent': '',
        'pitcher_throws': '',
        'batter_stands': '',
        'hfSA': '',
        'hfInfield': '',
        'team': '',
        'position': '',
        'hfOutfield': '',
        'hfRO': '',
        'home_road': '',
        'game_date_gt': '',
        'game_date_lt': '',
        'hfFlag': '',
        'hfPull': '',
        'metric_1': '',
        'hfInn': '',
        'min_pitches': '0',
        'min_results': '0',
        'group_by': 'name',
        'sort_col': 'pitches',
        'player_event_sort': 'h_launch_speed',
        'sort_order': 'asc',
        'min_pas': '0',
        'type': 'details',
    }
    
    FIELD_DTYPES = {
        'pitch_type': 'VARCHAR',
        'game_date': 'DATE',
        'release_speed': 'DECIMAL(18,8)',
        'release_pos_x': 'DECIMAL(18,8)',
        'release_pos_z': 'DECIMAL(18,8)',
        'player_name': 'VARCHAR',
        'batter': 'BIGINT',
        'pitcher': 'BIGINT',
        'events': 'VARCHAR',
        'description': 'VARCHAR',
        'spin_dir': 'VARCHAR',
        'spin_rate_deprecated': 'VARCHAR',
        'break_angle_deprecated': 'VARCHAR',
        'break_length_deprecated': 'VARCHAR',
        'zone': 'BIGINT',
        'des': 'VARCHAR',
        'game_type': 'VARCHAR',
        'stand': 'VARCHAR',
        'p_throws': 'VARCHAR',
        'home_team': 'VARCHAR',
        'away_team': 'VARCHAR',
        'type': 'VARCHAR',
        'hit_location': 'BIGINT',
        'bb_type': 'VARCHAR',
        'balls': 'BIGINT',
        'strikes': 'BIGINT',
        'game_year': 'BIGINT',
        'pfx_x': 'DECIMAL(18,8)',
        'pfx_z': 'DECIMAL(18,8)',
        'plate_x': 'DECIMAL(18,8)',
        'plate_z': 'DECIMAL(18,8)',
        'on_3b': 'BIGINT',
        'on_2b': 'BIGINT',
        'on_1b': 'BIGINT',
        'outs_when_up': 'BIGINT',
        'inning': 'BIGINT',
        'inning_topbot': 'VARCHAR',
        'hc_x': 'DECIMAL(18,8)',
        'hc_y': 'DECIMAL(18,8)',
        'tfs_deprecated': 'VARCHAR',
        'tfs_zulu_deprecated': 'VARCHAR',
        'fielder_2': 'BIGINT',
        'umpire': 'VARCHAR',
        'sv_id': 'VARCHAR',
        'vx0': 'DECIMAL(18,8)',
        'vy0': 'DECIMAL(18,8)',
        'vz0': 'DECIMAL(18,8)',
        'ax': 'DECIMAL(18,8)',
        'ay': 'DECIMAL(18,8)',
        'az': 'DECIMAL(18,8)',
        'sz_top': 'DECIMAL(18,8)',
        'sz_bot': 'DECIMAL(18,8)',
        'hit_distance_sc': 'BIGINT',
        'launch_speed': 'DECIMAL(18,8)',
        'launch_angle': 'BIGINT',
        'effective_speed': 'DECIMAL(18,8)',
        'release_spin_rate': 'BIGINT',
        'release_extension': 'DECIMAL(18,8)',
        'game_pk': 'BIGINT',
        'pitcher_1': 'BIGINT',
        'fielder_2_1': 'BIGINT',
        'fielder_3': 'BIGINT',
        'fielder_4': 'BIGINT',
        'fielder_5': 'BIGINT',
        'fielder_6': 'BIGINT',
        'fielder_7': 'BIGINT',
        'fielder_8': 'BIGINT',
        'fielder_9': 'BIGINT',
        'release_pos_y': 'DECIMAL(18,8)',
        'estimated_ba_using_speedangle': 'DECIMAL(18,8)',
        'estimated_woba_using_speedangle': 'DECIMAL(18,8)',
        'woba_value': 'DECIMAL(18,8)',
        'woba_denom': 'BIGINT',
        'babip_value': 'BIGINT',
        'iso_value': 'BIGINT',
        'launch_speed_angle': 'BIGINT',
        'at_bat_number': 'BIGINT',
        'pitch_number': 'BIGINT',
        'pitch_name': 'VARCHAR',
        'home_score': 'BIGINT',
        'away_score': 'BIGINT',
        'bat_score': 'BIGINT',
        'fld_score': 'BIGINT',
        'post_away_score': 'BIGINT',
        'post_home_score': 'BIGINT',
        'post_bat_score': 'BIGINT',
        'post_fld_score': 'BIGINT',
        'if_fielding_alignment': 'VARCHAR',
        'of_fielding_alignment': 'VARCHAR',
        'spin_axis': 'BIGINT',
        'delta_home_win_exp': 'DECIMAL(18,8)',
        'delta_run_exp': 'DECIMAL(18,8)',
        'bat_speed': 'DECIMAL(18,14)',
        'swing_length': 'DECIMAL(18,8)',
        'estimated_slg_using_speedangle': 'DECIMAL(18,8)',
        'delta_pitcher_run_exp': 'DECIMAL(18,8)',
        'hyper_speed': 'DECIMAL(18,8)',
        'home_score_diff': 'SMALLINT',
        'bat_score_diff': 'SMALLINT',
        'home_win_exp': 'DECIMAL(18,8)',
        'bat_win_exp': 'DECIMAL(18,8)',
        'age_pit_legacy': 'SMALLINT',
        'age_bat_legacy': 'SMALLINT',
        'n_thruorder_pitcher': 'SMALLINT',
        'n_priorpa_thisgame_player_at_bat': 'SMALLINT',
        'pitcher_days_since_prev_game': 'SMALLINT',
        'batter_days_since_prev_game': 'SMALLINT',
        'pitcher_days_until_next_game': 'SMALLINT',
        'batter_days_until_next_game': 'SMALLINT',
        'api_break_z_with_gravity': 'DECIMAL(18,8)',
        'api_break_x_arm': 'DECIMAL(18,8)',
        'api_break_x_batter_in': 'DECIMAL(18,8)',
        'arm_angle': 'DECIMAL(18,8)',
    }

    def __init__(self, data_dir = 'data') -> None:
        data_dir = Path(data_dir)
        self.raw_dir = data_dir / 'raw' / 'statcast'

        # Create directory if it does not exist
        self.raw_dir.mkdir(parents=True, exist_ok=True)

    def search(
            self,
            start_date: StrDate = (datetime.date.today() - datetime.timedelta(days=1)),
            end_date: StrDate = (datetime.date.today() - datetime.timedelta(days=1)),
            player_type: str = 'pitcher',
        ) -> bytes:
        """Search MLB.com's Statcast database.

        *Don't query for more than 3-4 days*

        Parameters
        ----------
        start_date : str or datetime.date
            Start date, inclusive. If str, must use ISO format (YYYY-MM-DD).
        end_date : str or datetime.date
            End date, inclusive. If str, must use ISO format (YYYY-MM-DD).
        player_type : str, default = "pitcher"
            "pitcher" or "batter"
        url_params : dict
        """
        start_date = datetime.date.fromisoformat(start_date) if isinstance(start_date, str) else start_date
        end_date = datetime.date.fromisoformat(end_date) if isinstance(end_date, str) else end_date

        params = self.DEFAULT_URL_PARAMS.copy()
        params['hfSea'] = f'{start_date.year}|'
        params['game_date_gt'] = f'{start_date:%Y-%m-%d}'
        params['game_date_lt'] = f'{end_date:%Y-%m-%d}'
        params['player_type'] = player_type

        url = 'https://baseballsavant.mlb.com/statcast_search/csv'
        resp = requests.get(url, params=params)

        return resp.content

    def extract(
            self,
            start_date: StrDate = (datetime.date.today() - datetime.timedelta(days=1)),
            end_date: StrDate = (datetime.date.today() - datetime.timedelta(days=1)),
            days_step: int = 1,
        ) -> None:

        start_date = datetime.date.fromisoformat(start_date) if isinstance(start_date, str) else start_date
        end_date = datetime.date.fromisoformat(end_date) if isinstance(end_date, str) else end_date

        search_start_dates = date_range(start_date, end_date, days_step)
        for start in search_start_dates:
            end = min(start + datetime.timedelta(days=days_step - 1), end_date)

            print(f'Searching {start:%Y-%m-%d} - {end:%Y-%m-%d}')
            content = self.search(start, end)

            filename = (
                f'statcast-{start:%Y-%m-%d}.csv'
                if start == end
                else f'statcast-{start:%Y-%m-%d}-{end:%Y-%m-%d}.csv'
            )

            filepath = self.raw_dir / filename
            with open(filepath, 'wb') as f:
                f.write(content)

    def _create_table(self) -> None:
        fields_sql = ", ".join(" ".join(x) for x in self.FIELD_DTYPES.items())
        sql = f'create table if not exists raw.statcast({fields_sql});'

        con = duckdb.connect(DATABASE_NAME)
        con.execute(sql)
        con.close()

    def load_file(self, filename: str) -> None:
        filepath = self.raw_dir / filename
        sql = f"copy raw.statcast from '{filepath}' (header);"

        con = duckdb.connect(DATABASE_NAME)
        con.execute(sql)
        con.close()

    def load_season(self, year: int) -> None:
        con = duckdb.connect(DATABASE_NAME)

        # Copy CSV to table
        filepaths = sorted(self.raw_dir.glob(f'statcast-{year}*.csv'))
        for filepath in filepaths:
            sql = f"copy raw.statcast from '{filepath}' (header);"
            con.execute(sql)

        con.close()

    def extract_load(
            self,
            start_date: StrDate = (datetime.date.today() - datetime.timedelta(days=1)),
            end_date: StrDate = (datetime.date.today() - datetime.timedelta(days=1)),
            days_step: int = 1,
        ) -> None:

        start_date = datetime.date.fromisoformat(start_date) if isinstance(start_date, str) else start_date
        end_date = datetime.date.fromisoformat(end_date) if isinstance(end_date, str) else end_date

        self.extract(start_date, end_date)

        filename_start_dates = date_range(start_date, end_date, days_step)
        for start in filename_start_dates:
            for filepath in self.raw_dir.glob(f'statcast-{start:%Y-%m-%d}*'):
                self.load_file(filepath.name)
