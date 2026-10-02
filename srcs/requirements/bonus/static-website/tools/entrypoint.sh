#!/bin/bash
set -e

cd /var/www/static

echo "Starting Python HTTP Server on port 8000 ..."
exec python3 -m http.server 8000 --bind 0.0.0.0