FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

# Package version when installing by pip. ex.) 0.5.0
ARG KALLITHEA_VER=

# Software preparation
RUN apt-get update \
 && : This is what to keep installed in the image. \
 && apt-get install -y --no-install-recommends \
                    dumb-init nginx locales mercurial git python \
 && : This is only needed for kallithea installation. \
 && apt-get install -y --no-install-recommends \
                    build-essential libffi-dev \
                    python-pip python-setuptools python-dev npm libpq-dev libmysqlclient-dev \
 && : Install kallithea and optional packages.\
 && pip install --no-cache-dir kallithea${KALLITHEA_VER:+==$KALLITHEA_VER} \
 && pip install --no-cache-dir psycopg2 \
 && pip install --no-cache-dir mysqlclient \
 && : Preparing the front-end files. \
 && kallithea-cli front-end-build \
 && : Clean up installation materials. \
 && apt-get purge -y \
                  python-pip python-dev npm libpq-dev libmysqlclient-dev \
                  build-essential libffi-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm /etc/nginx/sites-enabled/*

# Prepare a directory for storing persistent data.
RUN mkdir -p /kallithea/config \
 && mkdir -p /kallithea/repos \
 && mkdir -p /kallithea/logs

# Copy assets.
COPY ./assets/kallithea_proxy /etc/nginx/sites-enabled/kallithea_proxy
COPY ./assets/startup.sh /kallithea/startup.sh

# Service port
EXPOSE 80

# Startup command
CMD ["dumb-init", "bash", "/kallithea/startup.sh"]
