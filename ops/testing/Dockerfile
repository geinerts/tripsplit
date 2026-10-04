FROM php:8.3-cli-bookworm@sha256:4687aec76c4a895b68b91bcd5e48f1ba7a3dea120f6de50bba7e1a93af5372dd

RUN apt-get update \
    && apt-get install -y --no-install-recommends libonig-dev libsqlite3-dev libxml2-dev \
    && docker-php-ext-install pdo_mysql pdo_sqlite mbstring dom xml xmlwriter \
    && rm -rf /var/lib/apt/lists/* \
    && touch /splyto-isolated-test-runtime

USER www-data
WORKDIR /workspace/api
