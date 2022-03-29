FROM php:7.4.16-apache
LABEL maintainer="liuq@bilishare.com"
LABEL author="liuq"
LABEL description="Docker environment for fast installing typecho blog"

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
 	install-php-extensions pdo_mysql

COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN cp /etc/apache2 /usr -r && rm -rf /etc/apache2/*

ENTRYPOINT [ "/docker-entrypoint.sh" ]

VOLUME /var/www/html
VOLUME /etc/apache2
