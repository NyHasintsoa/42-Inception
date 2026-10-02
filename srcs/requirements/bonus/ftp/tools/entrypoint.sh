#!/bin/bash

set -e

if ! id "$FTP_USER" &>/dev/null; then
    echo "Creating FTP user: $FTP_USER"
    useradd -m -d /var/www/wordpress -s /bin/bash "$FTP_USER"
    echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
fi

chown -R www-data:www-data /var/www/wordpress
usermod -aG www-data "$FTP_USER"

echo "Starting vsftpd..."
exec vsftpd /etc/vsftpd.conf