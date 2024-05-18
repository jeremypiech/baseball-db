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
        'hfGT': 'R|PO|',
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
        'pitch_type': 'VARCHAR',  # VARCHAR
        'game_date': 'DATE',  # DATE
        'release_speed': 'DECIMAL(18,8)',  # NUMERIC
        'release_pos_x': 'DECIMAL(18,8)',  # NUMERIC
        'release_pos_z': 'DECIMAL(18,8)',  # NUMERIC
        'player_name': 'VARCHAR',  # VARCHAR
        'batter': 'BIGINT',  # INTEGER
        'pitcher': 'BIGINT',  # INTEGER
        'events': 'VARCHAR',  # VARCHAR
        'description': 'VARCHAR',  # TEXT
        'spin_dir': 'VARCHAR',  # NUMERIC
        'spin_rate_deprecated': 'VARCHAR',  # NUMERIC
        'break_angle_deprecated': 'VARCHAR',  # NUMERIC
        'break_length_deprecated': 'VARCHAR',  # NUMERIC
        'zone': 'BIGINT',  # SMALLINT
        'des': 'VARCHAR',  # TEXT
        'game_type': 'VARCHAR',  # VARCHAR
        'stand': 'VARCHAR',  # VARCHAR
        'p_throws': 'VARCHAR',  # VARCHAR
        'home_team': 'VARCHAR',  # VARCHAR
        'away_team': 'VARCHAR',  # VARCHAR
        'type': 'VARCHAR',  # VARCHAR
        'hit_location': 'BIGINT',  # SMALLINT
        'bb_type': 'VARCHAR',  # VARCHAR
        'balls': 'BIGINT',  # SMALLINT
        'strikes': 'BIGINT',  # SMALLINT
        'game_year': 'BIGINT',  # SMALLINT
        'pfx_x': 'DECIMAL(18,8)',  # NUMERIC
        'pfx_z': 'DECIMAL(18,8)',  # NUMERIC
        'plate_x': 'DECIMAL(18,8)',  # NUMERIC
        'plate_z': 'DECIMAL(18,8)',  # NUMERIC
        'on_3b': 'BIGINT',  # INTEGER
        'on_2b': 'BIGINT',  # INTEGER
        'on_1b': 'BIGINT',  # INTEGER
        'outs_when_up': 'BIGINT',  # SMALLINT
        'inning': 'BIGINT',  # SMALLINT
        'inning_topbot': 'VARCHAR',  # VARCHAR
        'hc_x': 'DECIMAL(18,8)',  # NUMERIC
        'hc_y': 'DECIMAL(18,8)',  # NUMERIC
        'tfs_deprecated': 'VARCHAR',  # NUMERIC
        'tfs_zulu_deprecated': 'VARCHAR',  # NUMERIC
        'fielder_2': 'BIGINT',  # INTEGER
        'umpire': 'VARCHAR',  # VARCHAR
        'sv_id': 'VARCHAR',  # VARCHAR
        'vx0': 'DECIMAL(18,8)',  # NUMERIC
        'vy0': 'DECIMAL(18,8)',  # NUMERIC
        'vz0': 'DECIMAL(18,8)',  # NUMERIC
        'ax': 'DECIMAL(18,8)',  # NUMERIC
        'ay': 'DECIMAL(18,8)',  # NUMERIC
        'az': 'DECIMAL(18,8)',  # NUMERIC
        'sz_top': 'DECIMAL(18,8)',  # NUMERIC
        'sz_bot': 'DECIMAL(18,8)',  # NUMERIC
        'hit_distance_sc': 'BIGINT',  # SMALLINT
        'launch_speed': 'DECIMAL(18,8)',  # NUMERIC
        'launch_angle': 'BIGINT',  # NUMERIC
        'effective_speed': 'DECIMAL(18,8)',  # NUMERIC
        'release_spin_rate': 'BIGINT',  # SMALLINT
        'release_extension': 'DECIMAL(18,8)',  # NUMERIC
        'game_pk': 'BIGINT',  # INTEGER
        'pitcher_1': 'BIGINT',  # INTEGER
        'fielder_2_1': 'BIGINT',  # INTEGER
        'fielder_3': 'BIGINT',  # INTEGER
        'fielder_4': 'BIGINT',  # INTEGER
        'fielder_5': 'BIGINT',  # INTEGER
        'fielder_6': 'BIGINT',  # INTEGER
        'fielder_7': 'BIGINT',  # INTEGER
        'fielder_8': 'BIGINT',  # INTEGER
        'fielder_9': 'BIGINT',  # INTEGER
        'release_pos_y': 'DECIMAL(18,8)',  # NUMERIC
        'estimated_ba_using_speedangle': 'DECIMAL(18,8)',  # NUMERIC
        'estimated_woba_using_speedangle': 'DECIMAL(18,8)',  # NUMERIC
        'woba_value': 'DECIMAL(18,8)',  # NUMERIC
        'woba_denom': 'BIGINT',  # NUMERIC
        'babip_value': 'BIGINT',  # NUMERIC
        'iso_value': 'BIGINT',  # NUMERIC
        'launch_speed_angle': 'BIGINT',  # SMALLINT
        'at_bat_number': 'BIGINT',  # SMALLINT
        'pitch_number': 'BIGINT',  # SMALLINT
        'pitch_name': 'VARCHAR',  # VARCHAR
        'home_score': 'BIGINT',  # SMALLINT
        'away_score': 'BIGINT',  # SMALLINT
        'bat_score': 'BIGINT',  # SMALLINT
        'fld_score': 'BIGINT',  # SMALLINT
        'post_away_score': 'BIGINT',  # SMALLINT
        'post_home_score': 'BIGINT',  # SMALLINT
        'post_bat_score': 'BIGINT',  # SMALLINT
        'post_fld_score': 'BIGINT',  # SMALLINT
        'if_fielding_alignment': 'VARCHAR',  # VARCHAR
        'of_fielding_alignment': 'VARCHAR',  # VARCHAR
        'spin_axis': 'BIGINT',  # SMALLINT
        'delta_home_win_exp': 'DECIMAL(18,8)',  # NUMERIC
        'delta_run_exp': 'DECIMAL(18,8)',  # NUMERIC
        'bat_speed': 'DECIMAL(18,14)',
        'swing_length': 'DECIMAL(18,8)',
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
            end_date: StrDate = (datetime.date.today() - datetime.timedelta(days=1))
        ) -> None:

        start_date = datetime.date.fromisoformat(start_date) if isinstance(start_date, str) else start_date
        end_date = datetime.date.fromisoformat(end_date) if isinstance(end_date, str) else end_date

        search_start_dates = date_range(start_date, end_date, 4)
        for start in search_start_dates:
            end = min(start + datetime.timedelta(days=3), end_date)

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
        ) -> None:

        start_date = datetime.date.fromisoformat(start_date) if isinstance(start_date, str) else start_date
        end_date = datetime.date.fromisoformat(end_date) if isinstance(end_date, str) else end_date

        self.extract(start_date, end_date)

        filename_start_dates = date_range(start_date, end_date, 4)
        for start in filename_start_dates:
            for filepath in self.raw_dir.glob(f'statcast-{start:%Y-%m-%d}*'):
                self.load_file(filepath.name)
