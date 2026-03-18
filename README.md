# Keycloak Authentication Server

A standalone Keycloak authentication server with custom themes, ready to be used by any application requiring authentication services.

## Overview

This project provides a containerized Keycloak instance with:
- PostgreSQL database for persistent storage
- Custom "barbershop-v2-theme" login theme
- Development mode configuration for easy theme customization

## Prerequisites

- Docker
- Docker Compose

## Project Structure

```
keycloak-auth/
├── docker-compose.yml          # Docker services configuration
├── themes/                     # Custom Keycloak themes
│   └── barbershop-v2-theme/      # Custom login theme
│       └── login/
│           ├── resources/
│           │   ├── css/       # Custom styles
│           │   └── img/       # Theme images
│           └── theme.properties
├── .gitignore
└── README.md
```

## Getting Started

### 1. Start the Services

```bash
docker-compose up -d
```

This will start:
- **PostgreSQL** on internal network (not exposed to host)
- **Keycloak** on http://localhost:8081

### 2. Access Keycloak Admin Console

Open your browser and navigate to:
```
http://localhost:8081
```

**Admin Credentials:**
- Username: `admin`
- Password: `admin`

### 3. Apply the Custom Theme

1. Log in to the Keycloak Admin Console
2. Select your realm (or create a new one)
3. Go to **Realm Settings** → **Themes** tab
4. Under **Login theme**, select `barbershop-v2-theme` from the dropdown
5. Click **Save**

### 4. Test the Theme

1. Create a test client application in your realm
2. Navigate to the login URL for your realm
3. You should see the custom barbershop v2 theme applied

## Configuration

### Environment Variables

The following environment variables are configured in `docker-compose.yml`:

**PostgreSQL:**
- `POSTGRES_DB`: keycloak
- `POSTGRES_USER`: keycloak
- `POSTGRES_PASSWORD`: password

**Keycloak:**
- `KC_DB`: postgres
- `KC_DB_URL`: jdbc:postgresql://postgres:5432/keycloak
- `KC_DB_USERNAME`: keycloak
- `KC_DB_PASSWORD`: password
- `KEYCLOAK_ADMIN`: admin
- `KEYCLOAK_ADMIN_PASSWORD`: admin
- `KC_HTTP_PORT`: 8081

### Theme Development

The Keycloak instance is configured with theme caching disabled for development:
```
--spi-theme-static-max-age=-1
--spi-theme-cache-themes=false
--spi-theme-cache-templates=false
```

This means you can modify theme files in `./themes/` and see changes immediately by refreshing your browser (no container restart required).

## Managing Services

### Stop Services
```bash
docker-compose down
```

### Stop and Remove Volumes (Clean Slate)
```bash
docker-compose down -v
```

### View Logs
```bash
# All services
docker-compose logs -f

# Keycloak only
docker-compose logs -f keycloak

# PostgreSQL only
docker-compose logs -f postgres
```

### Restart Services
```bash
docker-compose restart
```

## Customizing the Theme

The custom theme is located in `./themes/barbershop-v2-theme/login/`.

**To modify:**
1. Edit CSS files in `./themes/barbershop-v2-theme/login/resources/css/`
2. Replace images in `./themes/barbershop-v2-theme/login/resources/img/`
3. Modify `theme.properties` for theme metadata
4. Refresh your browser to see changes (no restart needed)

## Integration with Applications

To integrate this Keycloak instance with your applications:

1. **Create a Realm** for your application
2. **Create a Client** in that realm with appropriate settings
3. **Configure your application** to use:
   - Auth Server URL: `http://localhost:8081`
   - Realm: `<your-realm-name>`
   - Client ID: `<your-client-id>`

## Production Considerations

> [!WARNING]
> This configuration is for **development only**. For production:

- Change default passwords
- Use `start` command instead of `start-dev`
- Enable HTTPS/TLS
- Use proper database credentials
- Enable theme caching
- Configure proper network security
- Use environment-specific configuration files

## Troubleshooting

### Keycloak won't start
- Check if port 8081 is already in use
- Verify Docker and Docker Compose are running
- Check logs: `docker-compose logs keycloak`

### Theme not appearing
- Ensure the theme directory is properly mounted
- Check theme.properties file exists
- Verify theme name matches directory name
- Check Keycloak logs for theme loading errors

### Database connection issues
- Ensure PostgreSQL container is running: `docker-compose ps`
- Check database credentials match in both services
- Verify network connectivity: `docker-compose logs postgres`

## License

This project is provided as-is for development and testing purposes.
# keycloak
