ARG VERSION="5.6"
FROM mysql:$VERSION as builder
ARG SW_MAJOR=5
ENV MYSQL_ROOT_PASSWORD "root"
COPY shopware${SW_MAJOR}/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
RUN chmod 755 /docker-entrypoint-initdb.d/*.sh

RUN echo "[client]" > /root/.my.cnf \
   && echo "user=root" >> /root/.my.cnf \
   && echo "password=${MYSQL_ROOT_PASSWORD}" >> /root/.my.cnf


HEALTHCHECK --timeout=5s --start-period=30s CMD /usr/bin/mysql $MYSQL_DATABASE -e "SELECT COUNT(*) as cnt FROM s_core_shops" || exit 1

FROM mysql:$VERSION as shopware5
ENV MYSQL_ROOT_PASSWORD "root"
ENV MYSQL_DATABASE=shopware
ENV MYSQL_USER=shopware
ENV MYSQL_PASSWORD=shopware
ENV APP_HOST="localhost"
COPY --from=builder /docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --from=builder  /root/.my.cnf /root/.my.cnf
HEALTHCHECK --timeout=5s --start-period=30s CMD /usr/bin/mysql $MYSQL_DATABASE -e "SELECT COUNT(*) as cnt FROM s_core_shops" || exit 1

FROM mysql:$VERSION as shopware6

ARG SW_VERSION=6.4.2.0
ARG SW_MAJOR=6
ENV MYSQL_ROOT_PASSWORD "root"
ENV MYSQL_DATABASE=shopware
ENV MYSQL_USER=shopware
ENV MYSQL_PASSWORD=shopware
ENV APP_URL="https://localhost"
ENV APP_HOST="localhost"

COPY --from=builder /docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --from=builder  /root/.my.cnf /root/.my.cnf
HEALTHCHECK --timeout=5s --start-period=30s CMD /usr/bin/mysql -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE -e "SELECT COUNT(*) FROM sales_channel_domain" || exit 1