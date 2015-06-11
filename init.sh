#!/bin/bash

# Add the dotdeb repositories
echo "
deb http://packages.dotdeb.org wheezy all
deb-src http://packages.dotdeb.org wheezy all
deb http://packages.dotdeb.org wheezy-php56 all
deb-src http://packages.dotdeb.org wheezy-php56 all
" >> /etc/apt/sources.list

wget http://www.dotdeb.org/dotdeb.gpg
apt-key add dotdeb.gpg

# PHP and NGinx installation
apt-get -y update
apt-get -y install git vim
apt-get install -y --force-yes php5 php5-apcu php5-cli php5-fpm php5-mysqlnd php5-mcrypt php5-gd php5-curl php5-intl
apt-get install -y --force-yes nginx

# MySQL installation
debconf-set-selections <<< 'mysql-server mysql-server/root_password password magento2'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password magento2'
apt-get install -y --force-yes mytop mysql-server-5.6

update-rc.d mysql defaults
/etc/init.d/mysql start

mysql -uroot -pmagento2 -e "CREATE SCHEMA magento2";

# Magento installation
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

mkdir /opt/hosting
cd /opt/hosting

git clone https://github.com/magento/magento2.git
cd magento2
composer install --no-interaction

chmod +x bin/magento
chmod -R 777 var/
chmod -R 777 pub/

echo "

upstream fastcgi_backend {
    server   unix:/var/run/php5-fpm.sock;
}

server {
    listen 80;
    server_name mage.dev;
    set \$MAGE_ROOT /opt/hosting/magento2/;
    set \$MAGE_MODE developer;
    include /opt/hosting/magento2/nginx.conf.sample;
}
" > /etc/nginx/sites-enabled/magento2
/etc/init.d/nginx restart

# Magento configuration
php bin/magento setup:install --base-url=http://mage.dev --backend-frontname=admin --db-name=magento2 --db-user=root --db-password=magento2 --admin-firstname=Magento --admin-lastname=User --admin-email=user@example.com --admin-user=admin --admin-password=admin123 --language=en_US --currency=USD --timezone=America/Chicago --use-rewrites=1