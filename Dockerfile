ARG PHP_VERSION="7.4"
ARG COMPOSER_VERSION=2.1
ARG composerImage=composer:$COMPOSER_VERSION
FROM $composerImage as composerbuilder

FROM php:${PHP_VERSION}-apache
ARG SW_VERSION=5.6.6
ARG PSALM_VERSION=4.7.3
ARG SW_MAJOR=5
ENV COMPOSER_HTACCESS_PROTECT="0" \
    COMPOSER_HOME="/var/www/.composer" \
    DB_USER=shopware \
    DB_PASSWORD=shopware \
    DB_NAME=shopware \
    DB_HOST=database \
    DB_PORT=3306 \
    APP_URL=https://localhost \
    # E_ALL & ~E_USER_DEPRECATED & ~E_DEPRECATED & ~E_NOTICE
    PHP_ERR_REPORTING="8183" \
    PHP_OPCACHE_CLI_ENABLED="1" \
    PHP_OPCACHE_ENABLED="1" \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS="1" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="50000" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="15" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="512"
RUN apt update \
    && apt install -y gpg-agent curl zip lua-zlib-dev sudo libpng-dev libfreetype6-dev jq libjpeg62-turbo-dev \
        inotify-tools autoconf make g++ git openssl libicu-dev libzip-dev libonig-dev libxml2-dev make nano \
    && curl -sL https://deb.nodesource.com/setup_18.x | bash \
    && apt-get install -y nodejs \
    && mkdir -p /var/www/.npm /var/www/.config \
    && chown -R www-data:www-data /var/www /var/www/.npm /var/www/.config \
    && npm install -g grunt-cli \
    && npm install grunt --save-dev \
    && a2enmod ssl rewrite \
    && a2dismod deflate -f \
    && a2ensite default-ssl \
    && a2dismod access_compat \
    && pecl install xdebug redis \
    && echo "extension=redis.so" >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/40-redis.ini \
    && echo "memory_limit=1024M" >> /usr/local/etc/php/conf.d/50-forestsoft.ini \
    && echo "zend_extension=xdebug" >>  /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.start_with_request=yes" >>   /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.client_host=127.0.0.1" >>   /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.mode=debug" >>   /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

COPY ./docker-php-entrypoint /usr/local/bin/docker-php-entrypoint
COPY ./build/app/init /usr/local/bin/init
COPY ./build/app/install.sh /usr/local/bin/install.sh
COPY ./build/app/healthcheck.sh /usr/local/bin/healthcheck.sh
COPY ./build/app/shopware${SW_MAJOR}/install.sh /usr/local/bin/installsw${SW_MAJOR}.sh
RUN chmod -R 755 /usr/local/bin/docker-php-entrypoint /usr/local/bin/install.sh /usr/local/bin/healthcheck.sh /usr/local/bin/installsw${SW_MAJOR}.sh /usr/local/bin/init/ \
    && /usr/local/bin/install.sh \
    && sudo -E docker-php-ext-install -j$(nproc) gd intl pdo pdo_mysql zip mbstring simplexml mysqli opcache

WORKDIR /tmp/
COPY --from=composerbuilder /usr/bin/composer /usr/local/bin/composer
RUN chmod 755 /usr/local/bin/composer \
&& rm -Rf /var/www/html/*

USER www-data
RUN /usr/local/bin/installsw${SW_MAJOR}.sh
WORKDIR /var/www/html/
RUN composer require vimeo/psalm:${PSALM_VERSION}

USER root
COPY sw.phar /usr/local/bin/sw.phar
COPY xdebug.sh /usr/local/bin/xdebug.sh

COPY config.php /var/www/html/config.php
COPY build/app/shopware${SW_MAJOR}/etc/apache2/ /etc/apache2/
COPY build/app/shopware${SW_MAJOR}/etc/php/ /usr/local/etc/php/conf.d/
COPY build/app/shopware${SW_MAJOR}/bin/ /var/www/html/bin/
COPY build/app/shopware${SW_MAJOR}/boot-container.sh /usr/local/bin/boot-container.sh

COPY wait-for-it.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/wait-for-it.sh  /usr/local/bin/boot-container.sh /usr/local/bin/xdebug.sh /var/www/html/bin/* \
    && chown -R www-data:www-data /var/www/html \
    && if [ -f "/var/www/html/engine/Shopware/Kernel.php" ]; then sed -i "s/___VERSION___/${SW_VERSION}/g" /var/www/html/engine/Shopware/Kernel.php; fi \
    && if  [ -f "/var/www/html/engine/Shopware/Application.php" ]; then sed -i "s/___VERSION___/${SW_VERSION}/g"  /var/www/html/engine/Shopware/Application.php; fi \
    && apt clean \
    # This migration doesnt work:  Could not apply migration (Migrations_Migration1607). Error: SQLSTATE[HY000]: General error: 1093 You can't specify target table 's_core_config_values' for update in FROM clause
    && if [ -f "/var/www/html/_sql/migrations/1607-add-voucher-checkout-configs.php" ]; then rm /var/www/html/_sql/migrations/1607-add-voucher-checkout-configs.php; fi \
    && rm -Rf /var/www/html/recovery \
    && rm -Rf /var/www/.composer \
    && rm -Rf /var/www/html/.env \
    && mkdir /var/www/.composer \
    && chown www-data:www-data /var/www/.composer \
    && rm -Rf /var/lib/apt/lists/ \
    && rm /usr/local/bin/installsw${SW_MAJOR}.sh \
    && rm /usr/local/bin/install.sh \
    && /usr/local/bin/xdebug.sh disable
HEALTHCHECK --timeout=5s --start-period=30s CMD /usr/local/bin/healthcheck.sh