#!/bin/bash

if [ "${SESSION_HANDLER:-""}" != "" ]; then
    echo "session.save_handler = $SESSION_HANDLER" >> /usr/local/etc/php/conf.d/50-forestsoft.ini
    echo 'session.save_path = "${SESSION_SAVE_PATH}"' >> /usr/local/etc/php/conf.d/50-forestsoft.ini
fi

if [ "${XDEBUG_IP:-""}" != "" ]; then
  echo "xdebug.client_host=$XDEBUG_IP" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

if [ "${XDEBUG_ENABLED:-""}" != "" ]; then
  echo "xdebug.client_mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi