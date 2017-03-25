FROM nginx:1.10.1-alpine
LABEL mantainer="Giuseppe Iannelli"

########### ENVS ###########
ENV CACTI_VERSION=1.1.0 \
SNMP_PORT=161 \
SNMP_PORT_PROTO=udp \
DB_TYPE=mysql \
DB_PORT=3306 \
DB_SSL=false

########### INSTALL PHP, MYSQL, SNMP, SUPERVISORD ###########
RUN apk add --no-cache --virtual .static_deps \
python supervisor openssl \
php5 php5-fpm php5-dom php5-gd php5-gmp php5-json php5-ldap php5-mysql php5-mysqli php5-odbc php5-openssl \
php5-pdo php5-pdo_mysql php5-pdo_odbc php5-pear php5-posix php5-snmp php5-sockets php5-xml php5-zlib \
net-snmp net-snmp-dev net-snmp-tools net-snmp-libs net-snmp-agent-libs \
mariadb-client mysql-client mariadb-client-libs mariadb-dev \
rrdtool rrdtool-cached rrdtool-cgi rrdtool-utils wget patch help2man

########### INSTALL SPINE DEPS ###########
RUN apk add --no-cache --virtual .spine-build-deps \
    autoconf \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    openssl-dev


########### DOWNLOAD CACTI ###########
RUN set -x \
&& mkdir -p /usr/share/nginx/cacti \
&& cd /usr/share/nginx/ \
&& wget http://www.cacti.net/downloads/cacti-"$CACTI_VERSION".tar.gz \
&& tar xzvf cacti-"$CACTI_VERSION".tar.gz  -C /usr/share/nginx/ \
&& mv cacti-"$CACTI_VERSION"/* cacti/ \
&& rm -rf cacti-"$CACTI_VERSION".tar.gz html cacti-"$CACTI_VERSION"

########### DOWNLOAD SPINE ###########
RUN set -x \
&& cd /usr/share/nginx/ \
&& wget http://www.cacti.net/downloads/spine/cacti-spine-"$CACTI_VERSION".tar.gz \
&& tar xvzf cacti-spine-"$CACTI_VERSION".tar.gz \
&& cd cacti-spine-"$CACTI_VERSION" \
&& ./configure \
&& make \
&& make install \
&& cd /usr/share/nginx/ \
&& rm -rf cacti-spine-"$CACTI_VERSION" cacti-spine-"$CACTI_VERSION".tar.gz

########### REMOVE SPINE DEPS ###########
RUN apk del .spine-build-deps

########### SETUP NGINX, PHP-FPM ###########
COPY docker/ /docker/
RUN set -x \
&& cp /docker/configurations/nginx/default.conf /etc/nginx/conf.d/default.conf \
&& cp /docker/configurations/nginx/mime.types /etc/nginx/mime.types \
&& cp /docker/configurations/php-fpm/php-fpm.conf /etc/php5/php-fpm.conf


########### CREATE RRA VOLUME #####

VOLUME ["/usr/share/nginx/cacti/rra/"]

########### SETUP CACTI ###########
RUN set -x \
&& mkdir -p /usr/share/nginx/cacti/rra/backup/ /usr/share/nginx/cacti/rra/archive/ /usr/share/nginx/cacti/cache \
&& chown -R nginx:nginx /usr/share/nginx/cacti \
&& cp /docker/configurations/cacti/config.php /usr/share/nginx/cacti/include/config.php \
&& cp /docker/configurations/cacti/global.php /usr/share/nginx/cacti/include/global.php \
&& echo  "*/5 * * * * php /usr/share/nginx/cacti/poller.php > /dev/null 2>&1" > /var/spool/cron/crontabs/nginx \
&& sh /docker/scripts/install_cacti_extras.sh

########### EXPOSE SNMP PORT ###########
EXPOSE $SNMP_PORT/$SNMP_PORT_PROTO

########### SET WORKDIR ###########
WORKDIR /usr/share/nginx/cacti

########### START SUPERVISORD ###########
RUN set -x \
&& mkdir -p /var/log/supervisord \
&& touch /var/log/supervisord/supervisord.log \
&& chmod +x /docker/entrypoint.sh

ENTRYPOINT ["/docker/entrypoint.sh"]
CMD ["cacti"]
