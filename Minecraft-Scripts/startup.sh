#!/bin/bash

# Checks to see if you have java installed 
command -v java >/dev/null 2>&1 || { echo >&2 "You most have java installed on your system to start the server."; exit 1; }

# Asks for the server jar name
echo "Please enter the name of the jar file (without the .jar)"
read jar_name

# Starts the server
java -Xms1G -Xmx2G -jar $jar_name.jar