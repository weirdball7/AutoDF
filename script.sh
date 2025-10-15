#!/bin/bash
START_TIME=''
END_TIME=''
HOME=$(pwd)
MEM_DUMP=''
OUT_DIR_NAME=''
OUT_DIR_PATH=''
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
        GETFILE
        #echo $HOME
    fi
}

# Allow the user to specify the filename; check if the file exists
function GETFILE()
{

    echo "Please provide *FULL PATH* of memory dump file."
    read MEM_DUMP 

    if [ ! -f "$MEM_DUMP" ]; then
        echo "File does not exist: $MEM_DUMP"
        exit 1
    fi
    
    echo "Please provide desired name for output directory for the script"
    read OUT_DIR_NAME

    echo "Please provide desired location for output directory for the script."
    read OUT_DIR_PATH

    cd "$OUT_DIR_PATH" 

    if [ -d "$OUT_DIR_NAME" ]; then
        echo "Directory $OUT_DIR_NAME already exists in $OUT_DIR_PATH."
    else
        mkdir "$OUT_DIR_NAME"
    fi

    mv "$MEM_DUMP" "$OUT_DIR_PATH/$OUT_DIR_NAME"
    cd "$OUT_DIR_PATH/$OUT_DIR_NAME"
}


CHECKROOT
#  Create a function to install the forensics tools if missing.

# Use different carvers to automatically extract data.

#  Use different carvers to automatically extract data
   # Data should be saved into a directory

#  Attempt to extract network traffic; if found, display to the user the location and size.

# Check for human-readable (exe files, passwords, usernames, etc.).

