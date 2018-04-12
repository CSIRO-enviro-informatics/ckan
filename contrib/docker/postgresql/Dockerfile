#FROM postgres:9.6.6
FROM mdillon/postgis:9.6-alpine
#FROM kartoza/postgis:9.6-2.4
MAINTAINER CSIRO

# Allow connections; we don't map out any ports so only linked docker containers can connect
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf

# Customize default user/pass/db
ENV POSTGRES_USER ckan
ENV POSTGRES_PASSWORD default_password
ENV POSTGRES_DBNAME ckan
#ENV ALLOW_IP_RANGE 0.0.0.0/0

# Include datastore setup scripts
ADD ./docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
