#!/bin/bash

curl --write-out '%{http_code}' --silent --output /dev/null -H "Host: ${APP_HOST:='localhost'}" -k https://localhost | grep 200 || exit 1