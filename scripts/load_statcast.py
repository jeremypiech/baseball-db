import datetime
import os
import sys

from dotenv import load_dotenv; load_dotenv()

from baseball_db.statcast import Statcast

DATA_DIR = os.getenv('DATA_DIRECTORY', 'data')


def main():
    try:
        sc = Statcast(data_dir = DATA_DIR)

        current_year = datetime.datetime.now(datetime.UTC).year
        sc.load(current_year)

        print("Updated Statcast data.")
        sys.exit(0)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
