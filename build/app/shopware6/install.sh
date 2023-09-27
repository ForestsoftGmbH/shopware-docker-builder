#!/bin/bash
set -e
composer create-project shopware/production html

cp -R html/* /var/www/html/
touch /var/www/html/install.lock
