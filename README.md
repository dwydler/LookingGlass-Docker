# LookingGlass

## Overview
LookingGlass is a user-friendly PHP based looking glass that allows the public (via a web interface) to execute network commands on behalf of your server.

This is a port of the native [Looking Glass application](https://github.com/dwydler/LookingGlass/tree/customize) into docker images.


## Demo
[Looking Glass](http://lg.n01.cl01.daniel.wydler.eu/)

Demo is running on a Cloud Server of Hetzner Online GmbH. 


## Features
You can find an overview [here](https://github.com/dwydler/LookingGlass/tree/customize). 


## Implemented commands
You can find an overview [here](https://github.com/dwydler/LookingGlass/tree/customize). 


## Requirements
* Docker & Docker Compose V2
* SSH/Terminal access (able to install commands/functions if non-existent)


## Install Docker, download containers und configure Looking Glass
1. This script will install docker and containerd:
  ```
    curl https://raw.githubusercontent.com/dwydler/LookingGlass-Docker/master/misc/01-docker.io-installation.sh | bash
  ```
2. For IPv6 support, edit the Docker daemon configuration file, located at /etc/docker/daemon.json. Configure the following parameters and run `systemctl restart docker.service` to restart docker:
  ```
  {
    "experimental": true,
    "ip6tables": true
  }
  ```
3. Clone the repository to the correct folder for docker container:
  ```
   git clone https://github.com/dwydler/LookingGlass-Docker.git /opt/containers/lookingglass
   git -C /opt/containers/lookingglass checkout $(git -C /opt/containers/lookingglass tag | tail -1)
  ```
4. Download dependencies:
  ```
   git -C /opt/containers/lookingglass submodule update --init --recursive
   git -C /opt/containers/lookingglass/data/webapp checkout $(git -C /opt/containers/lookingglass/data/webapp tag | tail -1)
  ```
5. Make a copy of the file "lg.default.env" named ".env"
  ```
  cp /opt/containers/lookingglass/lg.default.env /opt/containers/lookingglass/.env
  ```
6. Editing lg.env and set your parameters and data. Any change requires an restart of the containers.
7. Starting application with `docker compose -f /opt/containers/lookingglass/docker-compose.yml up -d`.
8. Don't forget to test, that the application works successfully (e.g. http(s)://IP-Addresse or FQDN/).


## Update Looking Glass
1. When you're ready to update the code, you can checkout the latest tag:
  ```
   ( cd /opt/containers/lookingglass && git fetch && git checkout $(git tag | tail -1) )
   ( cd /opt/containers/lookingglass/data/webapp && git fetch && git checkout $(git tag | tail -1) )
  ```
2. No restart needed. The changes will take effect immediately.


## License
Code is licensed under MIT Public License.  
If you wish to support my efforts, keep the "Powered by LookingGlass" link intact.
