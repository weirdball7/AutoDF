#!/bin/bash
START_TIME=''
END_TIME=''
HOME=''
MEM_DUMP=''
OUT_DIR_NAME=''
OUT_DIR_PATH=''
MEM_FILE=''
NETWORK_FILE=''

# Check the current user; exit if not root
function CHECKROOT()
{
    USER=$(whoami)
    if [ "$USER" != "root" ]; then 
        tput setaf 1 # Red
        echo 'User is not root....Exiting....' # Important output: not root
        tput sgr0
        figlet "YOU SHALL NOT PASS!" # ASCII art for not root
        exit
    else
        tput setaf 2 # Green
        echo 'User is root!...Continuing...' # Important output: root
        tput sgr0
        figlet "YOU ARE ROOT!" # ASCII art for root
        GETFILE
    fi
}

# Allow the user to specify the filename; check if the file exists
function GETFILE()
{
    tput setaf 4 # Blue
    echo "Please provide *FULL PATH* of memory dump file." # Prompt for memory dump
    tput sgr0 
    read MEM_DUMP

    if [ ! -f "$MEM_DUMP" ]; then
        tput setaf 1 # Red
        echo "File does not exist: $MEM_DUMP" # Error: file not found
        tput sgr0
        exit 1
    fi
    
    tput setaf 4 # Blue
    echo "Please provide desired name for output directory for the script" # Prompt for output dir name
    tput sgr0
    read OUT_DIR_NAME

    tput setaf 4 # Blue
    echo "Please provide desired *FULL PATH* location for output directory for the script." # Prompt for output dir path
    tput sgr0
    read OUT_DIR_PATH

    cd "$OUT_DIR_PATH" 

    if [ -d "$OUT_DIR_NAME" ]; then
        tput setaf 3 # Yellow
        echo "Directory $OUT_DIR_NAME already exists in $OUT_DIR_PATH." # Warn: dir exists
        tput sgr0
    else
        tput setaf 2 # Green
        mkdir "$OUT_DIR_NAME"
        echo "Directory Created..." # Success: dir created
        tput sgr0
    fi

    mv "$MEM_DUMP" "$OUT_DIR_PATH/$OUT_DIR_NAME"
    cd "$OUT_DIR_PATH/$OUT_DIR_NAME"
    tput setaf 6 # Cyan
    pwd # Show current path
    tput sgr0
    GETTOOLS
}

# Automate debugging/testing (delete output dir and re-unzip memory dump file)
function RESETLAB()
{
    tput setaf 1 # Red
    echo "Would you like to reset testing enviorment? [y/n]" # Prompt for reset
    tput sgr0
    read CHOICE
    if [ "$CHOICE" != "n" ]; then
        tput setaf 1 # Red
        echo "Deleting $OUT_DIR_NAME..." # Important output: deleting dir
        tput sgr0
        sleep 2
        cd
        sudo rm -rf "$OUT_DIR_PATH/$OUT_DIR_NAME"
        tput setaf 4 # Blue
        echo "Re-unzipping memory dump file..." # Important output: re-unzipping
        tput sgr0
        sleep 2
        cd $OUT_DIR_PATH
        unzip memory_file.zip
        tput setaf 6 # Cyan
        echo "Current stracture of testing enviorment:" # Show env structure
        tput sgr0
        ls
        sleep 3
        tput setaf 2 # Green
        figlet "TESTIN ENVIORMENT RESET COMPLETED SUCCSESFULLY!" # ASCII art: reset complete
        tput sgr0
        exit
    else
        tput setaf 1 # Red
        figlet "EXITING" # ASCII art: exiting
        tput sgr0
        exit
    fi
}

