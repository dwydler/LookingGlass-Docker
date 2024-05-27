#!/bin/bash
################################
# LookingGlass - User friendly PHP Looking Glass
#
# package     LookingGlass
# author      Nick Adams <nick@iamtelephone.com>
# copyright   2015 Nick Adams.
# link        http://iamtelephone.com
# license     http://opensource.org/licenses/MIT MIT License
################################

#######################
##                   ##
##     Functions     ##
##                   ##
#######################

##
# Create Config.php
##
function createConfig()
{
  cat > "$DIR/$CONFIG" <<EOF
<?php
/**
 * LookingGlass - User friendly PHP Looking Glass
 *
 * @package     LookingGlass
 * @author      Nick Adams <nick@iamtelephone.com>
 * @copyright   2015 Nick Adams.
 * @link        http://iamtelephone.com
 * @license     http://opensource.org/licenses/MIT MIT License
 */

// IPv4 address
\$ipv4 = '${IPV4}';

// IPv6 address (can be blank)
\$ipv6 = '${IPV6}';

// Rate limit
\$rateLimit = (int) '${RATELIMIT}';

// Site name (header)
\$siteName = '${SITE}';

// Site URL
\$siteUrl = '${URL}';

// Site URLv4
\$siteUrlv4 = '${URLV4}';

// Site URLv6
\$siteUrlv6 = '${URLV6}';

// Server location
\$serverLocation = '${LOCATION}';

// HOST
\$host = '';

// MTR
\$mtr = '';

// PING
\$ping = '';

// TRACEROUTE
\$traceroute = '';

// IPERF3
\$iperf3 = '';

// SQLITE3
\$sqlite3 = '';

// Privacy Url
\$privacyurl = '${PRIVACYURL}';

// Imprint Url
\$imprinturl = '${IMPRINTURL}';

// Iperf Port
\$iperfport = '${IPERFPORT}';

// Test files
\$testFiles = array();
EOF

        for i in "${TEST[@]}"; do
                echo "\$testFiles[] = '${i}';" >> "$DIR/$CONFIG"
        done

        sleep 1
}


##
# Create SQLite database
##
function database() {

	# Create a copy of the default database
	echo "Chekf if an database already exist."

	if [ ! -f ratelimit.db ]; then

		echo 'Creating SQLite database...'
		sqlite3 ratelimit.db  'CREATE TABLE RateLimit (ip TEXT UNIQUE NOT NULL, hits INTEGER NOT NULL DEFAULT 0, accessed INTEGER NOT NULL);'
		sqlite3 ratelimit.db 'CREATE UNIQUE INDEX "RateLimit_ip" ON "RateLimit" ("ip");'		
		echo "New database copied successfully."
	else
		echo "Database already exists. Skip."
	fi
	echo

	# Set permissions for folder and database file
	echo "Set permission for folder '$DIR'."
	chown www-data:www-data "${DIR}"

	echo "Set permission for 'ratelimit.db'."
	chown www-data:www-data ratelimit.db
}


##
# Create test files
##
function testFiles() {
	sleep 1

	# Local var/s
	local A=0

	local REMOVE=($(ls ../*.bin 2>/dev/null))

	echo "Delete files which are no longer needed..."
	for existingfile in "${REMOVE[@]}"; do

		# Remove ../ and file type extension.
		FILE=$(basename $existingfile .bin)
		echo "Checking file '$FILE'."

		# If file name not in array, do nothing
		# Else Delete the file
		if [[ ${TEST[@]} =~ $FILE ]]; then
			echo "File found. Nothing to do."
		else
			echo "Removing ${existingfile}."
			rm "${existingfile}"
		fi
	done
	echo

	echo "Create all files which are new..."
	for newfile in "${TEST[@]}"; do

		# Remove ../ and file type extension.
		FILE=$(basename $newfile .bin)
		echo "Checking file '$FILE'."

		if [[ ${REMOVE[@]} =~ $FILE ]]; then
			echo "File found. Nothing to do."
		else
			echo "Creating '$newfile' test file."
			shred --exact --iterations=1 --size="${newfile}" - > "../${newfile}.bin"
			sleep 1
		fi
	done
}

###########################
##                       ##
##     Configuration     ##
##                       ##
###########################

# Clear terminal
clear

# Welcome message
cat <<EOF

########################################
#
# LookingGlass is a user-friendly script
# to create a functional Looking Glass
# for your network.
#
# Created by Nick Adams (telephone)
# http://iamtelephone.com
#
########################################

EOF

# Global vars
CONFIG='Config.php'
DIR="/var/www/html/LookingGlass/"

echo "Checking if folder '$DIR' exist..."
while [[ ! -d "$DIR/" ]]; do
	# Wait 2 seconds
	echo "Wating 2 seconds (again)."
	sleep 2
done
echo "Found the mentioned directory."
cd "$DIR"
echo

IPV4=${lg_ip4_address}
IPV6=${lg_ip6_address}
LOCATION=${lg_location}
RATELIMIT=${lg_ratelimit}
SITE=${lg_sitename}
URL=${lg_url}
URLV4=${lg_url_ipv4}
URLV6=${lg_url_ipv6}
PRIVACYURL=${lg_url_privacy}
IMPRINTURL=${lg_url_imprint}
IPERFPORT=${lg_iperf_port}
TEST=(${lg_testfiles})


# Follow setup
cat <<EOF

###                    ###
# Starting configuration #
###                    ###

EOF

# Create Config.php file
echo "Creating Config.php..."
createConfig
echo

echo "Creating database..."
database
echo

echo "Deleting and creating test files..."
testFiles
echo


# All done
cat <<EOF

Installation is complete.

EOF
sleep 1
