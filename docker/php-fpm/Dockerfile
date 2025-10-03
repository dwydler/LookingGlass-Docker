# Reference image
FROM php:8.4.13-fpm

# Metadata
LABEL org.opencontainers.image.authors="Daniel Wydler"

# Package lists reread and updated
# Install package(s)
# Remove the package lists
RUN apt-get update && \
    apt-get install -y \
    net-tools \
    host \
    mtr \
    iputils-ping \
    traceroute \
    locales \
    && rm -r /var/lib/apt/lists/*
    
# Install a PHP extension inside the official PHP Docker images
RUN docker-php-ext-install gettext

# Configure Locale for language detection in the webapp
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales
