import duckdb
import os
import requests
import shutil

from pathlib import Path
from zipfile import ZipFile


DATABASE_NAME = os.getenv('BASEBALL_DB_NAME', 'baseball.db')


class ChadwickRegister:

    PEOPLE_FIELD_DTYPES = {
        'key_person': 'VARCHAR',
        'key_uuid': 'VARCHAR',
        'key_mlbam': 'BIGINT',
        'key_retro': 'VARCHAR',
        'key_bbref': 'VARCHAR',
        'key_bbref_minors': 'VARCHAR',
        'key_fangraphs': 'VARCHAR',
        'key_npb': 'VARCHAR',
        'key_sr_nfl': 'VARCHAR',
        'key_sr_nba': 'VARCHAR',
        'key_sr_nhl': 'VARCHAR',
        'key_wikidata': 'VARCHAR',
        'name_last': 'VARCHAR',
        'name_first': 'VARCHAR',
        'name_given': 'VARCHAR',
        'name_suffix': 'VARCHAR',
        'name_matrilineal': 'VARCHAR',
        'name_nick': 'VARCHAR',
        'birth_year': 'INTEGER',
        'birth_month': 'INTEGER',
        'birth_day': 'INTEGER',
        'death_year': 'INTEGER',
        'death_month': 'INTEGER',
        'death_day': 'INTEGER',
        'pro_played_first': 'INTEGER',
        'pro_played_last': 'INTEGER',
        'mlb_played_first': 'INTEGER',
        'mlb_played_last': 'INTEGER',
        'col_played_first': 'INTEGER',
        'col_played_last': 'INTEGER',
        'pro_managed_first': 'INTEGER',
        'pro_managed_last': 'INTEGER',
        'mlb_managed_first': 'INTEGER',
        'mlb_managed_last': 'INTEGER',
        'col_managed_first': 'INTEGER',
        'col_managed_last': 'INTEGER',
        'pro_umpired_first': 'INTEGER',
        'pro_umpired_last': 'INTEGER',
        'mlb_umpired_first': 'INTEGER',
        'mlb_umpired_last': 'INTEGER',
    }

    def __init__(self, data_dir = 'data') -> None:
        data_dir = Path(data_dir)
        self.raw_dir = data_dir / 'raw' / 'chadwick-register'

        # Create directory if it does not exist
        self.raw_dir.mkdir(parents=True, exist_ok=True)

    def download(self) -> None:
        """Download Chadwick register files."""
        url = 'https://github.com/chadwickbureau/register/archive/refs/heads/master.zip'
        resp = requests.get(url)

        filepath = self.raw_dir / 'register.zip'
        with open(filepath, 'wb') as f:
            f.write(resp.content)

    def unzip(self) -> None:
        """Unzip Chadwick register files."""
        filepath = self.raw_dir / 'register.zip'
        with ZipFile(filepath, 'r') as zf:
            zf.extractall(self.raw_dir)

    def load(self) -> None:
        # Create a new table with every load
        fields_sql = ", ".join(" ".join(x) for x in self.PEOPLE_FIELD_DTYPES.items())
        sql = f'create or replace table raw.chadwick_people({fields_sql});'

        con = duckdb.connect(DATABASE_NAME)
        con.execute(sql)

        # Copy CSVs to table
        filepaths = sorted(self.raw_dir.glob('**/people*.csv'))
        for filepath in filepaths:
            sql = f"copy raw.chadwick_people from '{filepath}' (header);"
            con.execute(sql)

        con.close()

    def cleanup(self) -> None:
        """Removes unzipped files."""
        for path in self.raw_dir.iterdir():
            if path.is_dir():
                shutil.rmtree(path)
