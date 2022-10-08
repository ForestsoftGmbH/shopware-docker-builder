#!/bin/bash
set -e -o pipefail

SW_VERSION=$1
SW_VERSION_LONG=$2
PHP_VERSION=$3
MYSQL_VERSION=$4

if [ "" == "$PHP_VERSION" ]; then
        PHP_VERSION=8.1
fi
if [ "" == "$MYSQL_VERSION" ]; then
        MYSQL_VERSION=5.7
fi
if [ "" == "$SW_VERSION" ]; then
    echo "Please specify shopware version"
    exit 255
fi

export SW_VERSION=$SW_VERSION
export MYSQL_VERSION=$MYSQL_VERSION
export PHP_VERSION=$PHP_VERSION

docker-compose -p shopware_$SW_VERSION down -v
docker-compose -p shopware_$SW_VERSION up --build -d

docker exec -i shopware_$SW_VERSION //bin/bash -c "/usr/local/bin/wait-for-it.sh database:3306 -t 120"
docker exec -e SW_TIMEOUT=500 -i shopware_$SW_VERSION //bin/bash -c "php /usr/local/bin/sw.phar install:vcs --branch $SW_VERSION -n --installDir=. --user=demo@demo.de --databaseName shopware"

docker exec	-i shopware_$SW_VERSION //bin/bash -c "cd /root/shopware-template/ && cp -R * /app/"
docker exec	-i shopware_$SW_VERSION //bin/bash -c "cd /app/ && composer update --no-scripts"
docker exec	-i shopware_$SW_VERSION //bin/bash -c "chown -R application:application /app/"
docker exec	-i shopware_$SW_VERSION //bin/bash -c " sed -i 's/___VERSION___/${SW_VERSION_LONG}/g' /app/engine/Shopware/Kernel.php"
docker exec	-i shopware_$SW_VERSION //bin/bash -c " sed -i 's/___VERSION___/${SW_VERSION_LONG}/g' /app/engine/Shopware/Application.php"
docker exec	-i shopware_db_$SW_VERSION //bin/bash -c "mysqldump -proot shopware > /docker-entrypoint-initdb.d/dump-sw-$SW_VERSION.sql && gzip /docker-entrypoint-initdb.d/dump-sw-$SW_VERSION.sql"

docker commit shopware_$SW_VERSION forestsoft/shopware:$SW_VERSION
docker commit shopware_db_$SW_VERSION forestsoft/shopware_database:$SW_VERSION
