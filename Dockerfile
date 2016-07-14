FROM nginx:1.11-alpine
MAINTAINER Vitalii Vokhmin <vitaliy.vokhmin@gmail.com>

RUN apk add --no-cache supervisor php-fpm php-pgsql php-mysql php-mcrypt php-pdo \
        php-curl php-gd php-json php-pdo_dblib php-pdo_pgsql php-pdo_mysql php-dom \
        php-pcntl php-posix

COPY ttrss.nginx.conf /etc/nginx/conf.d/ttrss
COPY configure-db.php /configure-db.php
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN adduser -S www-data

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

EXPOSE 80

ADD https://tt-rss.org/gitlab/fox/tt-rss/repository/archive.tar.gz /ttrss.tar.gz
RUN tar -zxC /var -f /ttrss.tar.gz && \
    mv /var/tt-rss.git /var/www && \
    rm /ttrss.tar.gz && \
    cp /var/www/config.php-dist /var/www/config.php && \
    chown www-data -R /var/www

WORKDIR /var/www

CMD php /configure-db.php && supervisord -c /etc/supervisor/conf.d/supervisord.conf
