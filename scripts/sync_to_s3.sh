#!/bin/bash

set -e

# Variables
LOCAL_DIR="deploy"
S3_BUCKET=$1
AWS_REGION=$2

# List local and remote files
echo "Listing local and S3 files for comparison..."
LOCAL_FILES=$(find $LOCAL_DIR -type f | sed "s|^$LOCAL_DIR/||")
REMOTE_FILES=$(aws s3api list-objects-v2 --bucket $S3_BUCKET --prefix $LOCAL_DIR/ --query "Contents[].Key" --output text | sed "s|^$LOCAL_DIR/||")

# Check for changes
CHANGES=false
for FILE in $LOCAL_FILES; do
  LOCAL_FILE_PATH="$LOCAL_DIR/$FILE"
  S3_FILE_PATH="$LOCAL_DIR/$FILE"

  # Get S3 file metadata
  S3_METADATA=$(aws s3api head-object --bucket $S3_BUCKET --key "$S3_FILE_PATH" 2>/dev/null || true)

  # If the file doesn't exist in S3, mark for sync
  if [ -z "$S3_METADATA" ]; then
    echo "New file: $FILE"
    CHANGES=true
    break
  else
    # Compare file size and modification time
    LOCAL_SIZE=$(stat -c%s "$LOCAL_FILE_PATH")
    REMOTE_SIZE=$(echo "$S3_METADATA" | jq -r '.ContentLength')
    LOCAL_MOD_TIME=$(date -r "$LOCAL_FILE_PATH" +%s)
    REMOTE_MOD_TIME=$(echo "$S3_METADATA" | jq -r '.LastModified' | date -d @$(date -u -d "{}" +%s) +%s)

    if [ "$LOCAL_SIZE" -ne "$REMOTE_SIZE" ] || [ "$LOCAL_MOD_TIME" -ne "$REMOTE_MOD_TIME" ]; then
      echo "Modified file: $FILE"
      CHANGES=true
      break
    fi
  fi
done

# Perform sync if changes are detected
if [ "$CHANGES" = true ]; then
  echo "Changes detected. Syncing..."
  aws s3 sync $LOCAL_DIR s3://$S3_BUCKET/$LOCAL_DIR --exact-timestamps --delete
else
  echo "No changes detected. Skipping sync."
fi
