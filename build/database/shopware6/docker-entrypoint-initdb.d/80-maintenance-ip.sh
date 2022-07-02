#!/bin/bash
if [ "${MAINTENANCE_IP}" != "" ]; then
  [ ! -x /usr/bin/jq ] && apt update && apt install -y jq
  IP_LIST=$(jq -n --arg v "$MAINTENANCE_IP" '$v | split("\n")')
  QUERY="update sales_channel SET maintenance=1, maintenance_ip_whitelist='${IP_LIST}';"
  mysql -v -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} -e "$QUERY"
fi