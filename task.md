# Task: Dockerize the Laravel App for Production

This Laravel microservice is missing its production Docker setup.

Create the following files in this folder:

- `Dockerfile`
- `docker-compose.yml`
- `.dockerignore`
- `docker/nginx/default.conf`
- `docker/php/opcache.ini`

## Requirements

### `Dockerfile`

Create a production Dockerfile that:

- Uses PHP-FPM for the Laravel application.
- Uses Nginx as the public web server.
- Does not run `php artisan serve`.
- Installs the PHP extensions needed by this app, including:
  - `bcmath`
  - `intl`
  - `mbstring`
  - `opcache`
  - `pcntl`
  - `pdo_pgsql`
  - `pgsql`
  - `zip`
- Installs Composer dependencies with production settings:

```sh
composer install --no-dev --prefer-dist --no-interaction --no-progress --no-scripts --optimize-autoloader
```

- Builds frontend assets with Node using:

```sh
npm ci
npm run build
```

- Copies the built `vendor` directory into the Laravel app image.
- Copies the built Vite assets from `public/build`.
- Copies `docker/php/opcache.ini` into PHP's config directory.
- Creates these writable Laravel directories if they do not exist:
  - `storage/framework/cache`
  - `storage/framework/sessions`
  - `storage/framework/views`
  - `storage/logs`
  - `bootstrap/cache`
- Sets ownership of `storage` and `bootstrap/cache` to `www-data`.
- Runs the final Laravel app container as `www-data`.
- Exposes PHP-FPM on port `9000`.
- Creates a separate Nginx build target that copies:
  - `docker/nginx/default.conf`
  - `public`
  - built assets from `public/build`

### `docker-compose.yml`

Create a Compose file that defines these services:

- `app`
- `nginx`
- `db`

The `app` service should:

- Build the `app` target from the Dockerfile.
- Use `.env` with `env_file`.
- Set production environment values:
  - `APP_ENV=production`
  - `APP_DEBUG=false`
  - `DB_CONNECTION=pgsql`
  - `DB_HOST=db`
  - `DB_PORT=5432`
- Depend on the `db` service.
- Use a shared Docker network.
- Avoid mounting the whole project folder as a bind mount.

The `nginx` service should:

- Build the `nginx` target from the Dockerfile.
- Depend on the `app` service.
- Map a host port, such as `9004`, to container port `80`.
- Use the same shared Docker network as `app`.

The `db` service should:

- Use a PostgreSQL image.
- Read the database name, username, and password from `.env` with safe defaults.
- Store database data in a named volume.
- Use the same shared Docker network.

### `docker/nginx/default.conf`

Create an Nginx config that:

- Listens on port `80`.
- Uses `/var/www/html/public` as the web root.
- Uses `index.php` and `index.html` as index files.
- Sends requests through Laravel's front controller with:

```nginx
try_files $uri $uri/ /index.php?$query_string;
```

- Passes PHP requests to the `app` service on port `9000`.
- Sets `SCRIPT_FILENAME` correctly for PHP-FPM.
- Blocks hidden files except `.well-known`.

### `docker/php/opcache.ini`

Create a production OPcache config that enables OPcache and uses production-friendly settings.

At minimum, include:

```ini
opcache.enable=1
opcache.enable_cli=1
opcache.validate_timestamps=0
opcache.memory_consumption=128
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
```

### `.dockerignore`

Create a Docker ignore file that excludes files and folders that should not be copied into the image, including:

- `.git`
- `.env`
- `node_modules`
- `vendor`
- `storage/logs/*`
- `storage/framework/cache/*`
- `storage/framework/sessions/*`
- `storage/framework/views/*`
- `npm-debug.log*`
- `.DS_Store`

## Check Your Work

From this folder, run:

```sh
docker compose up --build
```

In another terminal, run migrations:

```sh
docker compose exec app php artisan migrate --force
```

Then open:

```txt
http://localhost:9004
```

The Laravel app should load through Nginx, with PHP handled by the `app` container.

Stop the containers with:

```sh
docker compose down
```
