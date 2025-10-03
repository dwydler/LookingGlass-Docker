# Reference image
FROM nginx:1.29.1

# Metadata
LABEL org.opencontainers.image.authors="Daniel Wydler"

# Package lists reread and updated 
# Install package(s)
# Remove the package lists
RUN apt-get update && \
    apt-get install -y \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

#
COPY --chmod=755 /docker/nginx/99-lookingglass-config.sh /docker-entrypoint.d/

#
CMD ["nginx", "-g", "daemon off;"]
