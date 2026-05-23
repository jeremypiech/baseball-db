#!/bin/bash

source .env

for i in $(seq 1 10); do
  date=$(date -v-${i}d +%Y-%m-%d)
  year=$(echo "$date" | cut -d'-' -f1)
  aws s3 cp s3://${STATCAST_S3_BUCKET}/${year}/statcast-${date}.csv ${DATA_DIRECTORY}/statcast/${year}/statcast-${date}.csv
done

source .venv/bin/activate

python scripts/load_statcast.py
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi