#!/bin/bash

export WP_CLI_PHP_ARGS='-d display_errors=0'

set -eu

echo "[WordPress setup] Waiting for MariaDB…"
until mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SHOW DATABASES;" >/dev/null 2>&1; do
  echo $WORDPRESS_DB_HOST $WORDPRESS_DB_USER $WORDPRESS_DB_PASSWORD
  echo "MariaDB is not ready yet…"
  sleep 2
done

echo "[WordPress setup] Configuring WordPress"

# Config PHP-FPM
if ! grep -q "listen = 0.0.0.0:9000" /etc/php/8.2/fpm/pool.d/www.conf; then
  echo "listen = 0.0.0.0:9000" >>/etc/php/8.2/fpm/pool.d/www.conf
fi

# Config wp-config
sed -i "s/username_here/$WORDPRESS_DB_USER/g" /var/www/wordpress/wp-config-sample.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" /var/www/wordpress/wp-config-sample.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/g" /var/www/wordpress/wp-config-sample.php
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" /var/www/wordpress/wp-config-sample.php

cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
chown -R www-data:www-data /var/www/wordpress

echo "[WordPress setup] Configuring wp"

cd /var/www/wordpress

if ! wp core is-installed --allow-root; then
  wp core install --url=elopin.42.fr --title=inception42 \
    --admin_user="$WP_ADMIN" --admin_password="$WP_ADMIN_PWD" \
    --admin_email="$WP_ADMIN_EMAIL" --skip-email --allow-root
fi

wp plugin install akismet --activate --allow-root
wp theme install twentytwentythree --activate --allow-root

echo "[WordPress setup] Configuring End"

exec php-fpm8.2 -F
