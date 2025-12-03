#!/bin/bash
set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

echo "[MariaDB setup] Starting configuration"

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
  echo "[MariaDB setup] Initializing database"
  mysql_install_db --user=mysql --ldata=/var/lib/mysql >/dev/null

  echo "[MariaDB setup] Starting temporary mysqld"
  mysqld_safe --skip-networking &
  sleep 5

  echo "[MariaDB setup] Configuring users and database"
  mysql -u root <<-EOSQL
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

  mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
else
  echo "[MariaDB setup] Database already initialized"
fi

chown -R mysql:mysql /var/lib/mysql

echo "[MariaDB setup] Starting mysqld_safe"
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock --bind-address=0.0.0.0 --port=3306
