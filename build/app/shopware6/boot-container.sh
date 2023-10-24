#!/bin/bash
function includeScriptDir() {
    if [[ -d "$1" ]]; then
        for FILE in "$1"/*.sh; do
            echo "-> Executing ${FILE}"
            # run custom scripts, only once
            . "$FILE"
        done
    fi
}

if [ -d "/usr/local/bin/init.d" ]; then
  includeScriptDir "/usr/local/bin/init.d"
fi

includeScriptDir "/usr/local/bin/ssh-init"

includeScriptDir "/usr/local/bin/init/"

if [ "${DB_HOST:-""}" != "localhost" ]; then
  /usr/local/bin/wait-for-it.sh ${DB_HOST}:${DB_PORT} -t ${DB_WAIT_TIMEOUT:-120}
fi

if [ -f "/usr/local/etc/php/conf.d/xdebug.ini" ]; then
    mv /usr/local/etc/php/conf.d/xdebug.ini /tmp/xdebug.ini
fi

if [ "${APP_URL:-""}" != "" ] && [ ! -f "/var/www/html/config/jwt/public.pem" ]; then
  su -s/bin/bash -c "mkdir -p /var/www/html/config/jwt" www-data
  APP_URL="$APP_URL" /var/www/html/bin/console system:generate-jwt-secret --public-key-path=/var/www/html/config/jwt/public.pem
  rm -Rf /var/www/html/var/cache/*
  chown -R www-data:www-data /var/www/html/config/jwt/* /var/www/html/var/cache /var/www/html/var/log
fi
if [ "${SKIP_UPDATE:-"0"}" != "1" ]; then
    su -s/bin/bash -c "/var/www/html/bin/console system:update:prepare" www-data
    su -s/bin/bash -c "/var/www/html/bin/console system:update:finish" www-data
fi
if [ "${SKIP_PLUGIN_INSTALL:-"0"}" != "1" ]; then
  /var/www/html/bin/installPlugin.sh
fi
if [ "${SKIP_PLUGIN_UPDATE:-"0"}" != "1" ]; then
  su -s/bin/bash -c "/var/www/html/bin/console plugin:update:all" www-data
fi
if [ "${SKIP_THEME_COMPILE:-"0"}" != "1" ]; then
  su -s/bin/bash -c "/var/www/html/bin/console theme:compile" www-data
fi
if [ "${SKIP_ASSET_INSTALL:-"0"}" != "1" ]; then
  if [ "${SHOPWARE_ENV:-"production"}" == "test" ]; then
     export SHOPWARE_ENV="production" # Make sure bundles will be copied
  fi
  su -s/bin/bash -c "/var/www/html/bin/console assets:install" www-data
fi
if [ "${SKIP_INDEXING:-"0"}" != "1" ]; then
  su -s/bin/bash -c "php -d memory_limit=-1 /var/www/html/bin/console dal:refresh:index --skip product.indexer,media.indexer" www-data
fi
if [ -f "/tmp/xdebug.ini" ]; then
    mv /tmp/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
fi