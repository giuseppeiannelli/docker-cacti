#!/bin/sh

install_plugins(){
  cd /usr/share/nginx/cacti/plugins
  plugins_list="plugin:settings-v0.71-1.tgz plugin:thold-v0.5.0.tgz plugin:realtime-v0.5-2.tgz plugin:monitor-v1.2-1.tgz plugin:hmib-v1.4-2.tgz plugin:rrdclean-v0.41.tgz plugin:errorimage-v0.2-1.tgz plugin:ugroup-v0.2-2.tgz plugin:aggregate-v0.75.tgz"
  not_avaible_plugins_list="plugin:syslog-v1.22-2.tgz"
  for plugin in $plugins_list; do
    wget http://docs.cacti.net/_media/$plugin \
    && tar xvzf $plugin \
    && rm -rf $plugin
  done
}

install_rrdtool_font(){
apk --update add font-adobe-100dpi \
font-adobe-75dpi \
font-adobe-utopia-100dpi \
font-adobe-utopia-75dpi \
font-adobe-utopia-type1 \
font-bh-100dpi \
font-bh-75dpi \
font-bh-lucidatypewriter-100dpi \
font-bh-lucidatypewriter-75dpi \
font-bh-ttf \
font-bh-type1 \
font-bitstream-100dpi \
font-bitstream-75dpi \
font-bitstream-type1 \
font-ibm-type1 \
font-misc-meltho \
font-misc-misc \
font-mutt-misc \
font-schumacher-misc \
font-sony-misc
}
install_plugins
install_rrdtool_font
