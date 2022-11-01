#!/bin/bash
echo "Refresh Plugin list"
su -s/bin/bash -c"/var/www/html/bin/console sw:plugin:refresh" www-data

echo "Update installed plugins"
su -s/bin/bash -c"/var/www/html/bin/console sw:plugin:update --no-refresh --batch active,installed" www-data

PLUGINS=""
if [ -d "/var/www/html/custom/project" ]; then
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
    echo "Check <$plugin> for installation..."
    notInstalled=$(php /var/www/html/bin/plugin.php $plugin installed);
    if [ "$notInstalled" == "1" ]; then
      echo "Install Plugin <$plugin>"
      /var/www/html/bin/console sw:plugin:install $plugin
      clearNeeded=1
    fi
    echo "Check <$plugin> for activation..."
    notActive=$(php /var/www/html/bin/plugin.php $plugin active);
    if [ "$notActive" == "1" ]; then
      echo "Activate <$plugin>"
      /var/www/html/bin/console sw:plugin:activate $plugin
      clearNeeded=1
    fi
    echo "Check <$plugin> for update version..."
    updateActive=$(php /var/www/html/bin/plugin.php $plugin update);
    if [ "$updateActive" == "1" ]; then
      /var/www/html/bin/console sw:plugin:update --no-refresh $plugin
      clearNeeded=1
    fi
  fi
done
if [ "$clearNeeded" == "1" ]; then
  echo "Clearing the cache"
  rm -Rf /var/www/html/cache/*
fi
