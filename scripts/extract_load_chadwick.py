import os
import sys

from dotenv import load_dotenv; load_dotenv()

from baseball_db.chadwick import ChadwickRegister

DATA_DIR = os.getenv('DATA_DIRECTORY', 'data')


def main():
    try:
        cr = ChadwickRegister(data_dir = DATA_DIR)
        cr.extract_load()
        print("Updated Chadwick Register data.")
        sys.exit(0)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
