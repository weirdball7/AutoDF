#!/bin/bash
START_TIME=''
END_TIME=''
HOME=''
MEM_DUMP=''
OUT_DIR_NAME=''
OUT_DIR_PATH=''
MEM_FILE=''
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

    echo "Please provide desired *FULL PATH* location for output directory for the script."
    read OUT_DIR_PATH

    cd "$OUT_DIR_PATH" 

    if [ -d "$OUT_DIR_NAME" ]; then
        echo "Directory $OUT_DIR_NAME already exists in $OUT_DIR_PATH."
    else
        mkdir "$OUT_DIR_NAME"
        echo "Directory Created..."
    fi

    mv "$MEM_DUMP" "$OUT_DIR_PATH/$OUT_DIR_NAME"
    cd "$OUT_DIR_PATH/$OUT_DIR_NAME"
    pwd 
    GETTOOLS
    
}

#! THIS FUNCTION IS FOR AUTOMATING DUBUGING AND TESTING (DELETING OUTPUT DIRETORY AND RE-UNZIPING MEMORY DUMP FILE)
function RESETLAB()
{
    echo "Would you like to reset testing enviorment? [y/n]"
    read CHOICE
    if [ "$CHOICE" != "n" ]; then
        echo "Deleting $OUT_DIR_NAME..."
        sleep 2
        cd
        sudo rm -rf "$OUT_DIR_PATH/$OUT_DIR_NAME"
        echo "Re-unzipping memory dump file..."
        sleep 2
        cd $OUT_DIR_PATH
        unzip memory_file.zip
        echo "Current stracture of testing enviorment:"
        ls
        sleep 3
        figlet "TESTIN ENVIORMENT RESET COMPLETED SUCCSESFULLY!"
        exit
    else
        figlet "EXITING"
        exit
    fi


}


#  Create a function to install the forensics tools if missing.
function GETTOOLS()
{
    echo "Checking if binwalk is installed..."
    sleep 1
    if ! command -v binwalk; then
        echo "Binwalk not found...Installing...."
        sudo apt install binwalk -y
        sleep 2
    else 
        echo "binwalk is installed.. continuing..."
        sleep 2
    fi

    echo "Checking if bulk-extractor is installed..."
    sleep 1
    if ! command -v bulk-extractor; then
        echo "bulk-extractor not found...Installing...."
        sudo apt install bulk-extractor -y
        sleep 2
    else 
        echo "bulk-extractor is installed.. continuing"
        sleep 2
    fi

    echo "Checking if foremost is installed..."
    sleep 1
    if ! command -v foremost; then
        echo "foremost not found...Installing...."
        sudo apt install foremost -y
        sleep 2
    else 
        echo "foremost is installed.. continuing"
        sleep 2
    fi

    echo "Checking if strings installed..."
    sleep 1
    if ! command -v strings; then
        echo "strings not found...Installing...."
        sudo apt install binutils -y
        sleep 2
    else 
        echo "strings is installed.. continuing"
        sleep 2
    fi
    # TODO: Add Volatility installation
    #! ASK BEN ABOUT INSTALLATION PROCCESS  

    
    figlet "ALL NEEDED TOOLS INSTALLED!"

    # RESETLAB
    RUNSTRINGS
}


function RUNSTRINGS()
{
    HOME=$(pwd)
    MEM_FILE=$(basename "$MEM_DUMP")
    echo "$MEM_FILE"
    echo "Creating strings output directory"
    sleep 1
    mkdir STRINGS_DUMP
    #? - Possible approach but it producess more work down the line.
    #? mv $MEM_FILE STRINGS_DUMP 
    #? cd STRINGS_DUMP
    #? strings $MEM_FILE > strings-full.txt
    #! - Better approach -
    strings $MEM_FILE > $HOME/STRINGS_DUMP/strings-full.txt 
    pwd 
    ls
    ls $HOME/STRINGS_DUMP
    sleep 1
    RESETLAB
}


CHECKROOT



# Use different carvers to automatically extract data.

#  Use different carvers to automatically extract data
   # Data should be saved into a directory

#  Attempt to extract network traffic; if found, display to the user the location and size.

# Check for human-readable (exe files, passwords, usernames, etc.).

