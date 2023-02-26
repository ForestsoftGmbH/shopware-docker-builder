#!/bin/bash
write_config ( ) {
  if [ -n "$3" ]; then
    conf=$3
  else 
    conf=50-forestsoft.ini
  fi

  if [ -n "$1" ] && [ -n "$2" ]; then
     echo "$1 = $2" >> /usr/local/etc/php/conf.d/$conf
  fi    
}

write_config "xdebug.client_host" "$XDEBUG_IP" "docker-php-ext-xdebug.ini"

if [ "${XDEBUG_ENABLED:-""}" != "" ]; then
  write_config "xdebug.client_mode" "debug" "docker-php-ext-xdebug.ini"
fi


write_config "error_reporting" "$PHP_ERR_REPORTING"
write_config "session.save_handler" "$SESSION_HANDLER"
write_config "session.save_path" "\"$SESSION_SAVE_PATH\""