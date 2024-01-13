#!/bin/bash

echo "Check if credentials for docker hub existing."
if [[ -z $HOME/.docker/config.json ]]; then

	read -e -p "Enter your docker hub account: " USERNAME
	docker login -u $USERNAME
else
	docker login
fi

# Enter the tag for the container
read -e -p "Enter the tag for the container: " CONTAINERTAG

#
docker buildx create --name lookingglass

#
docker buildx use lookingglass


#
cd /opt/containers/lookingglass/docker/nginx
docker buildx build \
       	--platform linux/arm64,linux/amd64 \
       	-t wydler/lookingglass-web:$CONTAINERTAG \
       	. \
	--push

cd /opt/containers/lookingglass/docker/php-fpm
docker buildx build \
       	--platform linux/arm64,linux/amd64 \
       	-t wydler/lookingglass-php:$CONTAINERTAG \
       	. \
       	--push

cd /opt/containers/lookingglass/docker/ipref3
docker buildx build \
       	--platform linux/arm64,linux/amd64 \
       	-t wydler/lookingglass-iperf:$CONTAINERTAG \
       	. \
       	--push


