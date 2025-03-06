# Run services

docker compose -f postgres.yml up -d
docker compose -f keycloak.yml up -d
docker compose -f nginx.yml up -d
docker compose -f nexus.yml up -d