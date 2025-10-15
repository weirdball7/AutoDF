#!/bin/bash
# Check the current user exit if not root 
function CHECKROOT()
{
    USER=$(whoami)
    if [ "$USER" != "root" ]; then 
        echo 'User is not root....Exiting....'
        figlet "YOU SHALL NOT PASS!"
        exit
    else
        echo 'User is root!...Continuing...'
        figlet "YOU ARE ROOT!"
    fi
}
CHECKROOT
# Allow the user to specify the filename; check if the file exists

#  Create a function to install the forensics tools if missing.

# Use different carvers to automatically extract data.

#  Use different carvers to automatically extract data
   # Data should be saved into a directory

#  Attempt to extract network traffic; if found, display to the user the location and size.

# Check for human-readable (exe files, passwords, usernames, etc.).

