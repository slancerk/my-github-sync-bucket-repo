#!/bin/bash

S3_BUCKET=$1
AWS_REGION=$2

if [ -z "$S3_BUCKET" ] || [ -z "$AWS_REGION" ]; then
  echo "Usage: $0 <s3-bucket-name> <aws-region>"
  exit 1
fi

echo "Listing local and S3 files for comparison..."

LOCAL_FILES=$(find deploy -type f)
for LOCAL_FILE in $LOCAL_FILES; do
  LOCAL_MOD_TIME=$(stat -c %Y "$LOCAL_FILE")
  S3_FILE="s3://$S3_BUCKET/$LOCAL_FILE"
  S3_MOD_TIME=$(aws s3 ls "$S3_FILE" --region "$AWS_REGION" | awk '{print $1, $2}' | xargs -I{} date -d "{}" +%s 2>/dev/null)
  
  if [ -z "$S3_MOD_TIME" ]; then
    echo "New file: $LOCAL_FILE"
    aws s3 cp "$LOCAL_FILE" "$S3_FILE" --region "$AWS_REGION"
  elif [ "$LOCAL_MOD_TIME" -gt "$S3_MOD_TIME" ]; then
    echo "Updated file: $LOCAL_FILE"
    aws s3 cp "$LOCAL_FILE" "$S3_FILE" --region "$AWS_REGION"
  else
    echo "Unchanged file: $LOCAL_FILE"
  fi
done

echo "Sync completed."
