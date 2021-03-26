#!/bin/bash

# Color variables
INFO='\033[1;32m[INFO]\033[0m'
ERROR='\033[1;31m[ERROR]\033[0m'

# Checks if you have the required programs installed for the script to work
command -v jq >/dev/null 2>&1 || { echo -e >&2 "$ERROR You most have jq installed on your system for this script to work. How to install: https://stedolan.github.io/jq/download/"; exit 1; }
command -v wget >/dev/null 2>&1 || { echo -e >&2 "$ERROR You most have wget installed on your system for this script to work.  How to install: https://phoenixnap.com/kb/wget-command-with-examples"; exit 1; }

# Asks for the name of the directory you want
echo "Please enter the name of the server directory"; read server_directory

# Checks to see if the provided directory exists
if [ -d "$server_directory" ]; then
    echo -e "$ERROR The provided directory already exists."
    echo -e "$ERROR Please provide another directory name or delete the provided directory."
    exit 1
fi

# Asks for the Paper version you want to use
echo "Please enter the version of Paper you want to use"; read version

# Chceks for the latest Paper build for the version provided
version_number=`curl -sS -X GET "https://papermc.io/api/v2/projects/paper/versions/$version" -H  "accept: application/json" | jq '.builds | last'`

# Checks to see if the version that was provided doesn't exist
if [ $version_number == "null" ]; then
    echo -e "$ERROR The Paper version you provided is invalid."
    exit 1
fi

# Makes the server directory with the provided name 
echo -e "$INFO Making server directory."; mkdir $server_directory
# Downloads the requested versiuon of Paper
echo -e "$INFO Downloading Paper $version..."; wget https://papermc.io/api/v2/projects/paper/versions/$version/builds/$version_number/downloads/paper-$version-$version_number.jar &> /dev/null; echo -e "$INFO Finished downloading Paper $version!"
# Moves the Paper jar to the server directory
echo -e "$INFO Moving jar file to server directory."; mv paper-$version-$version_number.jar ./$server_directory/

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
    echo -e "$INFO You'll have to manually set the EULA to true"
    exit 0
fi

# Move the to the server directory
cd $server_directory
# Makes the eula.txt file and sets it to true
touch eula.txt; printf "eula=true" >> eula.txt

# Asks if you want to start the server right now
if [[ "no" == $(yes_or_no "Do you want to start the server now? Must have screen installed!") ]]; then
    echo -e "$INFO Script has finished!"
    exit 0
fi

# Checks if screen and java is installed 
command -v screen >/dev/null 2>&1 || { echo -e >&2 "$ERROR You most have screen installed on your system to start the server. How to install: https://phoenixnap.com/kb/how-to-use-linux-screen-with-commands"; exit 1; }
command -v java >/dev/null 2>&1 || { echo -e >&2 "$ERROR You most have java installed on your system to start the server."; exit 1; }

# Starts the server
echo -e "$INFO Starting screen session!"; screen -S minecraft -dm java -Xms2G -Xmx2G -jar paper-$version-$version_number.jar; echo -e "$INFO You can see the server console with screen -r minecraft"