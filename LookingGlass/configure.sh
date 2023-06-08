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

// HOST
\$host = '${HOST}';

// MTR
\$mtr = '${MTR}';

// PING
\$ping = '${PING}';

// TRACEROUTE
\$traceroute = '${TRACEROUTE}';

// SQLITE3
\$sqlite3 = '${SQLITE3}';

// Privacy Url
\$privacyurl = '${PrivacyUrl}';

// Imprint Url
\$imprinturl = '${ImprintUrl}';


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
                        elif [ $f1 = '$sqlite3' ]; then
                                SQLITE3=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        elif [ $f1 = '$privacyurl' ]; then
                                PrivacyUrl=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
                        elif [ $f1 = '$imprinturl' ]; then
                                ImprintUrl=("$(echo $f2 | awk -F\' '{print $(NF-1)}')")
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

        # 
        if [ ! -f "${DIR}/ratelimit.db" ]; then
                echo
                echo 'Creating SQLite database...'
                sqlite3 ratelimit.db  'CREATE TABLE RateLimit (ip TEXT UNIQUE NOT NULL, hits INTEGER NOT NULL DEFAULT 0, accessed INTEGER NOT NULL);'
                sqlite3 ratelimit.db 'CREATE UNIQUE INDEX "RateLimit_ip" ON "RateLimit" ("ip");'
                read -e -p 'Enter the username of your webserver (E.g. www-data): ' USER
                read -e -p 'Enter the user group of your webserver (E.g. www-data): ' GROUP
      
                # Change owner of folder & DB
                if [[ -n $USER ]]; then
                        if [[ -n $GROUP ]]; then
                                chown $USER:$GROUP "${DIR}"
                                chown $USER:$GROUP ratelimit.db
                        else
                                chown $USER:$USER "${DIR}"
                                chown $USER:$USER ratelimit.db
                        fi
                else
                cat <<EOF

##### IMPORTANT #####
Please set the owner of LookingGlass (subdirectory) and ratelimit.db
to that of your webserver:
chown user:group LookingGlass
chown user:group ratelimit.db
#####################
EOF
                fi
        fi
}

##
# Fix MTR on REHL based OS
##
function mtrFix() {
        # Check permissions for MTR & Symbolic link
        if [ $(stat --format="%a" /usr/sbin/mtr) -ne 4755 ] || [ ! -f "/usr/bin/mtr" ]; then
                if [ $(id -u) = "0" ]; then
                        echo 'Fixing MTR permissions...'
                        chmod 4755 /usr/sbin/mtr
                        ln -s /usr/sbin/mtr /usr/bin/mtr
                else
                        cat <<EOF

##### IMPORTANT #####
You are not root. Please log into root and run:
chmod 4755 /usr/sbin/mtr
ln -s /usr/sbin/mtr /usr/bin/mtr
#####################
EOF
                fi
        fi
}

##
# Check and install script requirements
##
function requirements() {
        sleep 1

        # Check for apt-get/yum
        if [ -f /usr/bin/apt ]; then
                # Check for root
                if [ $(id -u) != "0" ]; then
                        INSTALL='sudo apt'
                else
                        INSTALL='apt'
                fi
        elif [ -f /usr/bin/yum ]; then
                # Check for root
                if [ $(id -u) != "0" ]; then
                        INSTALL='sudo yum'
                else
                        INSTALL='yum'
                fi
        else
                INSTALL='none'

                cat <<EOF

##### IMPORTANT #####
Unknown Operating system. Install dependencies manually:
host mtr iputils-ping traceroute sqlite3
#####################
EOF
        fi

        # command ifconfig
        echo 'Checking for ifconfig...'
        if [ ! -f "/sbin/ifconfig" ] && [ ! -f "/bin/ifconfig" ] ; then
                echo "Please install: ${INSTALL} -y install net-tools."
                exit
        echo
        fi

        # command host
        echo 'Checking for host...'
        if [ ! -f "/usr/bin/host" ]; then
                if [ $INSTALL = 'none' ]; then
                        HOST='NULL'
                elif [ $INSTALL = 'yum' ]; then
                        echo "Please install: ${INSTALL} -y install bind-utils."
                        exit
                else
                        echo "Please install: ${INSTALL} -y install host."
                        exit
                fi
        echo
        fi

        # command mtr
        echo 'Checking for mtr...'
        if [ ! -f "/usr/bin/mtr" ] && [ ! -f "/usr/sbin/mtr" ] ; then
                if [ $INSTALL = 'none' ]; then
                        MTR='NULL'
                else
                        echo "Please install: ${INSTALL} -y install mtr."
                        exit
                fi
        echo
        fi

        # command ping
        echo 'Checking for ping...'
        if [ ! -f "/bin/ping" ]; then
                if [ $INSTALL = 'none' ]; then
                        PING='NULL'
                else
                        echo "Please install: ${INSTALL} -y install iputils-ping."
                        exit
                fi
        echo
        fi

        # command traceroute
        echo 'Checking for traceroute...'
        if [ ! -f "/usr/bin/traceroute" ] && [ ! -f "/usr/sbin/traceroute" ]; then
                if [ "$INSTALL" = "none" ]; then
                        TRACEROUTE='NULL'
                else
                        echo "Please install: ${INSTALL} -y install traceroute."
                        exit
                fi
        echo
        fi

        # command sqlite3
        echo 'Checking for sqlite3...'
        if [ ! -f "/usr/bin/sqlite3" ]; then
                if [ "$INSTALL" = "none" ]; then
                        SQLITE3='NULL'
                elif [ "$INSTALL" = "yum" ]; then
                        echo "Please install: ${INSTALL} -y install sqlite-devel."
                        exit
                else
                        echo "Please install: ${INSTALL} -y install sqlite3."
                        exit
                fi
        echo
        fi
}

