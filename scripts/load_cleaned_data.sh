#!/bin/bash

# Script to load cleaned weather data into HDFS if not already present

set -e  # Exit on any error

LOCAL_FILE="./weather-cleaned.csv.xz"
HDFS_TARGET_DIR="/weather-cleaned"
CONTAINER_NAME="namenode"

echo "Checking for cleaned data in HDFS..."

# Check if HDFS directory exists and contains data
if docker exec $CONTAINER_NAME hdfs dfs -test -d $HDFS_TARGET_DIR 2>/dev/null; then
    # Check if there are any files in the directory (excluding _SUCCESS)
    FILE_COUNT=$(docker exec $CONTAINER_NAME hdfs dfs -ls $HDFS_TARGET_DIR 2>/dev/null | grep -v "_SUCCESS" | grep -c "part-" || echo "0")
    
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo "Cleaned data already exists in HDFS at $HDFS_TARGET_DIR"
        echo "Files found:"
        docker exec $CONTAINER_NAME hdfs dfs -ls $HDFS_TARGET_DIR
        exit 0
    fi
fi

echo "Cleaned data not found in HDFS. Loading..."

# Check if local compressed file exists
if [ ! -f "$LOCAL_FILE" ]; then
    echo "Error: Local file $LOCAL_FILE does not exist!"
    echo "Please ensure the cleaned data file is present."
    exit 1
fi

# Decompress the file
echo "Decompressing $LOCAL_FILE..."
if [ ! -f "./weather-cleaned.csv" ]; then
    xz -dk "$LOCAL_FILE"
fi

# Create HDFS directory if it doesn't exist
echo "Creating HDFS directory $HDFS_TARGET_DIR..."
docker exec $CONTAINER_NAME hdfs dfs -mkdir -p $HDFS_TARGET_DIR 2>/dev/null || true

# Copy CSV file to container
echo "Copying cleaned data to container..."
docker cp ./weather-cleaned.csv $CONTAINER_NAME:/tmp/weather-cleaned.csv

# Upload to HDFS
echo "Uploading to HDFS..."
docker exec $CONTAINER_NAME hdfs dfs -put -f /tmp/weather-cleaned.csv $HDFS_TARGET_DIR/part-00000

# Clean up temporary files in container
echo "Cleaning up..."
docker exec -u root $CONTAINER_NAME rm -f /tmp/weather-cleaned.csv

# Create SUCCESS marker
docker exec $CONTAINER_NAME hdfs dfs -touchz $HDFS_TARGET_DIR/_SUCCESS

echo "Data loaded successfully!"
echo "Verifying files in HDFS..."
docker exec $CONTAINER_NAME hdfs dfs -ls $HDFS_TARGET_DIR

echo ""
echo "Done! Cleaned weather data is available in HDFS at $HDFS_TARGET_DIR"
