# Migrating Keycloak Data to k3s

This guide explains how to migrate your local Keycloak PostgreSQL data to a Postgres instance running in your k3s cluster.

## Prerequisites

1.  **Local Backup**: You have generated `keycloak_backup.sql` using the `./backup-db.sh` script.
2.  **k3s Access**: You have `kubectl` configured to access your k3s cluster.
3.  **Destination DB**: You have a PostgreSQL pod running in your k3s cluster (e.g., installed via Helm or a manifest).

## Migration Steps

### 1. Identify your k3s Postgres Pod
Find the name of the pod running Postgres in your cluster.

```bash
kubectl get pods
# Example output: postgres-0 or keycloak-postgres-7d8b9c
```

Set the pod name variable:
```bash
POD_NAME=postgres-0  # REPLACE with your actual pod name
NAMESPACE=default    # REPLACE with your namespace if different
```

### 2. Copy the Backup File to the Pod
Use `kubectl cp` to upload the SQL file into the pod's temporary directory.

```bash
kubectl cp ./keycloak_backup.sql $NAMESPACE/$POD_NAME:/tmp/keycloak_backup.sql
```

### 3. Import the Data
Execute the `psql` command inside the pod to restore the data.

**Warning**: This assumes the target database is empty or you are okay with overwriting data.

```bash
# If your DB user is 'keycloak' and DB name is 'keycloak'
kubectl exec -it $POD_NAME -n $NAMESPACE -- psql -U keycloak -d keycloak -f /tmp/keycloak_backup.sql
```

*Note: If you get a password prompt, enter the password for the 'keycloak' user in your k3s database.*

### 4. Verify
Check if the tables were created.

```bash
kubectl exec -it $POD_NAME -n $NAMESPACE -- psql -U keycloak -d keycloak -c "\dt"
```

## Troubleshooting

*   **"Database does not exist"**: Ensure you created the `keycloak` database in your k3s instance before importing.
    ```bash
    kubectl exec -it $POD_NAME -- psql -U postgres -c "CREATE DATABASE keycloak;"
    ```
*   **Version Mismatch**: If your local Postgres is v15 and k3s is v12, you might encounter syntax errors. Try to match versions.

## Architecture Note: Shared vs. Separate Databases

**Question:** Should I run one Postgres for all apps or separate Postgres instances?

**Recommendation for k3s:**
*   **Shared Instance (Recommended for resource efficiency):** Run **one** HA Postgres cluster (e.g., using CloudNativePG or Bitnami Helm chart) and create separate *logical databases* (schemas) for each app (e.g., `keycloak_db`, `app1_db`). This saves RAM and CPU.
*   **Separate Instances:** Use this only if apps have strictly different requirements (e.g., one needs specific extensions or heavy tuning) or for strict security isolation.
