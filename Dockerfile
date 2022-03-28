FROM php:7.4.16-apache
LABEL maintainer="liuq@bilishare.com" author="liuq" description="Docker environment for fast installing typecho blog" version="0.0.2"

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
 	install-php-extensions pdo_mysql

VOLUME /var/www/html
VOLUME /etc/apache2
