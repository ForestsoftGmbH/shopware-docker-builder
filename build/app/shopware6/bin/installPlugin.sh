#!/bin/bash
echo "Refresh Plugin list"
su -s/bin/bash -c"/var/www/html/bin/console plugin:refresh" www-data >> /dev/null

PLUGINS=""
if [ -d "/var/www/html/custom/plugins" ]; then
  cd /var/www/html/custom/plugins
  PLUGINS=$(ls .);
fi
if [ -d "/var/www/html/custom/project" ]; then
  cd /var/www/html/custom/project
  PLUGINS="$(echo $PLUGINS) $(ls .)"
fi
clearNeeded=0
for plugin in ${PLUGINS}; do
  if [ "$plugin" != "" ]; then
    notInstalled=$(php /var/www/html/bin/plugin.php $plugin installed);
    if [ "$notInstalled" == "1" ]; then
      echo "Install Plugin $plugin"
      su -s/bin/bash -c"/var/www/html/bin/console plugin:install -a $plugin" www-data
      clearNeeded=1
    fi
    notActive=$(php /var/www/html/bin/plugin.php $plugin active);
    if [ "$notActive" == "1" ]; then
      echo "Activate $plugin"
      su -s/bin/bash -c"/var/www/html/bin/console plugin:activate $plugin" www-data
      clearNeeded=1
    fi
    updateActive=$(php /var/www/html/bin/plugin.php $plugin update);
    if [ "$updateActive" == "1" ]; then
      su -s/bin/bash -c"/var/www/html/bin/console plugin:update $plugin" www-data
      clearNeeded=1
    fi
  fi
done
if [ "$clearNeeded" == "1" ]; then
  echo "Clearing the cache"
  su -s/bin/bash -c"/var/www/html/bin/console cache:clear" www-data
fi
su -s/bin/bash -c"/var/www/html/bin/console plugin:update:all" www-data