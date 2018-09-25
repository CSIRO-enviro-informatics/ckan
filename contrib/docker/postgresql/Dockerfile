FROM postgres:9.6.8
MAINTAINER CSIRO

RUN apt-get update
RUN apt-get install -y --no-install-recommends postgresql-9.6-postgis-2.5 postgresql-9.6-postgis-scripts
RUN apt-get purge -y --auto-remove &&	rm -rf /etc/apt/sources.list.d/temp.list
# Allow connections; we don't map out any ports so only linked docker containers can connect
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/postgresql/data/pg_hba.conf

# Customize default user/pass/db
ENV POSTGRES_USER ckan
ENV POSTGRES_PASSWORD default_password
ENV POSTGRES_DB ckan

# Include datastore setup scripts
COPY ./docker-entrypoint-initdb.d /docker-entrypoint-initdb.d
