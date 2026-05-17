import os

from dotenv import load_dotenv; load_dotenv()

DATABASE_NAME = os.getenv('BASEBALL_DB_NAME', 'baseball.duckdb')
