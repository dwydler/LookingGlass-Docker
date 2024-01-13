# Reference image
FROM nginx:latest

# Metadata
LABEL org.opencontainers.image.authors="Daniel Wydler"

# Package lists reread and updated 
RUN apt update

# Install package(s)
RUN apt install -y sqlite3

# Deletes the already downloaded installation files from the package cache
RUN apt clean

# Remove the package lists
RUN rm -r /var/lib/apt/lists/*

#
COPY 99-lookingglass-config.sh /docker-entrypoint.d/

#
CMD ["nginx", "-g", "daemon off;"]

