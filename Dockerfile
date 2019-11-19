FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

ARG KALLITHEA_VER=

RUN apt-get update \
 && apt-get install -y dumb-init nginx locales mercurial git python \
                       build-essential libffi-dev \
                       python-pip python-dev npm libpq-dev libmysqlclient-dev \
 && pip install --no-cache-dir kallithea${KALLITHEA_VER:+==$KALLITHEA_VER} \
 && kallithea-cli front-end-build \
 && pip install --no-cache-dir psycopg2 \
 && pip install --no-cache-dir mysqlclient \
 && apt-get purge -y python-pip python-dev npm libpq-dev libmysqlclient-dev \
                     build-essential libffi-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm /etc/nginx/sites-enabled/*

RUN mkdir -p /kallithea/config \
 && mkdir -p /kallithea/repos \
 && mkdir -p /kallithea/logs

ADD ./assets/kallithea_proxy /etc/nginx/sites-enabled/kallithea_proxy
ADD ./assets/startup.sh /kallithea/startup.sh

# VOLUME ["/kallithea/config", "/kallithea/repos", "/kallithea/logs"]

EXPOSE 80

CMD ["dumb-init", "bash", "/kallithea/startup.sh"]
