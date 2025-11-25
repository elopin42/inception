FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y mariadb-server mariadb-client tini gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY tools/setup.sh /usr/local/bin/mariadb/setup.sh
RUN chmod +x /usr/local/bin/mariadb/setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/mariadb/setup.sh"]



