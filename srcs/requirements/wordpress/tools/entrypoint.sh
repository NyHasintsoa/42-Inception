#!/bin/bash

set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
: "${DOMAIN_NAME:?DOMAIN_NAME must be set}"
export HTTP_HOST="${DOMAIN_NAME}"

echo "Waiting for MariaDB..."
until mariadb-admin ping -h"mariadb" -u"${WORDPRESS_DB_USER}" -p"${DB_PASSWORD}" --silent; do
    sleep 2
done

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
        --title="Inception" \
        --admin_user="wpadmin" \
        --admin_password="${DB_PASSWORD}" \
        --admin_email="admin@${DOMAIN_NAME}" \
        --skip-email \
        --allow-root
fi

if ! wp user get user1 --allow-root >/dev/null 2>&1; then
    echo "Creating additional WordPress user..."
    wp user create user1 "user1@${DOMAIN_NAME}" \
        --role=author \
        --user_pass="${DB_PASSWORD}" \
        --allow-root
fi

wp option update home "https://${DOMAIN_NAME}" --allow-root
wp option update siteurl "https://${DOMAIN_NAME}" --allow-root

chown -R www-data:www-data /var/www/wordpress

mkdir -p /run/php
exec php-fpm8.4 -F