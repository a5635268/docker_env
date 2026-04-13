# WARNING: PHP 7.4 已于 2022年11月28日停止维护 (EOL)
# 不再接收任何安全补丁。仅用于无法升级的遗留项目。
# 新项目请使用 PHP 8.2+ 版本。
FROM php:7.4-fpm-alpine

LABEL maintainer="xiaogang.zhou@qq.com"

RUN apk add --no-cache \
    libpng-dev libjpeg-turbo-dev freetype-dev \
    libzip-dev icu-dev curl-dev \
    oniguruma-dev \
    gettext-dev \
    autoconf g++ make linux-headers libtool \
    vim tzdata

RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN docker-php-ext-install -j$(nproc) \
    pdo_mysql mysqli gd mbstring curl zip intl \
    opcache bcmath calendar exif gettext sockets \
    sysvmsg sysvsem sysvshm

RUN pecl install \
    redis-5.3.7 \
    seaslog-2.2.0 \
    && docker-php-ext-enable redis seaslog

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN cat > /usr/local/etc/php/conf.d/seaslog.ini <<'EOF'
[seaslog]
seaslog.default_basepath = /var/www/logs
seaslog.default_template = "%T | %L | %D | %R | %m | %F | %C | %I | %P | %Q | %M"
seaslog.default_logger = default
seaslog.disting_type = 1
seaslog.recall_depth = 2
seaslog.use_buffer = 0
EOF

RUN mkdir -p /var/www/logs && chown -R www-data:www-data /var/www/logs

WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["php-fpm"]

