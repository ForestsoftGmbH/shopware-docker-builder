#!/bin/bash
set +e
. /usr/local/bin/init/setup-ssl.sh
apache2ctl start
/usr/local/bin/wait-for-it.sh localhost:443 -t 90
echo "curl --write-out '%{http_code}' --silent --output /dev/null -k -H "Host: $APP_HOST" https://localhost"
response=$(curl --write-out '%{http_code}' --silent --output /dev/null -k -H "Host: $APP_HOST" https://localhost)
echo -n "HTTP Status: $response"
if [ "$response" != "200" ]; then
  echo " - Error"
  set -e
  curl --silent -k -I -H "Host: $APP_HOST" https://localhost || exit $?
  curl --silent -k -H "Host: $APP_HOST" https://localhost
  if [ -f "/app/var/log/${APP_ENV}.log" ]; then
    tail /app/var/log/${APP_ENV}.log
  fi
  exit $response
else
  echo " - OK"
  echo "Everything went well - Container is reachable over https"
  exit 0
fi
