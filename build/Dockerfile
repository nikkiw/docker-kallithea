FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

# Package version when installing by pip. ex.) 0.5.0
ARG KALLITHEA_VER=0.5.0

# Pass the path in advance to the directory where kallithea is installed.
ENV PATH $PATH:/home/kallithea/.local/bin

# Software preparation
RUN apt-get update \
 && : This is what to keep installed in the image. \
 && apt-get install -y --no-install-recommends \
                    dumb-init gosu nginx locales mercurial git python python-setuptools \
 && : Prepare kallithea execution user. \
 && groupadd kallithea \
 && useradd -m -c '' -g kallithea kallithea \
 && : This is only needed for kallithea installation. \
 && apt-get install -y --no-install-recommends \
                    build-essential libffi-dev \
                    python-pip python-dev npm libpq-dev libmysqlclient-dev \
 && : Install kallithea and optional packages.\
 && gosu kallithea:kallithea pip install --no-cache-dir --user kallithea${KALLITHEA_VER:+==$KALLITHEA_VER} \
 && gosu kallithea:kallithea pip install --no-cache-dir psycopg2 \
 && gosu kallithea:kallithea pip install --no-cache-dir mysqlclient \
 && : Preparing the front-end files. \
 && gosu kallithea:kallithea kallithea-cli front-end-build \
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
 && mkdir -p /kallithea/logs \
 && chown kallithea:kallithea /kallithea/config \
 && chown kallithea:kallithea /kallithea/repos \
 && chown kallithea:kallithea /kallithea/logs

# Copy assets.
COPY ./assets/kallithea_proxy /etc/nginx/sites-enabled/kallithea_proxy
COPY ./assets/startup.sh /kallithea/startup.sh

# Service port
EXPOSE 80

# Startup command
CMD ["dumb-init", "bash", "/kallithea/startup.sh"]
