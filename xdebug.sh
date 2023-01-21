#!/bin/bash
if [ "$1" == "enable" ]; then
  if [ -f "/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini" ]; then
    sed -i -e 's#;zend_extension=xdebug#zend_extension=xdebug#g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
  else
    echo "zend_extension=xdebug" >>   /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
  fi
  if [ ! -z $MAINTENANCE_IP ]; then
    sed -i -e "s#;xdebug.client_host=127.0.0.1#xdebug.client_host=$MAINTENANCE_IP#g" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
  fi
  sed -i -e 's#;xdebug.mode=debug#xdebug.mode=debug#g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

if [ "$1" == "disable" ]; then
  sed -i -e 's#zend_extension=xdebug#;zend_extension=xdebug#g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

if [ "$1" == "status" ]; then
  fgrep ';zend_extension=xdebug' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && echo "XDEBUG disabled" || echo "XDEBUG enabled"
fi
