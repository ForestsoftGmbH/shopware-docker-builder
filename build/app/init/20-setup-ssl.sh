#!/bin/sh
if [ ! -f "/etc/ssl/certs/ssl-cert-snakeoil.pem" ] && [ "${DO_SSL_CREATE:-"0"}" != "0" ]; then
  if [ "${APP_HOST:-""}" = "" ]; then
    export APP_HOST="localhost"
  fi

  echo ""
  echo "Genereating SSL certificate for Host $APP_HOST"
  echo ""
  openssl req -x509 -subj "/CN=${APP_HOST}" -nodes -days 365 -newkey rsa:4096 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem
fi