# Install forensics tools if missing
function GETTOOLS()
{
    tput setaf 4 # Blue
    echo "Checking if binwalk is installed..." # Checking binwalk
    tput sgr0
    sleep 1
    if ! command -v binwalk; then
        tput setaf 1 # Red
        echo "Binwalk not found...Installing...." # Installing binwalk
        tput sgr0
        sudo apt install binwalk -y
        sleep 2
    else 
        tput setaf 2 # Green
        echo "binwalk is installed.. continuing..." # Binwalk installed
        tput sgr0
        sleep 2
    fi

    tput setaf 4 # Blue
    echo "Checking if bulk-extractor is installed..." # Checking bulk-extractor
    tput sgr0
    sleep 1
    if ! command -v bulk_extractor; then
        tput setaf 1 # Red
        echo "bulk-extractor not found...Installing...." # Installing bulk-extractor
        tput sgr0
        sudo apt install bulk-extractor -y
        sleep 2
    else 
        tput setaf 2 # Green
        echo "bulk-extractor is installed.. continuing" # bulk-extractor installed
        tput sgr0
        sleep 2
    fi

    tput setaf 4 # Blue
    echo "Checking if foremost is installed..." # Checking foremost
    tput sgr0
    sleep 1
    if ! command -v foremost; then
        tput setaf 1 # Red
        echo "foremost not found...Installing...." # Installing foremost
        tput sgr0
        sudo apt install foremost -y
        sleep 2
    else 
        tput setaf 2 # Green
        echo "foremost is installed.. continuing" # foremost installed
        tput sgr0
        sleep 2
    fi

    tput setaf 4 # Blue
    echo "Checking if strings installed..." # Checking strings
    tput sgr0
    sleep 1
    if ! command -v strings; then
        tput setaf 1 # Red
        echo "strings not found...Installing...." # Installing strings
        tput sgr0
        sudo apt install binutils -y
        sleep 2
    else 
        tput setaf 2 # Green
        echo "strings is installed.. continuing" # strings installed
        tput sgr0
        sleep 2
    fi
    # TODO: Add Volatility installation
    #! ASK BEN ABOUT INSTALLATION PROCCESS  

    tput setaf 2 # Green
    figlet "ALL NEEDED TOOLS INSTALLED!" # ASCII art: all tools installed
    tput sgr0

    RUNSTRINGS
}

function RUNSTRINGS()
{
    HOME=$(pwd)
    MEM_FILE=$(basename "$MEM_DUMP")
    tput setaf 6 # Cyan
    echo "$MEM_FILE" # Show memory dump filename
    tput sgr0
    tput setaf 4 # Blue
    echo "Creating strings output directory" # Creating output dir
    tput sgr0
    sleep 1
    mkdir STRINGS_DUMP

    tput setaf 4 # Blue
    echo "Running full strings scan on $MEM_FILE" # Running strings scan
    tput sgr0
    strings $MEM_FILE > $HOME/STRINGS_DUMP/strings-full.txt
    tput setaf 2 # Green
    echo "[*SCAN COMPLETE*]" # Scan complete
    tput sgr0
    ls $HOME/STRINGS_DUMP

    tput setaf 4
    echo "Scanning for username in $MEM_FILE..."
    tput sgr0
    sleep 1
    STRINGS_USERNAME=$(strings $MEM_FILE | grep -i 'username')
    echo $STRINGS_USERNAME > $HOME/STRINGS_DUMP/strings-username.txt
    ls $HOME/STRINGS_DUMP
    tput setaf 2 # Green
    echo "[*SCAN COMPLETE*]" # Scan complete
    tput sgr0

    sleep 1


    tput setaf 4
    echo "Scanning for password in $MEM_FILE..."
    tput sgr0
    sleep 1
    STRINGS_PASSWORD=$(strings $MEM_FILE | grep -i 'password')
    echo $STRINGS_PASSWORD > $HOME/STRINGS_DUMP/strings-password.txt
    ls $HOME/STRINGS_DUMP
    tput setaf 2 # Green
    echo "[*SCAN COMPLETE*]" # Scan complete
    tput sgr0

    sleep 1


    tput setaf 4
    echo "Scanning for address in $MEM_FILE..."
    tput sgr0
    sleep 1
    STRINGS_ADDRESS=$(strings $MEM_FILE | grep -i 'address')
    echo $STRINGS_ADDRESS > $HOME/STRINGS_DUMP/strings-address.txt
    ls $HOME/STRINGS_DUMP
    tput setaf 2 # Green
    echo "[*SCAN COMPLETE*]" # Scan complete
    tput sgr0

    sleep 1


    tput setaf 4
    echo "Scanning for user in $MEM_FILE..."
    tput sgr0
    sleep 1
    STRINGS_USER=$(strings $MEM_FILE | grep -i 'user')
    echo $STRINGS_USER > $HOME/STRINGS_DUMP/strings-user.txt
    ls $HOME/STRINGS_DUMP
    tput setaf 2 # Green
    echo "[*SCAN COMPLETE*]" # Scan complete
    tput sgr0

    sleep 1

    tput setaf 4
    echo "Scanning for IP in $MEM_FILE..."
    tput sgr0
    sleep 1
    STRINGS_IP=$(strings $MEM_FILE | grep -i 'IP')
    echo $STRINGS_IP > $HOME/STRINGS_DUMP/strings-IP.txt
    ls $HOME/STRINGS_DUMP
    tput setaf 2 # Green
    echo "[*SCAN COMPLETE*]" # Scan complete
    tput sgr0

    sleep 1


    tput setaf 4
    echo "Scanning for connect in $MEM_FILE..."
    tput sgr0
    sleep 1
    STRINGS_CONNECT=$(strings $MEM_FILE | grep -i 'connect')
    echo $STRINGS_CONNECT > $HOME/STRINGS_DUMP/strings-connect.txt
    ls $HOME/STRINGS_DUMP
    tput setaf 2 # Green
    echo "[*SCAN COMPLETE*]" # Scan complete
    tput sgr0

    sleep 1

    tput setaf 4
    echo "Scanning for network in $MEM_FILE..."
    tput sgr0
    sleep 1
    STRINGS_NETWORK=$(strings $MEM_FILE | grep -i 'network')
    echo $STRINGS_NETWORK > $HOME/STRINGS_DUMP/strings-network.txt
    ls $HOME/STRINGS_DUMP
    tput setaf 2 # Green
    echo "[*SCAN COMPLETE*]" # Scan complete
    tput sgr0

    sleep 1


    tput setaf 4
    echo "Scanning for .exe in $MEM_FILE..."
    tput sgr0
    sleep 1
    STRINGS_EXE=$(strings $MEM_FILE | grep -i '.exe')
    echo $STRINGS_EXE > $HOME/STRINGS_DUMP/strings-exe.txt
    ls $HOME/STRINGS_DUMP
    tput setaf 2 # Green
    echo "[*SCAN COMPLETE*]" # Scan complete
    tput sgr0

    sleep 1

    
    # sleep 3

    RUNBINWALK
    
}

