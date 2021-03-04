#!/bin/bash

# Color variables
INFO='\033[1;32m'
ERROR='\033[1;31m'
RESET='\033[0m'

# Checks if you have the required programs installed for the script to work
command -v wget >/dev/null 2>&1 || { echo -e >&2 "$ERROR[ERROR]$RESET You most have wget installed on your system for this script to work.  How to install: https://phoenixnap.com/kb/wget-command-with-examples"; exit 1; }
command -v java >/dev/null 2>&1 || { echo -e >&2 "$ERROR[ERROR]$RESET You most have java installed on your system for this script to work."; exit 1; }
command -v git >/dev/null 2>&1 || { echo -e >&2 "$ERROR[ERROR]$RESET You most have git installed on your system for this script to work.  How to install: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"; exit 1; }

# Asks for the name of the directory you want
echo -e "Please enter the name of the server directory"; read server_directory

# Checks to see if the provided directory exists
if [ -d "$server_directory" ]; then
    echo -e "$ERROR[ERROR]$RESET The provided directory already exists."
    echo -e "$ERROR[ERROR]$RESET Please provide another directory name or delete the provided directory."
    exit 1
fi

# Asks for the Spigot version you want to use
echo -e "Please enter the version of Spigot you want to use"; read version

# Checks to see if the BuildTools directory exists
if [ -d "BuildTools" ]; then
    echo -e "$ERROR[ERROR]$RESET The BuildTools directory already exists."
    echo -e "$ERROR[ERROR]$RESET Please delete the BuildTools directory and then start this script again."
    exit 1
fi
# Makes the BuildTools directory
echo -e "$INFO[INFO]$RESET Making BuildTools directory."; mkdir BuildTools
# Downloads BuildTools
echo -e "$INFO[INFO]$RESET Downloading BuildTools..."; wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar &> /dev/null; echo -e "$INFO[INFO]$RESET Finished downloading BuildTools!"
# Moves the BuildTools jar to the BuildTools directory
echo -e "$INFO[INFO]$RESET Moving jar file to BuildTools directory."; mv BuildTools.jar ./BuildTools/
# Enters BuildTools directory
echo -e "$INFO[INFO]$RESET Entering BuildTools directory"; cd BuildTools
# Builds the provided Spigot version
echo -e "$INFO[INFO]$RESET Building Spigot version $version... This may take a while."; sleep 5; java -jar BuildTools.jar --rev $version; echo -e "$INFO[INFO]$RESET Done building Spigot jar!"
# Moves back to the directory of where the script is located
echo -e "$INFO[INFO]$RESET Moving back to base directory."; cd ..
# Check to see if the provided server directory already exists
if [ -d "$server_directory" ]; then
    echo -e "$ERROR[ERROR]$RESET The provided server directory already exists."
    echo -e "$ERROR[ERROR]$RESET Please provide another server directory or delete the provided directory."
    exit 1
fi
# Makes server directory
echo -e "$INFO[INFO]$RESET Making server directory."; mkdir $server_directory
# Moves spigot jar to server directory
echo -e "$INFO[INFO]$RESET Moving the Spigot jar to the server directory."; mv ./BuildTools/spigot-$version.jar ./$server_directory/
# Deletes the BuildTools directory
echo -e "$INFO[INFO]$RESET Deleting the BuildTools directory."; rm -rf BuildTools

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

# Checks if screen is installed 
command -v screen >/dev/null 2>&1 || { echo -e >&2 "$ERROR[ERROR]$RESET You most have screen installed on your system to start the server. How to install: https://phoenixnap.com/kb/how-to-use-linux-screen-with-commands"; exit 1; }

# Starts the server
echo -e "$INFO[INFO]$RESET Starting screen session!"; screen -S minecraft -dm java -Xms2G -Xmx2G -jar spigot-$version.jar; echo -e "$INFO[INFO]$RESET You can see the server console with screen -r minecraft"