#!/bin/bash

if [ "${PHP_VERSION:0:3}" = "7.3" ]; then
  docker-php-ext-configure gd --with-freetype-dir --with-jpeg-dir;
else
  docker-php-ext-configure gd --with-freetype --with-jpeg;
fi