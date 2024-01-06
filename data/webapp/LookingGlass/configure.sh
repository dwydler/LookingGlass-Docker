#!/bin/bash
################################
# LookingGlass - User friendly PHP Looking Glass
#
# package     LookingGlass
# author      Nick Adams <nick@iamtelephone.com>
# copyright   2015 Nick Adams.
# link        http://iamtelephone.com
# license     http://opensource.org/licenses/MIT MIT License
# version     1.4.0
################################

#######################
##                   ##
##     Functions     ##
##                   ##
#######################

##
# Create Config.php
##
function createConfig() {
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
 * @version     1.3.0
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
# Create/Load config varialbes
##
function config() {
        
        sleep 1
        
        # Check if previous config exists
        if [ ! -f $CONFIG ]; then
                # Create config file
                echo 'Creating Config.php...'
                echo ' ' > "$DIR/$CONFIG"
        else
                echo 'Loading Config.php...'
        fi

        sleep 1

        # Read Config line by line
        while IFS="=" read -r f1 f2 || [ -n "$f1" ]; do
                # Read variables
                if [ "$(echo $f1 | head -c 1)" = '$' ]; then
                        # Set Variables
                        if [ $f1 = '$ipv4' ]; then
                                IPV4="$(echo $f2 | awk -F\' '{print $(NF-1)}')"
                        elif [ $f1 = '$ipv6' ]; then
                                IPV6="$(echo $f2 | awk -F\' '{print $(NF-1)}')"
                        elif [ $f1 = '$rateLimit' ]; then
                                RATELIMIT=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        elif [ $f1 = '$serverLocation' ]; then
                                LOCATION="$(echo $f2 | awk -F\' '{print $(NF-1)}')"
                        elif [ $f1 = '$siteName' ]; then
                                SITE=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        elif [ $f1 = '$siteUrl' ]; then
                                URL=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        elif [ $f1 = '$siteUrlv4' ]; then
                                URLV4=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        elif [ $f1 = '$siteUrlv6' ]; then
                                URLV6=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
#                        elif [ $f1 = '$sqlite3' ]; then
#                                SQLITE3=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        elif [ $f1 = '$privacyurl' ]; then
                                PRIVACYURL=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        elif [ $f1 = '$imprinturl' ]; then
                                IMPRINTURL=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        elif [ $f1 = '$iperfport' ]; then
                                IPERFPORT=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        elif [ $f1 = '$testFiles[]' ]; then
                                TEST+=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        fi
                fi
        
        done < "$DIR/$CONFIG"
}

##
# Create SQLite database
##
function database() {

	echo

	# Create a copy of the default database
	echo "Create a copy of the default database"
	cp ratelimit.empty.db ratelimit.db

	# Set permissions for folder and database file
	echo "Set permission for current folder and ratelimit.db"
	chown www-data:www-data "${DIR}"
	chown www-data:www-data  ratelimit.db
}


##
# Setup parameters for PHP file creation
##
function setup() {
        sleep 1

        # Local vars
        local IP4=
        local IP6=
        local LOC=
        local S=
        local T=
        local U=

	if [[ -z $IPV4 ]]; then
		IPV4=$(curl -s -4 ifconfig.me/ip) 
	fi

	if [[ -z $IPV6 ]]; then
                IPV6=$(curl -s -6 ifconfig.me/ip)
        fi


        # User input
        read -e -p "Enter your website name (Header/Logo) [${SITE}]: " -i "$SITE" S
        read -e -p "Enter the public URL to this LG (without http://) [${URL}]: " -i "$URL" U
        read -e -p "Enter the public URLv4 to this LG (without http://) [${URLV4}]: " -i "$URLV4" UV4
        read -e -p "Enter the public URLv6 to this LG (without http://) [${URLV6}]: " -i "$URLV6" UV6
        read -e -p "Enter the public URL to an Privacy [${PRIVACYURL}]: " -i "$PRIVACYURL" PRIURL
        read -e -p "Enter the public URL to an Imprint [${IMPRINTURL}]: " -i "$IMPRINTURL" IMPURL
        read -e -p "Enter the servers location [${LOCATION}]: " -i "$LOCATION" LOC
        read -e -p "Enter the test IPv4 address [${IPV4}]: " -i "$IPV4" IP4
        read -e -p "Enter the test IPv6 address [${IPV6}]: " -i "$IPV6" IP6
        read -e -p "Enter the Port for the Ipref Server [${IPERFPORT}]: " -i "$IPERFPORT" IPP
        read -e -p "Enter the size of test files in MB (Example: 100MB 1GB 10GB) [${TEST[*]}]: " T
        
	YESNO="y"
	
	if [[ ! -z $RATELIMIT ]] && [[ "$RATELIMIT" -eq "0" ]]; then
		YESNO="n"
	fi
	
        read -e -p "Do you wish to enable rate limiting of network commands? (y/n): " -i "$YESNO" RATE

        # Check local vars aren't empty; Set new values  
        if [[ -n $LOC ]]; then
                LOCATION=$LOC
        fi

        if [[ -n $S ]]; then
                SITE=$S
        fi

        if [[ -n $U ]]; then
                URL=$U
        fi

        # Assign entered value to script variable, can be left blank
        IPV4=$IP4
        IPV6=$IP6
        URLV4=$UV4
        URLV6=$UV6
        PRIVACYURL=$PRIURL
        IMPRINTURL=$IMPURL
        IPERFPORT=$IPP

        # Rate limit
        if [[ "$RATE" = 'y' ]] || [[ "$RATE" = 'yes' ]]; then
                read -e -p "Enter the # of commands allowed per hour (per IP) [${RATELIMIT}]: " -i "$RATELIMIT" RATE
                if [[ -n $RATE ]]; then
                        if [ "$RATE" != "$RATELIMIT" ]; then
                                RATELIMIT=$RATE
                        fi
                fi
        else
                RATELIMIT=0
        fi

         # Create test files
        if [[ -n $T ]]; then
                echo
                echo 'Removing old test files:'
    
                # Delete old test files
                local REMOVE=($(ls ../*.bin 2>/dev/null))
    
                for i in "${REMOVE[@]}"; do
                        if [ -f "${i}" ]; then
                                echo "Removing ${i}"
                                rm "${i}"
                                sleep 1
                        fi
                done
    
                TEST=($T)

                # Create new test files
                echo
                echo 'Creating new test files:'          
                testFiles
        fi
}

##
# Create test files
##
function testFiles() {
        sleep 1

        # Local var/s
        local A=0

        # Check for and/or create test file
        for i in "${TEST[@]}"; do
                if [[ -n i ]] && [ ! -f "../${i}.bin" ]; then
                        echo "Creating $i test file"
                        shred --exact --iterations=1 --size="${i}" - > "../${i}.bin"
                        A=$((A+1))
                        sleep 1
                fi
        done

        # No test files were created
        if [ $A = 0 ]; then
                echo 'Test files already exist...'
        fi
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

read -e -p "Do you wish to install LookingGlass? (y/n): " ANSWER

if [[ "$ANSWER" = 'y' ]] || [[ "$ANSWER" = 'yes' ]]; then
        cat <<EOF

###              ###
# Starting install #
###              ###

EOF
        sleep 1
else
        echo 'Installation terminated.'
        echo
        exit
fi

# Global vars
CONFIG='Config.php'
DIR="$(cd "$(dirname "$0")" && pwd)"
IPV4=
IPV6=
LOCATION=
RATELIMIT=
SITE=
URL=
URLV4=
URLV6=
PRIVACYURL=
IMPRINTURL=
IPERFPORT=
TEST=()


# Read Config file
echo 'Checking for previous config:'
config
echo

# Create test files
echo 'Creating test files:'
testFiles
echo

# Follow setup
cat <<EOF

###                    ###
# Starting configuration #
###                    ###

EOF
echo 'Running setup:'
setup
echo

# Create Config.php file
echo 'Creating Config.php...'
createConfig
database

# All done
cat <<EOF

Installation is complete

EOF
sleep 1
