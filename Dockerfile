FROM nginx:1.11-alpine
MAINTAINER Vitalii Vokhmin <vitaliy.vokhmin@gmail.com>

# install libs
RUN apk add --no-cache supervisor php5-fpm php5-pgsql php5-mysql php5-mcrypt php5-pdo \
        php5-curl php5-gd php5-json php5-pdo_dblib php5-pdo_pgsql php5-pdo_mysql php5-dom \
        php5-pcntl php5-posix && \
    adduser -S www-data && \
    rm -rf /etc/nginx/conf.d/*

# copy config files
COPY ttrss.nginx.conf /etc/nginx/conf.d/ttrss.nginx.conf
COPY configure-db.php /configure-db.php
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# fetch ttrss, feedly theme, videoframes plugin
ADD https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.tar.gz /ttrss.tar.gz
ADD https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz /feedly.tar.gz
ADD https://github.com/tribut/ttrss-videoframes/archive/master.tar.gz /video.tar.gz

# install
RUN tar -zxC /var -f /ttrss.tar.gz && \
    tar -zxC /var -f /feedly.tar.gz && \
    tar -zxC /var -f /video.tar.gz && \
    mv /var/tt-rss.git /var/www && \
    mv /var/tt-rss-feedly-theme-master/* /var/www/themes/ && \
    mv /var/ttrss-videoframes-master/* /var/www/plugins/ && \
    rm /ttrss.tar.gz /feedly.tar.gz /video.tar.gz && \
    rmdir /var/tt-rss-feedly-theme-master /var/ttrss-videoframes-master && \
    cp /var/www/config.php-dist /var/www/config.php && \
    chown www-data -R /var/www && \
    sed -i "s/'SESSION_COOKIE_LIFETIME', 86400/'SESSION_COOKIE_LIFETIME', 2592000/" /var/www/config.php

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

WORKDIR /var/www

CMD php /configure-db.php && supervisord -c /etc/supervisor/conf.d/supervisord.conf
