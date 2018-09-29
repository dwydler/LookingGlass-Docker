# LookingGlass

## Overview

LookingGlass is a user-friendly PHP based looking glass that allows the public (via a web interface) to execute network
commands on behalf of your server.

Current version: v1.4.0

It's recommended that everyone updates their existing install!

## Demo
[Looking Glass](http://www.wydler.eu/LookingGlass/)
Demo is running on Webspace of domainFACTORY. 

## Features

* Automated install via bash script
* IPv4 & IPv6 support (DualStack, Only IPv4 or IPv6)
* Separate Domains for IPv4/IPv6
* Live output via long polling
* Multi Language System. New Languages are Welcome!
* Rate limiting of network commands

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

* PHP >= 5.6
* PHP PDO with SQLite driver (required for rate-limit)
* SSH/Terminal access (able to install commands/functions if non-existent)

## Install / Update

1. Download [LookingGlass](https://github.com/StadtBadWurzach/LookingGlass/archive/v1.4.0.zip) to the intended
folder within your web directory
2. Move archive to the correct directory
3. Extract archive with unzip LookingGlass-1.4.0.zip
4. Navigate to the `LookingGlass` subdirectory in terminal
5. Run `bash configure.sh`
6. Follow the instructions and `configure.sh` will take care of the rest
	- Note: Re-enter test files to create random test files from `GNU shred`

_Forgot a setting? Simply run the `configure.sh` script again_

## Apache

An .htaccess is included which protects the rate-limit database, disables indexes, and disables gzip on test files.
Ensure `AllowOverride` is on for .htaccess to take effect.

Output buffering __should__ work by default.

For an HTTPS setup, please visit:
- [Mozilla SSL Configuration Generator](https://mozilla.github.io/server-side-tls/ssl-config-generator/)

## Nginx

To enable output buffering, and disable gzip on test files please refer to the provided configuration:

[HTTP setup](LookingGlass/lookingglass-http.nginx.conf)

The provided config is setup for LookingGlass to be on a subdomain/domain root.

For an HTTPS setup please visit:
- [Mozilla SSL Configuration Generator](https://mozilla.github.io/server-side-tls/ssl-config-generator/)

## License

Code is licensed under MIT Public License.

* If you wish to support my efforts, keep the "Powered by LookingGlass" link intact.
