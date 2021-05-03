FROM php:7.4.16-apache
LABEL maintainer="lqadm@qq.com" author="linkaliu" description="docker environment for typecho" version="0.0.1"

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
 	install-php-extensions pdo_mysql

VOLUME /var/www/html
VOLUME /etc/apache2