function RUNBINWALK()
{
    HOME=$(pwd)
    MEM_FILE=$(basename "$MEM_DUMP")
    echo "Running binwalk..."
    sleep 1
    mkdir BINWALK_DUMP
    ls 
    sleep 2
    binwalk $MEM_FILE > $HOME/BINWALK_DUMP/binwalk_scan.txt
    cat $HOME/BINWALK_DUMP/binwalk_scan.txt
    echo "Extracting files from binwalk scan..."
    sleep 2
    binwalk -e -C $HOME/BINWALK_DUMP --run-as=root $MEM_FILE
    ls $HOME/BINWALK_DUMP
    sleep 2
    RUNBULK
}

# ...existing code...
function RUNBULK()
{
    MEM_FILE=$(basename "$MEM_DUMP")                                 # get filename from full path
    tput setaf 4                                                      # blue
    echo "Running bulk-extractor"                                     # info: starting bulk_extractor
    tput sgr0                                                         # reset color
    sleep 1

    bulk_extractor -o BULK_DUMP $MEM_FILE                             # run bulk_extractor (output -> BULK_DUMP)

    tput setaf 2                                                      # green
    echo "bulk-extractor completed..PATH: $OUT_DIR_PATH/$OUT_DIR_NAME/BULK_DUMP"  # success + path
    tput sgr0                                                         # reset color
    sleep 1

    tput setaf 4                                                      # blue
    echo "Looking for network file..."                                # info: searching for pcap/pcapng
    tput sgr0                                                         # reset color
    sleep 1

    # Search for the first .pcap or .pcapng file under BULK_DUMP and return the full path
    NETWORK_FILE=$(find "$OUT_DIR_PATH/$OUT_DIR_NAME/BULK_DUMP" -type f \( -iname '*.pcap' -o -iname '*.pcapng' \) -print -quit)

    if [ -n "$NETWORK_FILE" ]; then
        tput setaf 2                                                  # green
        echo "Network File *FOUND* Location: $NETWORK_FILE"            # found message (full path)
        tput sgr0  
        FILE_LISTING=$(ls -l -- "$NETWORK_FILE" | awk '{print $5}')
        tput setaf 6                                                  # cyan
        echo "File size: $FILE_LISTING"
        tput sgr0
    else
        tput setaf 1                                                  # red
        echo "Network file not found"                                 # not found message
        tput sgr0                                                     # reset color
    fi

    RESETLAB                                                         # prompt to reset testing env (existing behavior)
}
#




CHECKROOT

# Use different carvers to automatically extract data.
# Attempt to extract network traffic; if found, display to the user the location and size.
# Check for human-readable (exe files, passwords, usernames, etc.).