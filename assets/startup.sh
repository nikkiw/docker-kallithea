#!/bin/bash

# generate locale
LANG=${KALLITHEA_LOCALE:-"en_US.UTF-8"}
locale-gen --lang ${LANG}
export LANG

# settings file path
KALLITHEA_INI=/kallithea/config/kallithea.ini

# perform initialization when there is no settings file
if [ ! -e $KALLITHEA_INI ]; then
    # create config file
    echo "Creating configuration file..."
    kallithea-cli config-create $KALLITHEA_INI
    cp $KALLITHEA_INI

    # replace external database
    if [ -n "$KALLITHEA_EXTERNAL_DB" ]; then
        echo "Setting db connection string..."
        DB_ESC=$(echo "$KALLITHEA_EXTERNAL_DB" | sed -e 's/[\/&]/\\&/g')
        sed -i "s/^sqlalchemy\.url\s*=.*$/sqlalchemy.url = ${DB_ESC}/1" $KALLITHEA_INI
    fi

    # ui language
    if [ -n "$KALLITHEA_LANG" ]; then
        echo "Setting language to ${KALLITHEA_LANG}"
        sed -i "s/^i18n\.lang\s*=.*$/i18n.lang = ${KALLITHEA_LANG}/1" $KALLITHEA_INI
    fi

    # cookie expiration time
    sed -ri 's/^(beaker.session.timeout =.*)$/\1\nbeaker.session.cookie_expires = 2592000/1' $KALLITHEA_INI

    # initialize database
    echo "Creating database..."
    kallithea-cli db-create -c $KALLITHEA_INI \
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
    PATCH_FILE=/usr/local/lib/python2.7/dist-packages/kallithea/templates/index_base.html
    sed -i "s/^                order: \[\[1, \"asc\"\]\],$/                order: [[${KRS_IDX}, \"${KRS_ODR}\"]],/1" $PATCH_FILE
fi

echo "Start kallithea..."
gearbox serve -c $KALLITHEA_INI &

echo "Start nginx reverse proxy..."
nginx -g "daemon off;"
