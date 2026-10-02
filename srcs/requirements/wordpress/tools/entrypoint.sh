#!/bin/bash

set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
export HTTP_HOST="${DOMAIN_NAME}"
: "${WP_TITLE:?WP_TITLE must be set}" \
    "${WP_ADMIN_USER:?WP_ADMIN_USER must be set}" \
    "${WP_ADMIN_PASSWORD:?WP_ADMIN_PASSWORD must be set}" \
    "${WP_ADMIN_EMAIL:?WP_ADMIN_EMAIL must be set}" \
    "${WP_USER:?WP_USER must be set}" \
    "${WP_USER_PASSWORD:?WP_USER_PASSWORD must be set}" \
    "${WP_USER_EMAIL:?WP_USER_EMAIL must be set}"

#--------------------------------------------------
# 1. Wait for MariaDB & Redis Services
#--------------------------------------------------
echo "Waiting for MariaDB..."
until mariadb-admin ping -h"mariadb" -u"${WORDPRESS_DB_USER}" -p"${DB_PASSWORD}" --silent; do
    sleep 2
done

echo "Waiting for Redis..."
until php -r '$redis = new Redis(); if (!$redis->connect("redis", 6379) || !$redis->ping()) exit(1);' >/dev/null 2>&1; do
    sleep 2
done

#--------------------------------------------------
# 2. Setup WordPress Base Directory
#--------------------------------------------------
mkdir -p /var/www/wordpress
cd /var/www/wordpress

if [ ! -f "wp-load.php" ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
fi

if [ ! -f "wp-config.php" ]; then
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root
fi

if ! wp core is-installed --allow-root; then
    echo "Installing WordPress core..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
fi

if ! WP_ADMIN_ID=$(wp user get "${WP_ADMIN_USER}" --field=ID --allow-root 2>/dev/null); then
    WP_ADMIN_ID=$(wp user get "${WP_ADMIN_EMAIL}" --field=ID --allow-root 2>/dev/null || true)
fi

if [ -z "${WP_ADMIN_ID}" ]; then
    echo "Creating WordPress admin user..."
    wp user create "${WP_ADMIN_USER}" "${WP_ADMIN_EMAIL}" \
        --role=administrator \
        --user_pass="${WP_ADMIN_PASSWORD}" \
        --allow-root
    WP_ADMIN_ID=$(wp user get "${WP_ADMIN_USER}" --field=ID --allow-root)
fi
wp user update "${WP_ADMIN_ID}" \
    --user_login="${WP_ADMIN_USER}" \
    --user_email="${WP_ADMIN_EMAIL}" \
    --user_pass="${WP_ADMIN_PASSWORD}" \
    --role=administrator \
    --allow-root

if [ "${WP_USER}" = "${WP_ADMIN_USER}" ] || [ "${WP_USER_EMAIL}" = "${WP_ADMIN_EMAIL}" ]; then
    echo "Cannot create ${WP_USER}: WP_USER_EMAIL and WP_USER must be unique from the admin account." >&2
else
    if ! WP_USER_ID=$(wp user get "${WP_USER}" --field=ID --allow-root 2>/dev/null); then
        WP_USER_ID=$(wp user get "${WP_USER_EMAIL}" --field=ID --allow-root 2>/dev/null || true)
    fi

    if [ -z "${WP_USER_ID}" ]; then
        echo "Creating additional WordPress user..."
        wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
            --role=author \
            --user_pass="${WP_USER_PASSWORD}" \
            --allow-root
        WP_USER_ID=$(wp user get "${WP_USER}" --field=ID --allow-root)
    fi

    wp user update "${WP_USER_ID}" \
        --user_login="${WP_USER}" \
        --user_email="${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
fi

#--------------------------------------------------
# 3. Configure Redis Object Cache
#--------------------------------------------------
echo "Configuring Redis Object Cache..."
wp config set WP_CACHE true --raw --allow-root
wp config set WP_REDIS_HOST "redis" --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root
wp config set WP_REDIS_CLIENT "phpredis" --allow-root

if ! wp plugin is-installed redis-cache --allow-root; then
    echo "Installing Redis Cache plugin..."
    wp plugin install redis-cache --activate --allow-root
fi

if ! wp plugin is-active redis-cache --allow-root; then
    echo "Activating Redis Cache plugin..."
    wp plugin activate redis-cache --allow-root
fi

echo "Enabling Redis Object Cache..."
wp redis enable --allow-root || true

#--------------------------------------------------
# 4. Final Configurations & Hand-off
#--------------------------------------------------
wp option update home "https://${DOMAIN_NAME}" --allow-root
wp option update siteurl "https://${DOMAIN_NAME}" --allow-root

chown -R www-data:www-data /var/www/wordpress

mkdir -p /run/php
exec php-fpm8.4 -F