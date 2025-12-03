FROM debian:bookworm

RUN apt update && apt install -y \
    php php-fpm php-mysql php-curl php-gd php-xml php-mbstring php-zip wget unzip curl mariadb-client && \
    mkdir -p /run/php && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Installer WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Préparer WordPress
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000


RUN mkdir -p /var/www \
	&& wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz \
	&& tar -xvf /tmp/wordpress.tar.gz -C /var/www/ \
	&& chown -R www-data:www-data /var/www/wordpress \
	&& rm /tmp/wordpress.tar.gz

ENTRYPOINT ["/entrypoint.sh"]
