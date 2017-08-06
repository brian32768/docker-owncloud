FROM debian:9.0

MAINTAINER Philipp Schmitt <philipp@schmitt.co>

# Dependencies
# TODO: Add NFS support
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get install -y cron bzip2 php-cli php-gd php-pgsql php-sqlite3 \
    php-mysqlnd php-curl php-intl php-mcrypt php-ldap php-gmp php-apcu \
    php-imagick php-fpm smbclient nginx supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV OWNCLOUD_STABLE stable9.1
ENV TIMEZONE UTC

# Fetch ownCloud dist files
ADD https://github.com/owncloud/core/archive/${OWNCLOUD_STABLE}.tar.gz /var/www
ADD https://github.com/owncloud/3rdparty/archive/${OWNCLOUD_STABLE}.tar.gz /var/www

# Config files and scripts
COPY nginx_nossl.conf /etc/nginx/nginx_nossl.conf
COPY nginx_ssl.conf /etc/nginx/nginx_ssl.conf
COPY php.ini /etc/php/fpm/php.ini
COPY php-cli.ini /etc/php/cli/php.ini
COPY cron.conf /etc/owncloud-cron.conf
COPY supervisor-owncloud.conf /etc/supervisor/conf.d/supervisor-owncloud.conf
COPY run.sh /usr/bin/run.sh
COPY occ.sh /usr/bin/occ

# Install ownCloud
RUN mv /var/www/core-${OWNCLOUD_STABLE} /var/www/owncloud && \
    rmdir /var/www/owncloud/3rdparty && \
    mv /var/www/3rdparty-${OWNCLOUD_STABLE} /var/www/owncloud/3rdparty && \
    chmod +x /usr/bin/run.sh && \
    su -s /bin/sh www-data -c "crontab /etc/owncloud-cron.conf"

EXPOSE 80 443

VOLUME ["/var/www/owncloud/config", "/var/www/owncloud/data", \
        "/var/www/owncloud/apps", "/var/log/nginx", \
        "/etc/ssl/certs/owncloud.crt", "/etc/ssl/private/owncloud.key"]

WORKDIR /var/www/owncloud
# USER www-data
CMD ["/usr/bin/run.sh"]

ADD php-fpm/www.conf /etc/php/fpm/pool.d/www.conf
