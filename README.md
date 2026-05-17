# microservice1 Setup Guide

`microservice1` is a Laravel API served through Nginx on port `9000`.

## Prerequisites

- Docker Desktop
- Docker Compose
- Shared PostgreSQL from `../postgredb`
- External Docker network named `app-network`

## Docker Setup

1. Create the shared Docker network if it does not exist:

   ```bash
   docker network create app-network
   ```

2. Start the shared PostgreSQL service:

   ```bash
   cd ../postgredb
   docker compose up -d
   ```

3. Copy the Laravel environment file:

   ```powershell
   cd ../microservice1
   Copy-Item .env.example .env
   ```

   On macOS, Linux, Git Bash, or WSL:

   ```bash
   cp .env.example .env
   ```

4. Update `.env` for Docker:

   ```env
   DB_CONNECTION=pgsql
   DB_HOST=db
   DB_PORT=5432
   DB_DATABASE=sampledb
   DB_USERNAME=postgres
   DB_PASSWORD=postgres
   ```

5. Build and start the API:

   ```bash
   docker compose up -d --build
   ```

6. Generate the app key and run migrations:

   ```bash
   docker compose exec app php artisan key:generate
   docker compose exec app php artisan migrate --seed
   ```

Open:

```text
http://localhost:9000
```

## Useful Commands

```bash
docker compose exec app php artisan test
docker compose exec app php artisan migrate:fresh --seed
docker compose down
```

