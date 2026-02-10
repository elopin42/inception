FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql php-curl php-gd php-xml php-mbstring php-zip \
    wget unzip curl mariadb-client \
    && mkdir -p /run/php \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Download WordPress
RUN mkdir -p /var/www/wordpress \
    && wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /var/www/ \
    && chown -R www-data:www-data /var/www/wordpress \
    && rm /tmp/wordpress.tar.gz

COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
