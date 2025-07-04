# Run services

docker network create "devnet"
docker compose -f postgres.yml up -d
docker compose -f keycloak.yml up -d
docker compose -f nginx.yml up -d