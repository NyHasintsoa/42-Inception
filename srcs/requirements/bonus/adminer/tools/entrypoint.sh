#!/bin/bash
set -e

mkdir -p /var/www/adminer
cd /var/www/adminer

if [ ! -f "index.php" ]; then
    echo "Downloading Adminer..."
    curl -L -o index.php https://github.com/vrana/adminer/releases/download/v6.1.1/adminer-6.1.1.php
fi

exec php -S 0.0.0.0:8080 -t /var/www/adminer