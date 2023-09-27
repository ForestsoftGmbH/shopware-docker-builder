#!/bin/bash

if [ "${PHP_VERSION:0:3}" = "7.3" ]; then
  docker-php-ext-configure gd --with-freetype-dir --with-jpeg-dir;
else
  docker-php-ext-configure gd --with-freetype --with-jpeg;
fi

cd /tmp/
if [ "$SW_MAJOR" == "5" ]; then
git clone $REMOTE_REPO shopware
  cd shopware \
  && git checkout v${SW_VERSION} \
  && rm -Rf .git/
fi
