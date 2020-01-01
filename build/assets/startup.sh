#!/bin/bash

# generate locale
LANG=${KALLITHEA_LOCALE:-"en_US.UTF-8"}
locale-gen --lang ${LANG}
update-locale LANG=${LANG}
export LANG

# fix permission
KALLITHEA_FIX_PERMISSION=$(echo ${KALLITHEA_FIX_PERMISSION:-TRUE} | tr [:lower:] [:upper:])
if [ "$KALLITHEA_FIX_PERMISSION" = "TRUE"  ]; then
    echo "Fix permissions ..."
    chown -R kallithea:kallithea /kallithea/config
    chown -R kallithea:kallithea /kallithea/repos
    find /kallithea/config -type d -exec chmod u+wrx {} \;
    find /kallithea/config -type f -exec chmod u+wr  {} \;
    find /kallithea/repos  -type d -exec chmod u+wrx {} \;
    find /kallithea/repos  -type f -exec chmod u+wr  {} \;
fi

# settings file path
KALLITHEA_INI=/kallithea/config/kallithea.ini

# perform initialization when there is no settings file
if [ ! -e "$KALLITHEA_INI" ]; then
    # create config file
    echo "Creating configuration file..."
    gosu kallithea:kallithea kallithea-cli config-create $KALLITHEA_INI

    # replace external database
    if [ -n "$KALLITHEA_EXTERNAL_DB" ]; then
        echo "Setting db connection string..."
        DB_ESC=$(echo "$KALLITHEA_EXTERNAL_DB" | sed -e 's/[\/&]/\\&/g')
        sed -ri "s/^\\s*sqlalchemy\\.url\\s*=.*\$/sqlalchemy.url = ${DB_ESC}/1" $KALLITHEA_INI
    fi

    # ui language
    if [ -n "$KALLITHEA_LANG" ]; then
        echo "Setting language to ${KALLITHEA_LANG}"
        sed -ri "s/^\\s*i18n\\.lang\\s*=.*\$/i18n.lang = ${KALLITHEA_LANG}/1" $KALLITHEA_INI
    fi

    # cookie expiration time
    sed -ri "s/^\\s*(beaker\\.session\\.timeout\\s*=.*)\$/\\1\nbeaker.session.cookie_expires = 2592000/1" $KALLITHEA_INI

    # initialize database
    echo "Creating database..."
    gosu kallithea:kallithea kallithea-cli db-create -c $KALLITHEA_INI \
        --user ${KALLITHEA_ADMIN_USER:-"admin"} \
        --password ${KALLITHEA_ADMIN_PASS:-"admin"} \
        --email ${KALLITHEA_ADMIN_MAIL:-"admin@example.com"} \
        --repos /kallithea/repos \
        --force-yes
fi

# repository list patch
if [ -n "$KALLITHEA_REPOSORT_IDX" ]; then
    KRS_IDX=$KALLITHEA_REPOSORT_IDX
    KRS_ODR=${KALLITHEA_REPOSORT_ORDER:-"asc"}
    PATCH_FILE=/home/kallithea/.local/lib/python2.7/site-packages/kallithea/templates/index_base.html
    sed -ri "s/^                order: \\[\\[1, \"asc\"\\]\\],\$/                order: [[${KRS_IDX}, \"${KRS_ODR}\"]],/1" $PATCH_FILE
fi

echo "Start nginx reverse proxy ..."
nginx -g "daemon off;" &

echo "Start kallithea ..."
gosu kallithea:kallithea gearbox serve -c $KALLITHEA_INI
