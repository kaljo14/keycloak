#!/bin/bash

# Script to grant places_user full access to places_scraper database
# This ensures the application user has all necessary permissions

set -e

NAMESPACE="${1:-database}"
POD_NAME="postgres-postgresql-0"

echo "🔐 Granting full access to places_user on places_scraper database..."
echo ""

# Grant all privileges on database
kubectl exec -it "$POD_NAME" -n "$NAMESPACE" -- \
    env PGPASSWORD=4EG87AJaFxzA psql -U postgres -d places_scraper <<EOF

-- Grant all privileges on the database
GRANT ALL PRIVILEGES ON DATABASE places_scraper TO places_user;

-- Grant all privileges on all tables in public schema
GRANT ALL PRIVILEGES ON ALL TABLES IN public SCHEMA TO places_user;

-- Grant all privileges on all sequences (for auto-increment IDs)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN public SCHEMA TO places_user;

-- Grant usage on the public schema
GRANT USAGE ON SCHEMA public TO places_user;

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO places_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO places_user;

-- Change ownership of all existing tables to places_user
DO \$\$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public')
    LOOP
        EXECUTE 'ALTER TABLE public.' || quote_ident(r.tablename) || ' OWNER TO places_user';
    END LOOP;
END \$\$;

-- Change ownership of all sequences to places_user
DO \$\$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public')
    LOOP
        EXECUTE 'ALTER SEQUENCE public.' || quote_ident(r.sequence_name) || ' OWNER TO places_user';
    END LOOP;
END \$\$;

-- Verify permissions
\dt
\dp

EOF

echo ""
echo "✅ Full access granted to places_user!"
echo ""
echo "🔍 Verifying connection as places_user..."

# Test connection as places_user
kubectl exec -it "$POD_NAME" -n "$NAMESPACE" -- \
    env PGPASSWORD=8lRk1JBq7PmR psql -U places_user -d places_scraper -c "\dt"

echo ""
echo "✨ All done! places_user now has full access to places_scraper database."
