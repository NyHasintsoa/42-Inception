#!/bin/bash

set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -f "/var/lib/mysql/.inception-user-provisioned-v2" ]; then
    NEW_DATABASE=0
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        echo "Initializing MariaDB database system tables..."
        mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
        NEW_DATABASE=1
    fi

    mysqld_safe --user=mysql &

    until mysqladmin ping >/dev/null 2>&1; do
        sleep 1
    done

    if [ "$NEW_DATABASE" -eq 1 ]; then
        mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE OR REPLACE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    else
        mysql -u root -p"${DB_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE OR REPLACE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    fi

    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown

    touch /var/lib/mysql/.inception-user-provisioned-v2
fi

exec mysqld --user=mysql --bind-address=0.0.0.0