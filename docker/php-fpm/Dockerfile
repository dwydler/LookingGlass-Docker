############################
# Stage 1: Runtime
############################
FROM php:8.4.25-fpm@sha256:e6a73bef77ac123720bbb5e7b0608e45bde41d1cbac108d5e18b4d4a9d751304

############################
# Metadata
############################
LABEL maintainer="Daniel Wydler" \
      org.opencontainers.image.authors="Daniel Wydler" \
      org.opencontainers.image.description="A user-friendly PHP Looking Glass - Reloaded" \
      org.opencontainers.image.documentation="https://github.com/wydler/LookingGlass-Docker/blob/master/README.md" \
      org.opencontainers.image.source="https://github.com/wydler/LookingGlass-Docker" \
      org.opencontainers.image.title="lookingglass-php" \
      org.opencontainers.image.url="https://hub.docker.com/r/wydler/lookingglass-php"

############################
# System dependencies
############################
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        net-tools \
        host \
        mtr \
        iputils-ping \
        traceroute \
        locales \
    && rm -rf /var/lib/apt/lists/*

############################
# PHP extensions
############################
RUN docker-php-ext-install -j"$(nproc)" gettext

############################
# Locale configuration
############################
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

RUN locale-gen de_DE.UTF-8 en_US.UTF-8