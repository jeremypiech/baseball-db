#!/bin/bash

source .env

aws s3 cp s3://$STATCAST_S3_BUCKET/$(date +%Y) $DATA_DIRECTORY/statcast/$(date +%Y) --recursive

source .venv/bin/activate

python scripts/load_statcast.py
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi