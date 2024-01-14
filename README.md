# LookingGlass

## Overview

LookingGlass is a user-friendly PHP based looking glass that allows the public (via a web interface) to execute network
commands on behalf of your server.

It's recommended that everyone updates their existing install!

## Demo
[Looking Glass](https://lg.daniel.wydler.eu/)

Demo is running on a Cloud Server of Hetzner Online GmbH. 

## Features

* Automated install via bash script
* IPv4 & IPv6 support (DualStack, Only IPv4 or IPv6)
* Separate Domains for IPv4/IPv6
* Live output via long polling
* Multi Language System. New Languages are Welcome!
* Rate limiting of network commands
* Darkmode

## Implemented commands

* host, host6
* mtr, mtr6
* ping, ping6
* traceroute, traceroute6

__IPv6 commands will only work if your server has external IPv6 setup (or tunneled)__

## Requirements

* Docker & Docker Compose V2
* SSH/Terminal access (able to install commands/functions if non-existent)

## Install / Update

1. Clone the repository to the correct folder for docker containers.
2. Navigate to into the application folder (e.g. /opt/containers/lookingglass)
3. Editing lg.default.env and set your parameters and data. Any change requires an restart of the containers.
4. For IPv6 support, edit the Docker daemon configuration file, located at /etc/docker/daemon.json. Configure the following parameters and run `systemctl restart docker.service` to restart docker:
  ```
  {
    "experimental": true,
    "ip6tables": true
  }
  ```
5. Starting application with ` docker compose -f docker-compose.yml up -d`


## License

Code is licensed under MIT Public License.

* If you wish to support my efforts, keep the "Powered by LookingGlass" link intact.
