#!/bin/bash
set -e -o pipefail

SW_VERSION=${1:-"6.5.0.0"}
PSALM_VERSION=${2:-"5.15.0"}
PHP_VERSION=${3:-"8.2"}
MYSQL_VERSION=${4:-"8.0"}
COMPOSER_VERSION=${5:-"2.1.3"}
SW_MAJOR=${SW_VERSION:0:1}

if [ "" == "$PHP_VERSION" ]; then
  PHP_VERSION=8.2
fi
if [ "" == "$MYSQL_VERSION" ]; then
  MYSQL_VERSION=8.0
fi
if [ "" == "$SW_VERSION" ]; then
  echo "Please specify shopware version"
  exit 255
fi

export SW_VERSION=$SW_VERSION
export MYSQL_VERSION=$MYSQL_VERSION
export PHP_VERSION=$PHP_VERSION

if [ "${SW_VERSION:0:1}" == "6" ]; then
  REMOTE_REPO="https://github.com/shopware/production.git"
else
  REMOTE_REPO="https://github.com/shopware5/shopware.git"
fi

docker build -t forestsoft/shopware:$SW_VERSION \
  --build-arg SW_VERSION${SW_VERSION} \
  --build-arg PSALM_VERSION=${PSALM_VERSION} \
  --build-arg SW_MAJOR=${SW_MAJOR} \
  --build-arg REMOTE_REPO=${REMOTE_REPO} \
  --build-arg COMPOSER_VERSION=${COMPOSER_VERSION} \
  --build-arg PHP_VERSION=${PHP_VERSION} \
  .