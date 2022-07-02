#!/bin/bash

if [ "${SESSION_HANDLER:-""}" != "" ]; then
    echo "session.save_handler = $SESSION_HANDLER" >> /usr/local/etc/php/conf.d/50-forestsoft.ini
    echo 'session.save_path = "${SESSION_SAVE_PATH}"' >> /usr/local/etc/php/conf.d/50-forestsoft.ini
fi