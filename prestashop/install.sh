#!/usr/bin/env sh

#
# Commands to install WordPress dev environment.
#
# Example usage:
#
#   ssh <target host> sudo /bin/sh < <this filename>
#
# Alternatively use `deploy <target host>`.
#

echo "Installing packages..."
echo "---"

cat > /etc/apt/sources.list.d/wheezy-backports.list <<EOF
deb http://cloudfront.debian.net/debian wheezy-backports main
deb-src http://cloudfront.debian.net/debian wheezy-backports main
EOF

apt-get update
apt-get --yes install zsh zile less rsync curl
apt-get --yes install memcached
apt-get --yes install nginx
apt-get --yes install mysql-server-5.5
apt-get --yes install php5-fpm php5-memcached php5-mysql php5-gd

mysqladmin -uroot create prestashop-dev

echo "---"
echo "Installing files..."
echo "---"

cd /tmp/deploy/

# hosts
cp -v hosts /etc/hosts
chown root:root /etc/hosts
chmod 644 /etc/hosts

# timezone
cp -v timezone /etc/timezone
chown root:root /etc/timezone
chmod 644 /etc/timezone

# PHP
touch /var/log/php.log /var/log/php5-fpm.log
chown www-data:adm /var/log/php.log
chown root:adm /var/log/php5-fpm.log
cp -v php.ini /etc/php5/fpm/php.ini
cp -v php-fpm-pool.www.conf /etc/php5/fpm/pool.d/www.conf
rm -f /etc/php5/conf.d/* # modules loaded in main php.ini

# nginx
cp -v nginx.conf /etc/nginx/nginx.conf
chmod 644 /etc/nginx/nginx.conf

echo "---"
echo "Cleaning up..."

cd ..
rm -rf deploy/

echo "Restarting daemons..."
echo "---"
/etc/init.d/php5-fpm restart
/etc/init.d/nginx restart
/etc/init.d/mysql restart



