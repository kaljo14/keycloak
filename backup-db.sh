#!/bin/bash

# Define variables
CONTAINER_NAME="keycloak-auth-postgres-1" # Adjust if your container name is different
DB_USER="keycloak"
DB_NAME="keycloak"
OUTPUT_FILE="keycloak_backup.sql"

# Check if the container is running
if [ ! "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    # Try to find it loosely if the exact name fails
    CONTAINER_NAME=$(docker ps -q -f name=postgres | head -n 1)
    if [ -z "$CONTAINER_NAME" ]; then
        echo "Error: Postgres container not found."
        exit 1
    fi
fi

echo "Dumping database '$DB_NAME' from container '$CONTAINER_NAME'..."

# Run pg_dump inside the container
docker exec -t $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME > $OUTPUT_FILE

if [ $? -eq 0 ]; then
    echo "Backup successful! File saved to: $OUTPUT_FILE"
else
    echo "Backup failed."
    exit 1
fi
