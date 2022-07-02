#!/bin/bash

QUERY="UPDATE s_core_shops SET host='${APP_HOST}'"
echo $QUERY
mysql -v -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} -e "$QUERY"
