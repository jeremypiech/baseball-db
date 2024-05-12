import csv
import duckdb
import os
import requests
import subprocess

from pathlib import Path
from zipfile import ZipFile


DATABASE_NAME = os.getenv('BASEBALL_DB_NAME', 'baseball.db')


class Retrosheet:
    """Extract and load Retrosheet files."""
    EVENT_FIELD_DTYPES = {
        'GAME_ID': 'VARCHAR',
        'AWAY_TEAM_ID': 'VARCHAR',
        'INN_CT': 'INTEGER',
        'BAT_HOME_ID': 'INTEGER',
        'OUTS_CT': 'INTEGER',
        'BALLS_CT': 'INTEGER',
        'STRIKES_CT': 'INTEGER',
        'PITCH_SEQ_TX': 'VARCHAR',
        'AWAY_SCORE_CT': 'INTEGER',
        'HOME_SCORE_CT': 'INTEGER',
        'BAT_ID': 'VARCHAR',
        'BAT_HAND_CD': 'VARCHAR',
        'RESP_BAT_ID': 'VARCHAR',
        'RESP_BAT_HAND_CD': 'VARCHAR',
        'PIT_ID': 'VARCHAR',
        'PIT_HAND_CD': 'VARCHAR',
        'RESP_PIT_ID': 'VARCHAR',
        'RESP_PIT_HAND_CD': 'VARCHAR',
        'POS2_FLD_ID': 'VARCHAR',
        'POS3_FLD_ID': 'VARCHAR',
        'POS4_FLD_ID': 'VARCHAR',
        'POS5_FLD_ID': 'VARCHAR',
        'POS6_FLD_ID': 'VARCHAR',
        'POS7_FLD_ID': 'VARCHAR',
        'POS8_FLD_ID': 'VARCHAR',
        'POS9_FLD_ID': 'VARCHAR',
        'BASE1_RUN_ID': 'VARCHAR',
        'BASE2_RUN_ID': 'VARCHAR',
        'BASE3_RUN_ID': 'VARCHAR',
        'EVENT_TX': 'VARCHAR',
        'LEADOFF_FL': 'VARCHAR',
        'PH_FL': 'VARCHAR',
        'BAT_FLD_CD': 'INTEGER',
        'BAT_LINEUP_ID': 'INTEGER',
        'EVENT_CD': 'INTEGER',
        'BAT_EVENT_FL': 'VARCHAR',
        'AB_FL': 'VARCHAR',
        'H_CD': 'INTEGER',
        'SH_FL': 'VARCHAR',
        'SF_FL': 'VARCHAR',
        'EVENT_OUTS_CT': 'INTEGER',
        'DP_FL': 'VARCHAR',
        'TP_FL': 'VARCHAR',
        'RBI_CT': 'INTEGER',
        'WP_FL': 'VARCHAR',
        'PB_FL': 'VARCHAR',
        'FLD_CD': 'INTEGER',
        'BATTEDBALL_CD': 'VARCHAR',
        'BUNT_FL': 'VARCHAR',
        'FOUL_FL': 'VARCHAR',
        'BATTEDBALL_LOC_TX': 'VARCHAR',
        'ERR_CT': 'INTEGER',
        'ERR1_FLD_CD': 'VARCHAR',
        'ERR1_CD': 'VARCHAR',
        'ERR2_FLD_CD': 'VARCHAR',
        'ERR2_CD': 'VARCHAR',
        'ERR3_FLD_CD': 'VARCHAR',
        'ERR3_CD': 'VARCHAR',
        'BAT_DEST_ID': 'VARCHAR',
        'RUN1_DEST_ID': 'VARCHAR',
        'RUN2_DEST_ID': 'VARCHAR',
        'RUN3_DEST_ID': 'VARCHAR',
        'BAT_PLAY_TX': 'VARCHAR',
        'RUN1_PLAY_TX': 'VARCHAR',
        'RUN2_PLAY_TX': 'VARCHAR',
        'RUN3_PLAY_TX': 'VARCHAR',
        'RUN1_SB_FL': 'VARCHAR',
        'RUN2_SB_FL': 'VARCHAR',
        'RUN3_SB_FL': 'VARCHAR',
        'RUN1_CS_FL': 'VARCHAR',
        'RUN2_CS_FL': 'VARCHAR',
        'RUN3_CS_FL': 'VARCHAR',
        'RUN1_PK_FL': 'VARCHAR',
        'RUN2_PK_FL': 'VARCHAR',
        'RUN3_PK_FL': 'VARCHAR',
        'RUN1_RESP_PIT_ID': 'VARCHAR',
        'RUN2_RESP_PIT_ID': 'VARCHAR',
        'RUN3_RESP_PIT_ID': 'VARCHAR',
        'GAME_NEW_FL': 'VARCHAR',
        'GAME_END_FL': 'VARCHAR',
        'PR_RUN1_FL': 'VARCHAR',
        'PR_RUN2_FL': 'VARCHAR',
        'PR_RUN3_FL': 'VARCHAR',
        'REMOVED_FOR_PR_RUN1_ID': 'VARCHAR',
        'REMOVED_FOR_PR_RUN2_ID': 'VARCHAR',
        'REMOVED_FOR_PR_RUN3_ID': 'VARCHAR',
        'REMOVED_FOR_PH_BAT_ID': 'VARCHAR',
        'REMOVED_FOR_PH_BAT_FLD_CD': 'INTEGER',
        'PO1_FLD_CD': 'INTEGER',
        'PO2_FLD_CD': 'INTEGER',
        'PO3_FLD_CD': 'INTEGER',
        'ASS1_FLD_CD': 'INTEGER',
        'ASS2_FLD_CD': 'INTEGER',
        'ASS3_FLD_CD': 'INTEGER',
        'ASS4_FLD_CD': 'INTEGER',
        'ASS5_FLD_CD': 'INTEGER',
        'EVENT_ID': 'INTEGER',
        'HOME_TEAM_ID': 'VARCHAR',
        'BAT_TEAM_ID': 'VARCHAR',
        'FLD_TEAM_ID': 'VARCHAR',
        'BAT_LAST_ID': 'VARCHAR',
        'INN_NEW_FL': 'VARCHAR',
        'INN_END_FL': 'VARCHAR',
        'START_BAT_SCORE_CT': 'INTEGER',
        'START_FLD_SCORE_CT': 'INTEGER',
        'INN_RUNS_CT': 'INTEGER',
        'GAME_PA_CT': 'INTEGER',
        'INN_PA_CT': 'INTEGER',
        'PA_NEW_FL': 'VARCHAR',
        'PA_TRUNC_FL': 'VARCHAR',
        'START_BASES_CD': 'INTEGER',
        'END_BASES_CD': 'INTEGER',
        'BAT_START_FL': 'VARCHAR',
        'RESP_BAT_START_FL': 'VARCHAR',
        'BAT_ON_DECK_ID': 'VARCHAR',
        'BAT_IN_HOLD_ID': 'VARCHAR',
        'PIT_START_FL': 'VARCHAR',
        'RESP_PIT_START_FL': 'VARCHAR',
        'RUN1_FLD_CD': 'INTEGER',
        'RUN1_LINEUP_CD': 'INTEGER',
        'RUN1_ORIGIN_EVENT_ID': 'INTEGER',
        'RUN2_FLD_CD': 'INTEGER',
        'RUN2_LINEUP_CD': 'INTEGER',
        'RUN2_ORIGIN_EVENT_ID': 'INTEGER',
        'RUN3_FLD_CD': 'INTEGER',
        'RUN3_LINEUP_CD': 'INTEGER',
        'RUN3_ORIGIN_EVENT_ID': 'INTEGER',
        'RUN1_RESP_CAT_ID': 'VARCHAR',
        'RUN2_RESP_CAT_ID': 'VARCHAR',
        'RUN3_RESP_CAT_ID': 'VARCHAR',
        'PA_BALL_CT': 'INTEGER',
        'PA_CALLED_BALL_CT': 'INTEGER',
        'PA_INTENT_BALL_CT': 'INTEGER',
        'PA_PITCHOUT_BALL_CT': 'INTEGER',
        'PA_HITBATTER_BALL_CT': 'INTEGER',
        'PA_OTHER_BALL_CT': 'INTEGER',
        'PA_STRIKE_CT': 'INTEGER',
        'PA_CALLED_STRIKE_CT': 'INTEGER',
        'PA_SWINGMISS_STRIKE_CT': 'INTEGER',
        'PA_FOUL_STRIKE_CT': 'INTEGER',
        'PA_INPLAY_STRIKE_CT': 'INTEGER',
        'PA_OTHER_STRIKE_CT': 'INTEGER',
        'EVENT_RUNS_CT': 'INTEGER',
        'FLD_ID': 'VARCHAR',
        'BASE2_FORCE_FL': 'VARCHAR',
        'BASE3_FORCE_FL': 'VARCHAR',
        'BASE4_FORCE_FL': 'VARCHAR',
        'BAT_SAFE_ERR_FL': 'VARCHAR',
        'BAT_FATE_ID': 'INTEGER',
        'RUN1_FATE_ID': 'INTEGER',
        'RUN2_FATE_ID': 'INTEGER',
        'RUN3_FATE_ID': 'INTEGER',
        'FATE_RUNS_CT': 'INTEGER',
        'ASS6_FLD_CD': 'INTEGER',
        'ASS7_FLD_CD': 'INTEGER',
        'ASS8_FLD_CD': 'INTEGER',
        'ASS9_FLD_CD': 'INTEGER',
        'ASS10_FLD_CD': 'INTEGER',
        'UNKNOWN_OUT_EXC_FL': 'VARCHAR',
        'UNCERTAIN_PLAY_EXC_FL': 'VARCHAR',
        'COUNT_TX': 'VARCHAR',
    }

    GAME_FIELD_DTYPES = {
        'GAME_ID': 'VARCHAR',
        'GAME_DT': 'VARCHAR',
        'GAME_CT': 'INTEGER',
        'GAME_DY': 'VARCHAR',
        'START_GAME_TM': 'VARCHAR',
        'DH_FL': 'VARCHAR',
        'DAYNIGHT_PARK_CD': 'VARCHAR',
        'AWAY_TEAM_ID': 'VARCHAR',
        'HOME_TEAM_ID': 'VARCHAR',
        'PARK_ID': 'VARCHAR',
        'AWAY_START_PIT_ID': 'VARCHAR',
        'HOME_START_PIT_ID': 'VARCHAR',
        'BASE4_UMP_ID': 'VARCHAR',
        'BASE1_UMP_ID': 'VARCHAR',
        'BASE2_UMP_ID': 'VARCHAR',
        'BASE3_UMP_ID': 'VARCHAR',
        'LF_UMP_ID': 'VARCHAR',
        'RF_UMP_ID': 'VARCHAR',
        'ATTEND_PARK_CT': 'BIGINT',
        'SCORER_RECORD_ID': 'VARCHAR',
        'TRANSLATOR_RECORD_ID': 'VARCHAR',
        'INPUTTER_RECORD_ID': 'VARCHAR',
        'INPUT_RECORD_TS': 'VARCHAR',
        'EDIT_RECORD_TS': 'VARCHAR',
        'METHOD_RECORD_CD': 'INTEGER',
        'PITCHES_RECORD_CD': 'INTEGER',
        'TEMP_PARK_CT': 'INTEGER',
        'WIND_DIRECTION_PARK_CD': 'INTEGER',
        'WIND_SPEED_PARK_CT': 'INTEGER',
        'FIELD_PARK_CD': 'INTEGER',
        'PRECIP_PARK_CD': 'INTEGER',
        'SKY_PARK_CD': 'INTEGER',
        'MINUTES_GAME_CT': 'INTEGER',
        'INN_CT': 'INTEGER',
        'AWAY_SCORE_CT': 'INTEGER',
        'HOME_SCORE_CT': 'INTEGER',
        'AWAY_HITS_CT': 'INTEGER',
        'HOME_HITS_CT': 'INTEGER',
        'AWAY_ERR_CT': 'INTEGER',
        'HOME_ERR_CT': 'INTEGER',
        'AWAY_LOB_CT': 'INTEGER',
        'HOME_LOB_CT': 'INTEGER',
        'WIN_PIT_ID': 'VARCHAR',
        'LOSE_PIT_ID': 'VARCHAR',
        'SAVE_PIT_ID': 'VARCHAR',
        'GWRBI_BAT_ID': 'VARCHAR',
        'AWAY_LINEUP1_BAT_ID': 'VARCHAR',
        'AWAY_LINEUP1_FLD_CD': 'INTEGER',
        'AWAY_LINEUP2_BAT_ID': 'VARCHAR',
        'AWAY_LINEUP2_FLD_CD': 'INTEGER',
        'AWAY_LINEUP3_BAT_ID': 'VARCHAR',
        'AWAY_LINEUP3_FLD_CD': 'INTEGER',
        'AWAY_LINEUP4_BAT_ID': 'VARCHAR',
        'AWAY_LINEUP4_FLD_CD': 'INTEGER',
        'AWAY_LINEUP5_BAT_ID': 'VARCHAR',
        'AWAY_LINEUP5_FLD_CD': 'INTEGER',
        'AWAY_LINEUP6_BAT_ID': 'VARCHAR',
        'AWAY_LINEUP6_FLD_CD': 'INTEGER',
        'AWAY_LINEUP7_BAT_ID': 'VARCHAR',
        'AWAY_LINEUP7_FLD_CD': 'INTEGER',
        'AWAY_LINEUP8_BAT_ID': 'VARCHAR',
        'AWAY_LINEUP8_FLD_CD': 'INTEGER',
        'AWAY_LINEUP9_BAT_ID': 'VARCHAR',
        'AWAY_LINEUP9_FLD_CD': 'INTEGER',
        'HOME_LINEUP1_BAT_ID': 'VARCHAR',
        'HOME_LINEUP1_FLD_CD': 'INTEGER',
        'HOME_LINEUP2_BAT_ID': 'VARCHAR',
        'HOME_LINEUP2_FLD_CD': 'INTEGER',
        'HOME_LINEUP3_BAT_ID': 'VARCHAR',
        'HOME_LINEUP3_FLD_CD': 'INTEGER',
        'HOME_LINEUP4_BAT_ID': 'VARCHAR',
        'HOME_LINEUP4_FLD_CD': 'INTEGER',
        'HOME_LINEUP5_BAT_ID': 'VARCHAR',
        'HOME_LINEUP5_FLD_CD': 'INTEGER',
        'HOME_LINEUP6_BAT_ID': 'VARCHAR',
        'HOME_LINEUP6_FLD_CD': 'INTEGER',
        'HOME_LINEUP7_BAT_ID': 'VARCHAR',
        'HOME_LINEUP7_FLD_CD': 'INTEGER',
        'HOME_LINEUP8_BAT_ID': 'VARCHAR',
        'HOME_LINEUP8_FLD_CD': 'INTEGER',
        'HOME_LINEUP9_BAT_ID': 'VARCHAR',
        'HOME_LINEUP9_FLD_CD': 'INTEGER',
        'AWAY_FINISH_PIT_ID': 'VARCHAR',
        'HOME_FINISH_PIT_ID': 'VARCHAR',
    }

    SUB_FIELD_DTYPES = {
        'GAME_ID': 'VARCHAR',
        'INN_CT': 'INTEGER',
        'BAT_HOME_ID': 'INTEGER',
        'SUB_ID': 'VARCHAR',
        'SUB_HOME_ID': 'INTEGER',
        'SUB_LINEUP_ID': 'INTEGER',
        'SUB_FLD_CD': 'INTEGER',
        'REMOVED_ID': 'VARCHAR',
        'REMOVED_FLD_CD': 'INTEGER',
        'EVENT_ID': 'INTEGER',
    }

    ROSTER_FIELD_DTYPES = {
        'PLAYER_ID': 'VARCHAR',
        'LAST_NAME': 'VARCHAR',
        'FIRST_NAME': 'VARCHAR',
        'BATS': 'VARCHAR',
        'THROWS': 'VARCHAR',
        'TEAM_ID': 'VARCHAR',
        'POSITION': 'VARCHAR',
        'YEAR': 'BIGINT',
    }
    
    def __init__(self, data_dir = 'data') -> None:
        data_dir = Path(data_dir)

        self.raw_dir = data_dir / 'raw' / 'retrosheet'
        self.parsed_dir = data_dir / 'parsed' / 'retrosheet'

        # Create directories if they do not exist
        self.raw_dir.mkdir(parents=True, exist_ok=True)
        self.parsed_dir.mkdir(parents=True, exist_ok=True)

    def download(self) -> None:
        """Download Retrosheet files."""
        url = 'https://www.retrosheet.org/downloads/alldata.zip'
        resp = requests.get(url)

        filepath = self.raw_dir / 'alldata.zip'
        with open(filepath, 'wb') as f:
            f.write(resp.content)

    def unzip(self) -> None:
        """Unzip Retrosheet files."""
        filepath = self.raw_dir / 'alldata.zip'
        with ZipFile(filepath, 'r') as zf:
            zf.extractall(self.raw_dir)

    def move_team_files(self) -> None:
        """Move team files to events folder in order to run Chadwick CLI."""
        in_dir = self.raw_dir / 'teams'
        out_dir = self.raw_dir / 'events'

        for f in in_dir.glob('TEAM*'):
            out_path = out_dir / f.name
            f.rename(out_path)

    def parse_events(self) -> None:
        """Parses Retrosheet event files with Chadwick CLI and saves to csv."""
        # Get all years
        in_dir = self.raw_dir / 'events'
        files = in_dir.glob('*.EV?')
        years = {int(f.name[:4]) for f in files}

        # Run Chadwick
        out_dir = self.parsed_dir / 'events'
        out_dir.mkdir(exist_ok=True)

        for year in years:
            out_path = out_dir / f'{year}.csv'

            cmd = f'cwevent -y {year} -n -f 0-96 -x 0-63 {year}*.EV?'
            with open(out_path, 'w+') as f:
                subprocess.run(
                    cmd,
                    shell=True,
                    stdout=f,
                    stderr=subprocess.DEVNULL,
                    cwd=in_dir,
                )

    def parse_games(self) -> None:
        """Parses Retrosheet event files for game summaries with Chadwick CLI
        and saves to csvs.
        """
        # Get all years
        in_dir = self.raw_dir / 'events'
        files = in_dir.glob('*.EV?')
        years = {int(f.name[:4]) for f in files}

        # Run Chadwick
        out_dir = self.parsed_dir / 'games'
        out_dir.mkdir(exist_ok=True)

        for year in years:
            out_path = out_dir / f'{year}.csv'

            cmd = f'cwgame -y {year} -n -f 0-83 {year}*.EV?'
            with open(out_path, 'w+') as f:
                subprocess.run(
                    cmd,
                    shell=True,
                    stdout=f,
                    stderr=subprocess.DEVNULL,
                    cwd=in_dir,
                )

    def parse_subs(self) -> None:
        """Parses Retrosheet event files for substitutions with Chadwick
        CLI and saves to csvs.
        """
        # Get all years
        in_dir = self.raw_dir / 'events'
        files = in_dir.glob('*.EV?')
        years = {int(f.name[:4]) for f in files}

        # Run Chadwick
        out_dir = self.parsed_dir / 'subs'
        out_dir.mkdir(exist_ok=True)

        for year in years:
            out_path = out_dir / f'{year}.csv'

            cmd = f'cwsub -y {year} -n {year}*.EV?'
            with open(out_path, 'w+') as f:
                subprocess.run(
                    cmd,
                    shell=True,
                    stdout=f,
                    stderr=subprocess.DEVNULL,
                    cwd=in_dir,
                )

    def parse_rosters(self) -> None:
        """Parses Retrosheet roster files and saves to csvs."""
        # Get all years
        in_dir = self.raw_dir / 'rosters'
        files = in_dir.glob('*.ROS')
        years = {int(f.name[3:7]) for f in files}

        # Build csv with every team's rosters for each season
        out_dir = self.parsed_dir / 'rosters'
        out_dir.mkdir(exist_ok=True)

        for year in years:
            out_path = out_dir / f'{year}.csv'
            with open(out_path, 'w', newline='') as out_file:
                writer = csv.writer(out_file)

                header = ['PLAYER_ID', 'LAST_NAME', 'FIRST_NAME', 'BATS', 'THROWS', 'TEAM_ID', 'POSITION', 'YEAR']
                writer.writerow(header)

                in_csvs = in_dir.glob(f'*{year}.ROS')
                for in_csv in in_csvs:
                    with open(in_csv, newline='') as in_file:
                        reader = csv.reader(in_file)
                        for row in reader:
                            writer.writerow(row + [year])        

    def _create_table(self, table: str) -> None:
        table_field_dtypes = {
            'events': self.EVENT_FIELD_DTYPES,
            'games': self.GAME_FIELD_DTYPES,
            'subs': self.SUB_FIELD_DTYPES,
            'rosters': self.ROSTER_FIELD_DTYPES,
        }

        field_dtypes = table_field_dtypes[table]

        fields_sql = ", ".join(" ".join(x) for x in field_dtypes.items())
        sql = f'create table if not exists raw.retrosheet_{table}({fields_sql});'

        print(DATABASE_NAME)
        con = duckdb.connect(DATABASE_NAME)
        con.execute(sql)
        con.close()
            
    def load_seasons(self, table: str, years: int | list[int]) -> None:
        if isinstance(years, int):
            years = [years]

        con = duckdb.connect(DATABASE_NAME)

        for year in years:
            filepath = self.parsed_dir / table / f'{year}.csv'
            sql = f"copy raw.retrosheet_{table} from '{filepath}' (header);"
            con.execute(sql)

        con.close()
