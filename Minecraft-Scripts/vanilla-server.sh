#!/bin/bash

# Color variables
INFO='\033[1;32m'
ERROR='\033[1;31m'
RESET='\033[0m'

# Checks if you have the required programs installed for the script to work
command -v wget >/dev/null 2>&1 || { echo -e >&2 "$ERROR[ERROR]$RESET You most have wget installed on your system for this script to work.  How to install: https://phoenixnap.com/kb/wget-command-with-examples"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo -e >&2 "$ERROR[ERROR]$RESET You most have jq installed on your system for this script to work. How to install: https://stedolan.github.io/jq/download/"; exit 1; }

# Asks for the name of the directory you want
echo -e "Please enter the name of the server directory"; read server_directory

# Checks to see if the provided directory exists
if [ -d "$server_directory" ]; then
    echo -e "$ERROR[ERROR]$RESET The provided directory already exists."
    echo -e "$ERROR[ERROR]$RESET Please provide another directory name or delete the provided directory."
    exit 1
fi

# Asks for the Minecraft version you want to use
echo -e "Please enter the version of Minecraft you want to use"; read version
# Checks for the hash of the Minecraft version provided
version_hash=`curl -sS -X GET "https://gist.githubusercontent.com/AppleMacOS/b16b018937e7982e0d7fc650d659fdaf/raw/b1bfac79f9e5db321d8fd4a450b4e49c73fa703b/vanilla-versions.json" -H  "accept: application/json" | jq --arg v "$version" '.[$v]'`
# Checks to see if the provided version exists
if [ $version_hash == null ]; then
    echo -e "$ERROR[ERROR]$RESET The Minecraft version you provided is invalid."
    exit 1
fi
# Removes the double qoutes from hash
version_hash_1=`echo "$version_hash" | tr -d '"'`
# Downloads the jar file
echo -e "$INFO[INFO]$RESET Downloading jar file..."; wget https://launcher.mojang.com/v1/objects/$version_hash_1/server.jar &> /dev/null; echo -e "$INFO[INFO]$RESET Finished downloading."
# Makes server directory
echo -e "$INFO[INFO]$RESET Making server directory."; mkdir $server_directory
# Moves server jar to server directory
echo -e "$INFO[INFO]$RESET Moving the Server jar to the server directory."; mv server.jar ./$server_directory/

# Yes or no function
function yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

# Asks the user if they agree to the Minecraft EULA
if [[ "no" == $(yes_or_no "Do you agree to the Minecraft EULA?") ]]; then
    echo -e "$INFO[INFO]$RESET You'll have to manually set the EULA to true"
    exit 0
fi

# Move the to the server directory
cd $server_directory
# Makes the eula.txt file and sets it to true
touch eula.txt; printf "eula=true" >> eula.txt

# Asks if you want to start the server right now
if [[ "no" == $(yes_or_no "Do you want to start the server now? Must have screen installed!") ]]; then
    echo -e "$INFO[INFO]$RESET Script has finished!"
    exit 0
fi

# Checks if screen and java is installed 
command -v java >/dev/null 2>&1 || { echo -e >&2 "$ERROR[ERROR]$RESET You most have java installed on your system for this script to work."; exit 1; }
command -v screen >/dev/null 2>&1 || { echo -e >&2 "$ERROR[ERROR]$RESET You most have screen installed on your system to start the server. How to install: https://phoenixnap.com/kb/how-to-use-linux-screen-with-commands"; exit 1; }

# Starts the server
echo -e "$INFO[INFO]$RESET Starting screen session!"; screen -S minecraft -dm java -Xms2G -Xmx2G -jar server.jar --nogui; echo -e "$INFO[INFO]$RESET You can see the server console with screen -r minecraft"