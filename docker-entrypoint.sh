#!/bin/sh

# Apache2
if [ ! -f "/etc/apache2/apache2.conf" ]; then
  cp /usr/apache2 /etc -r
fi

# Typecho last release version from 2017 - 1.1-17.10.30-release
if [ ! -f "/var/www/html/install.php" ]; then
  curl -o /usr/typecho.tar.gz -fL "http://typecho.org/downloads/1.1-17.10.30-release.tar.gz" \
  && tar -zxvf /usr/typecho.tar.gz -C /var/www/html \
  && cp -r /var/www/html/build/* /var/www/html \
  && rm /var/www/html/build -rf \
  && rm /usr/typecho.tar.gz
fi

# Start Apache2
/usr/sbin/apache2ctl -D FOREGROUND
