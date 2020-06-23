FROM alpine:3.10
LABEL Maintainer="mintzhao <mint.zhao.chiu@gmail.com>" \
      Description="Lightweight container with Nginx 1.16 & PHP-FPM 7.3 based on Alpine Linux."

# Switch to use a non-root user from here on
#USER nobody
USER root

# Install packages
RUN apk --no-cache add bash php7 php7-fpm php7-mysqli php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php-xml php-simplexml php7-phar php7-intl php7-dom php7-xmlreader php7-xmlwriter php7-ctype php7-session \
    php7-mbstring php7-gd nginx supervisor curl php-pdo php-pdo_mysql php-common php-zip php7-tokenizer \
    php7-pear php-fileinfo mariadb-client

RUN apk --no-cache add php7-gmp

# Configure nginx
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY docker/php/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY docker/php/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
#RUN chown -R nobody.nobody /run && \
#  chown -R nobody.nobody /var/lib/nginx && \
#  chown -R nobody.nobody /var/tmp/nginx && \
#  chown -R nobody.nobody /var/log/nginx

# Setup document root
RUN mkdir -p /var/www/html

# Make the document root a volume
VOLUME /var/www/html

# Add application
WORKDIR /var/www/public
COPY . /var/www


# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
