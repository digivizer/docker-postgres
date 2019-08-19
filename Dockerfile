FROM postgres:11
MAINTAINER Rob Sharp <rob.sharp@digivizer.com>

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates wget python-pip curl build-essential apt-utils

RUN \
  echo "deb [arch=amd64] http://packages.2ndquadrant.com/pglogical/apt/ jessie-2ndquadrant main\n" \
    > /etc/apt/sources.list.d/2ndquadrant.list

RUN wget --quiet -O - http://packages.2ndquadrant.com/pglogical/apt/AA7A6805.asc | apt-key add - && apt-get update

RUN apt-get install -y --no-install-recommends \
  postgresql-${PG_MAJOR}-pglogical

# Cleanup
RUN apt-get update -y -qq --fix-missing \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Configuration
COPY config/postgresql.conf "/usr/share/postgresql/${PG_MAJOR}/postgresql.conf.sample"
COPY config/pg_hba.conf "/usr/share/postgresql/${PG_MAJOR}/pg_hba.conf"
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY init.sh /docker-entrypoint-initdb.d/init.sh

CMD ["/docker-entrypoint.sh", "postgres"]

# HEALTHCHECK
COPY docker-healthcheck /usr/local/bin/
HEALTHCHECK CMD ["docker-healthcheck"]
