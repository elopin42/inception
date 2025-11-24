#!/bin/bash
cd /var/www/html

# attend que MariaDB soit prêt
until mysql -h${WORDPRESS_DB_HOST} -u${WORDPRESS_DB_USER} -p${WORDPRESS_DB_PASSWORD} -e "SELECT 1;" &>/dev/null; do
  echo "Waiting for MariaDB..."
  sleep 2
done

if [ ! -f wp-config.php ]; then
  wp config create --dbname=${WORDPRESS_DB_NAME} --dbuser=${WORDPRESS_DB_USER} --dbpass=${WORDPRESS_DB_PASSWORD} --dbhost=${WORDPRESS_DB_HOST} --allow-root
  wp core install --url="https://${DOMAIN_NAME}" --title="Inception Site" --admin_user=${WP_ADMIN} --admin_password=${WP_ADMIN_PWD} --admin_email=${WP_ADMIN_EMAIL} --allow-root
fi

php-fpm8.2 -F
