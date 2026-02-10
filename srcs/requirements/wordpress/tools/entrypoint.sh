#!/bin/bash
set -eu

echo "[WordPress setup] Waiting for MariaDB..."
until mysql -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" -e "SHOW DATABASES;" >/dev/null 2>&1; do
  sleep 2
done

echo "[WordPress setup] Configuring WordPress"

# Create wp-config.php from sample if not already done
if [ ! -f /var/www/wordpress/wp-config.php ]; then
  cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
  sed -i "s/username_here/$WORDPRESS_DB_USER/g" /var/www/wordpress/wp-config.php
  sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" /var/www/wordpress/wp-config.php
  sed -i "s/localhost/$WORDPRESS_DB_HOST/g" /var/www/wordpress/wp-config.php
  sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" /var/www/wordpress/wp-config.php
fi

chown -R www-data:www-data /var/www/wordpress

cd /var/www/wordpress

# Install WordPress core
if ! wp core is-installed --allow-root; then
  wp core install --url="$DOMAIN_NAME" --title="Inception" \
    --admin_user="$WP_ADMIN" --admin_password="$WP_ADMIN_PWD" \
    --admin_email="$WP_ADMIN_EMAIL" --skip-email --allow-root
fi

# Create second user (non-admin)
if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then
  wp user create "$WP_USER" "$WP_USER_EMAIL" \
    --role=author --user_pass="userpass42" --allow-root
fi

echo "[WordPress setup] Done"

exec php-fpm8.2 -F
