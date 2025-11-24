#!/bin/bash

# Init DB si vide
if [ ! -d /var/lib/mysql/mysql ]; then
  mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

  mysqld --user=mysql --bootstrap <<EOF
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER 'wpuser'@'%' IDENTIFIED BY 'wppass';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';
FLUSH PRIVILEGES;
EOF
fi

exec mysqld --user=mysql
