#!/bin/sh
RUN psql -c "create extension postgis"
RUN psql -c 'create extension "uuid-ossp"'
RUN createdb template_postgis
RUN psql template_postgis -c "UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis'"
