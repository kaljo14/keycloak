#!/bin/bash

# Create the data directory if it doesn't exist
mkdir -p keycloak_data

# Export the realm
# We use 'docker compose exec' to run the command inside the running container
echo "Exporting Keycloak realm..."
docker compose exec keycloak /opt/keycloak/bin/kc.sh export --dir /opt/keycloak/data/import --users realm_file

echo "Export complete. Check the 'keycloak_data' directory."
