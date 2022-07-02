#!/bin/bash
set -e
function includeScriptDir() {
    if [[ -d "$1" ]]; then
        for FILE in "$1"/*.sh; do
            echo "-> Executing ${FILE}"
            # run custom scripts, only once
            . "$FILE"
        done
    fi
}

includeScriptDir "/usr/local/bin/init/"
includeScriptDir "/usr/local/bin/init.d"
includeScriptDir "/usr/local/bin/ssh-init"

/usr/local/bin/wait-for-it.sh ${DB_HOST}:${DB_PORT} -t ${DB_WAIT_TIMEOUT:-120}

su -s/bin/bash -c "/var/www/html/bin/console sw:migrations:migrate" www-data
su -s/bin/bash -c "/var/www/html/bin/console sw:generate:attributes" www-data
su -s/bin/bash -c "/var/www/html/bin/console sw:snippets:to:db" www-data

/var/www/html/bin/installPlugin.sh
