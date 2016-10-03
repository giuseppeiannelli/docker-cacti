#!/bin/sh

update_cacti_db_config() {
    set -x \
    && sed -i 's/$DB_TYPE/'$DB_TYPE'/g' /usr/share/nginx/cacti/include/config.php \
    && sed -i 's/$DB_NAME/'$DB_NAME'/g' /usr/share/nginx/cacti/include/config.php \
    && sed -i 's/$DB_HOSTNAME/'$DB_HOSTNAME'/g' /usr/share/nginx/cacti/include/config.php \
    && sed -i 's/$DB_USERNAME/'$DB_USERNAME'/g' /usr/share/nginx/cacti/include/config.php \
    && sed -i 's/$DB_PASSWORD/'$DB_PASSWORD'/g' /usr/share/nginx/cacti/include/config.php \
    && sed -i 's/$DB_PORT/'$DB_PORT'/g' /usr/share/nginx/cacti/include/config.php \
    && sed -i 's/$DB_SSL/'$DB_SSL'/g' /usr/share/nginx/cacti/include/config.php \
    && sed -i 's/$CACTI_VERSION/'$CACTI_VERSION'/g' /usr/share/nginx/cacti/include/global.php
}

update_spine_config() {
    if [ ! -e "/usr/local/spine/etc/spine.conf" ]; then
      set -x \
      && cp -f /docker/configurations/spine/spine.conf /usr/local/spine/etc/spine.conf \
      && sed -i 's/$DB_HOSTNAME/'$DB_HOSTNAME'/g' /usr/local/spine/etc/spine.conf  \
      && sed -i 's/$DB_NAME/'$DB_NAME'/g' /usr/local/spine/etc/spine.conf \
      && sed -i 's/$DB_USERNAME/'$DB_USERNAME'/g' /usr/local/spine/etc/spine.conf \
      && sed -i 's/$DB_PASSWORD/'$DB_PASSWORD'/g' /usr/local/spine/etc/spine.conf \
      && sed -i 's/$DB_PORT/'$DB_PORT'/g' /usr/local/spine/etc/spine.conf \
      && chmod -R nginx:nginx /usr/local/spine/
    fi
}

spine_db_update() {
    set -x \
    && mysql -h $DB_HOSTNAME -u$DB_USERNAME -p $DB_PASSWORD -e "REPLACE INTO cacti.settings SET name='path_spine', value='/usr/local/spine/bin/spine';" \
    && echo "spine configuration updated"
}

start_supervisord(){
  supervisord --configuration=/docker/configurations/supervisord/supervisor.conf
}

if [ "$1" = "cacti" ];then
  update_cacti_db_config \
  && update_spine_config \
  && start_supervisord
fi
