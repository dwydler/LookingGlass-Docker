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

# Array with the name of containers
aContainerNames=(wydler/lookingglass-web wydler/lookingglass-php wydler/lookingglass-iperf)

# 
for i in "${aContainerNames[@]}"; do
	echo "Container '$i' wird bearbeitet:";
	
	echo "Get the container ID of the named container.";
	CONTAINERID=$(docker ps | grep "wydler/lookingglass-web" | awk {'print $1'} )
	
	echo "Output docker commands:";
	echo "docker commit $CONTAINERID $i:$CONTAINERTAG";
	echo "docker push $i:$CONTAINERTAG";

	echo
done

