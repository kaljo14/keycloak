#!/bin/bash

# Script to restore PostgreSQL backup to k3s cluster
# This script handles user/role name differences between environments

set -e

BACKUP_FILE="${1:-backup.sql}"
NAMESPACE="${2:-database}"
POD_NAME="postgres-postgresql-0"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file '$BACKUP_FILE' not found!"
    echo "Usage: $0 <backup-file> [namespace]"
    exit 1
fi

echo "📦 Preparing backup file for k3s environment..."

# Create a temporary modified backup file
TEMP_BACKUP="/tmp/k3s-backup-$(date +%s).sql"

# Replace 'admin' user references with 'postgres' (k3s superuser)
sed 's/OWNER TO admin/OWNER TO postgres/g' "$BACKUP_FILE" | \
sed 's/TO admin;/TO postgres;/g' > "$TEMP_BACKUP"

echo "✅ Modified backup file created: $TEMP_BACKUP"
echo ""
echo "📤 Copying backup to pod..."

# Copy the modified backup to the pod
kubectl cp "$TEMP_BACKUP" "$NAMESPACE/$POD_NAME:/tmp/backup-k3s.sql"

echo "✅ Backup copied to pod"
echo ""
echo "🔄 Restoring database..."

# Restore the database using postgres superuser
kubectl exec -it "$POD_NAME" -n "$NAMESPACE" -- \
    env PGPASSWORD=4EG87AJaFxzA psql -U postgres -d places_scraper -f /tmp/backup-k3s.sql

echo ""
echo "🧹 Cleaning up..."

# Clean up temporary files
rm -f "$TEMP_BACKUP"
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- rm -f /tmp/backup-k3s.sql

echo "✅ Restore complete!"
echo ""
echo "🔍 Verifying data..."

# Show table count
kubectl exec "$POD_NAME" -n "$NAMESPACE" -- \
    env PGPASSWORD=4EG87AJaFxzA psql -U postgres -d places_scraper -c "\dt"

echo ""
echo "✨ All done! Your database has been restored."
