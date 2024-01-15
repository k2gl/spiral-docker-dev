#syntax=docker/dockerfile:1.4
# Adapted from https://github.com/k2gl/spiral-docker-dev
FROM spiralscout/roadrunner:latest AS spiralscout_roadrunner
FROM composer/composer:2-bin AS composer_upstream
FROM php:8.3.2RC1-cli-alpine AS php_upstream

# PHP upstream image
FROM php_upstream AS php_base

WORKDIR /srv
ENV PATH="${PATH}:/srv/bin"

RUN  --mount=type=bind,from=mlocati/php-extension-installer:latest,source=/usr/bin/install-php-extensions,target=/usr/local/bin/install-php-extensions \
      install-php-extensions opcache zip xsl dom exif intl pcntl bcmath sockets

COPY --link --from=spiralscout_roadrunner /usr/bin/rr /usr/bin/rr

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin:/srv/bin"
COPY --from=composer_upstream --link /composer /usr/bin/composer

EXPOSE 8080/tcp

# PHP Dev image
FROM php_base AS php_dev

RUN apk add --no-cache nano mc fish curl;

ENV SHELL /usr/bin/fish

# PHP Prod image
FROM php_base AS php_prod

COPY --link composer.* ./
RUN set -eux; \
	composer install --no-cache --prefer-dist --no-dev --no-autoloader --no-scripts --no-progress

COPY --link . ./
RUN rm -Rf docker/