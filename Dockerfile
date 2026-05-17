# Step 1: Use the official PHP image
FROM php:8.4-fpm-alpine

# Set working directory
WORKDIR /var/www

# Install essential system dependencies (Alpine Linux equivalents for smaller image size)
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    zip \
    unzip \
    bash \
    postgresql-dev \
    libxml2-dev \
    oniguruma-dev

# Install and configure PHP extensions for PostgreSQL and general performance
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install \
        pdo \
        pdo_pgsql \
        pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        opcache

# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Copy custom OPcache configuration
COPY ./docker/php/opcache.ini $PHP_INI_DIR/conf.d/opcache.ini

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 1. Leverage Docker cache: Copy only composer files first
COPY composer.json composer.lock /var/www/

# 2. Install production dependencies (skips phpunit, fzaninotto, etc.)
RUN composer install \
    --no-dev \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist \
    --no-autoloader

# 3. Copy the rest of your application code
COPY . /var/www

# 4. Optimize the autoloader now that all source files are present
RUN composer dump-autoload --optimize --no-dev

# Set strict production permissions (www-data user)
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Switch to the non-root user for security
USER www-data

EXPOSE 9000
CMD ["php-fpm"]