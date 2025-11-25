#!/bin/sh
set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Load secrets if using Docker secrets
# if [ -d /run/secrets ]; then
#   for file in /run/secrets/*; do
#     name=$(basename "$file")
#     value=$(cat "$file")
#     export "$name=$value"
#   done
# fi

DB_DIR="/var/lib/mysql"

# -------------------------- INIT DB --------------------------
if [ ! -d "$DB_DIR/${MYSQL_DATABASE}" ]; then
  echo "[MariaDB] Initializing database directory..."
  mariadb-install-db --user=mysql --datadir="$DB_DIR"

  echo "[MariaDB] Starting temporary MariaDB server..."
  mariadbd --skip-networking --user=mysql &
  pid="$!"

  # Wait for MariaDB
  until mysqladmin ping >/dev/null 2>&1; do
    echo "[MariaDB] Waiting for server..."
    sleep 1
  done

  echo "[MariaDB] Running initial SQL setup..."

  cat <<EOF | mariadb -u root
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

  echo "[MariaDB] Stopping temporary MariaDB server..."
  kill "$pid"
  wait "$pid"
else
  echo "[MariaDB] Existing database detected, skipping init."
fi

# ---------------------- START FINAL SERVER ----------------------
echo "[MariaDB] Starting MariaDB normally..."
exec mariadbd --user=mysql --bind-address=0.0.0.0 --console
