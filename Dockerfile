ARG PG_VERSION=16
FROM postgres:${PG_VERSION}

# change default data location for use with commiting the image. Default use if volume, and thus NOT part of the image. This changes the data to be part of the image if commited
RUN mkdir -p /var/lib/postgresql-static/data
ENV PGDATA /var/lib/postgresql-static/data

# copy script to wait for postgres starting up
COPY --chown=postgres:postgres wait_for_postgres.sh /usr/local/bin/wait_for_postgres
RUN chmod +x /usr/local/bin/wait_for_postgres

# root user and database configuration
ENV POSTGRES_USER "postgres"
ENV POSTGRES_PASSWORD "postgres"
ENV POSTGRES_DB "postgres"

# override default entrypoint that is running postgres in the foregrund.
# we do not want this because we want it to run in background while we put data in
RUN sed -i '/exec "$@"/d' /usr/local/bin/docker-entrypoint.sh

ONBUILD ARG TZ
ONBUILD ENV TZ ${TIMEZONE}

# setup the locale
ONBUILD ARG LOCALE_LANG
ONBUILD RUN localedef -i ${LOCALE_LANG} -c -f UTF-8 -A /usr/share/locale/locale.alias ${LOCALE_LANG}.UTF-8
ONBUILD ENV LANG ${LOCALE_LANG}.utf8

# initialize database
ONBUILD RUN /usr/local/bin/docker-entrypoint.sh postgres

ONBUILD ARG HOST
ONBUILD ARG USER
ONBUILD ARG DATABASE_NAME
ONBUILD ARG PRE_FILE
ONBUILD ARG POST_FILE

# copy pre and post sql files to run before and after dumping the database
ONBUILD COPY ${PRE_FILE} /data/pre.sql
ONBUILD COPY ${POST_FILE} /data/post.sql

# dump database
ONBUILD RUN --mount=type=secret,id=pgpass,dst=/root/.pgpass \
    cp /root/.pgpass /var/lib/postgresql/.pgpass \
 && chown postgres:postgres /var/lib/postgresql/.pgpass \
 && chmod 0600 /var/lib/postgresql/.pgpass \
 && gosu postgres pg_ctl start \
 && gosu postgres wait_for_postgres \
 && gosu postgres pg_isready --host="${HOST}" --timeout=10 \
 && gosu postgres psql --variable=ON_ERROR_STOP=1 --file=/data/pre.sql \
 && gosu postgres pg_dump --no-password --verbose --host="${HOST}" --username="${USER}" "${DATABASE_NAME}" | gosu postgres psql --variable=ON_ERROR_STOP=1 "${DATABASE_NAME}" \
 && rm /var/lib/postgresql/.pgpass \
 && gosu postgres psql --variable=ON_ERROR_STOP=1 --dbname="${DATABASE_NAME}" --file=/data/post.sql \
 && gosu postgres psql --variable=ON_ERROR_STOP=1 --dbname="${DATABASE_NAME}" --command="VACUUM (FULL)" \
 && gosu postgres pg_ctl --mode=smart --timeout=10 stop \
 && gosu postgres pg_resetwal -D "${PGDATA}"

ONBUILD USER postgres
ENTRYPOINT ["postgres"]
