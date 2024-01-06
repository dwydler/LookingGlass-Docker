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

* host
* host (IPv6)
* mtr
* mtr6 (IPv6)
* ping
* ping6 (IPv6)
* traceroute
* traceroute6 (IPv6)

__IPv6 commands will only work if your server has external IPv6 setup (or tunneled)__

## Requirements

* Docker & Docker Compose V2
* SSH/Terminal access (able to install commands/functions if non-existent)

## Install / Update

1. Clone the repository to the correct folder for docker containers
2. Navigate to the `data/webapp/LookingGlass` subdirectory in terminal
3. Run `bash configure.sh`
4. Follow the instructions and `configure.sh` will take care of the rest
	- Note: Re-enter test files to create random test files from `GNU shred`
5. If you want use IPv6, add parameters `"ip6tables": true` and `"experimental": true` to /etc/docker/daemon.json. Do not forget `systemctl restart docker.service`

_Forgot a setting? Simply run the `configure.sh` script again_


## License

Code is licensed under MIT Public License.

* If you wish to support my efforts, keep the "Powered by LookingGlass" link intact.
