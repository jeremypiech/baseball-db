import os
import sys

from dotenv import load_dotenv; load_dotenv()

from baseball_db.retrosheet import Retrosheet

DATA_DIR = os.getenv('DATA_DIRECTORY', 'data')


def main():
    try:
        rs = Retrosheet(data_dir = DATA_DIR)
        rs.extract_load_all()
        print("Updated Retrosheet data.")
        sys.exit(0)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
