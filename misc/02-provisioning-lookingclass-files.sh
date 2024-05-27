#!/bin/bash

# Create folder for docker containers
mkdir -p /opt/containers/

# Clone repository to local folder
git clone https://github.com/dwydler/LookingGlass-Docker.git /opt/containers/lookingglass

# Switch to the latest release
git -C /opt/containers/lookingglass checkout $(git -C /opt/containers/lookingglass tag | tail -1)

# Download dependencies
git -C /opt/containers/lookingglass submodule update --init --recursive
git -C /opt/containers/lookingglass/data/webapp checkout $(git -C /opt/containers/lookingglass/data/webapp tag | tail -1)


# Display content of the folder
ls -lisa /opt/containers/lookingglass/
