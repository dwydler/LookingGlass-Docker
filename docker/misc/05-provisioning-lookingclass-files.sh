#!/bin/bash

# Create folder for docker containers
mkdir -p /opt/containers/

# Clone repository to local folder
git clone https://codeberg.org/wd/LookingGlass-Docker.git /opt/containers/lookingglass/

# Display content of the folder
ls -lisa /opt/containers/lookingglass/
