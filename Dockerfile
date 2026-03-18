FROM quay.io/keycloak/keycloak:22.0.0

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure database for build (must match runtime)
ENV KC_DB=postgres

# Copy custom themes
COPY themes/ /opt/keycloak/themes/

# Build the image to optimize startup
# This bakes the PostgreSQL driver and themes into the image
RUN /opt/keycloak/bin/kc.sh build

# Change back to keycloak user (good practice)
USER keycloak
