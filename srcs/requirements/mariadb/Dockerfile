FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server mariadb-client && rm -rf /var/lib/apt/lists/*

RUN echo "[mysqld]\nbind-address=0.0.0.0" > /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

CMD ["/entrypoint.sh"]


