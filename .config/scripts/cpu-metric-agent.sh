#!/bin/bash

# Database connection details
HOST="192.168.1.4"
DB_NAME="grafana"
USER="postgres"
PASSWORD="bucky"

# Fetch CPU usage using vmstat
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

# Metric data
METRIC_NAME="cpu_usage"
METRIC_VALUE=$CPU_USAGE
CREATED_AT=$(date '+%Y-%m-%d %H:%M:%S')

# Insert query
INSERT_QUERY="INSERT INTO metrics (metric_name, metric_value, created_at) VALUES ('$METRIC_NAME', $METRIC_VALUE, '$CREATED_AT');"

# Execute the query using psql
PGPASSWORD=$PASSWORD psql -h $HOST -p 5432 -d $DB_NAME -U $USER -c "$INSERT_QUERY"

# Check if the insert was successful
if [ $? -eq 0 ]; then
    echo "Data inserted successfully: $METRIC_NAME = $METRIC_VALUE at $CREATED_AT"
else
    echo "Failed to insert data"
fi

