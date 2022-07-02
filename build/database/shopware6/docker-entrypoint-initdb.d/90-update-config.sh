#!/bin/bash
QUERY="update sales_channel_domain SET url='$APP_URL' WHERE sales_channel_id = (SELECT id FROM sales_channel WHERE type_id = x'8A243080F92E4C719546314B577CF82B') LIMIT 1"
mysql -v -uroot -p${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} -e "$QUERY"
