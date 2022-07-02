#!/bin/bash
if [ "$1" == "enable" ]; then
  if [ -f "/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini" ]; then
    sed -i -e 's#;zend_extension=xdebug#zend_extension=xdebug#g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
  else
    echo "zend_extension=xdebug" >>   /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
  fi
fi

if [ "$1" == "disable" ]; then
  sed -i -e 's#zend_extension=xdebug#;zend_extension=xdebug#g' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

if [ "$1" == "status" ]; then
  fgrep ';zend_extension=xdebug' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && echo "XDEBUG disabled" || echo "XDEBUG enabled"
fi