##
# Setup parameters for PHP file creation
##
function setup() {
        sleep 1

        # Local vars
        local IP4=$(ifconfig | sed -n '2 p' | awk '{print $2}')
        local IP6=$(ifconfig | sed -n '3 p' | awk '{print $2}')
        local LOC=
        local S=
        local T=
        local U=

        # User input
        read -e -p "Enter your website name (Header/Logo) [${SITE}]: " S
        read -e -p "Enter the public URL to this LG (including http://) [${URL}]: " U
        read -e -p "Enter the public URLv4 to this LG (including http://) [${URLV4}]: " -i "$URLV4" UV4
        read -e -p "Enter the public URLv6 to this LG (including http://) [${URLV6}]: " -i "$URLV6" UV6
        read -e -p "Enter the public URL to an Privacy [${PrivacyUrl}]: " -i "$PrivacyUrl" PriUrl
        read -e -p "Enter the public URL to an Imprint [${ImprintUrl}]: " -i "$ImprintUrl" ImpUrl
        read -e -p "Enter the servers location [${LOCATION}]: " LOC
        read -e -p "Enter the test IPv4 address [${IPV4}]: " -i "$IP4" IP4
        read -e -p "Enter the test IPv6 address [${IPV6}]: " -i "$IP6" IP6
        read -e -p "Enter the size of test files in MB (Example: 100MB 1GB 10GB) [${TEST[*]}]: " T
        if [ -z $SQLITE3 ]; then
                read -e -p "Do you wish to enable rate limiting of network commands? (y/n): " -i "$RATELIMIT" RATE
        fi

        # Check local vars aren't empty; Set new values
        if [[ -n $IP4 ]]; then
                IPV4=$IP4
        fi

        # IPv6 can be left blank
        IPV6=$IP6
        if [[ -n $LOC ]]; then
                LOCATION=$LOC
        fi

        if [[ -n $S ]]; then
                SITE=$S
        fi

        if [[ -n $U ]]; then
                URL=$U
        fi

        if [[ -n $U ]]; then
                URLV4=$UV4
        fi

        if [[ -n $UV6 ]]; then
                URLV6=$UV6
        fi

         if [[ -n $PriUrl ]]; then
                PrivacyUrl=$PriUrl
        fi

         if [[ -n $ImpUrl ]]; then
                ImprintUrl=$ImpUrl
        fi

        # Rate limit
        if [[ "$RATE" = 'y' ]] || [[ "$RATE" = 'yes' ]]; then
                read -e -p "Enter the # of commands allowed per hour (per IP) [${RATELIMIT}]: " RATE
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
HOST=
MTR=
PING=
TRACEROUTE=
SQLITE3=
PrivacyUrl=
ImprintUrl=
TEST=()

# Install required scripts
echo 'Checking script requirements:'
requirements
echo

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

# Create DB
if [ -z $SQLITE3 ]; then
        database
fi

# Check for RHEL mtr
if [ "$INSTALL" = 'yum' ] && ["$MTR" = '']; then
  mtrFix
fi

# All done
cat <<EOF

Installation is complete

EOF
sleep 1
