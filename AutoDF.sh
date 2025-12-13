#!/bin/bash

# AutoDF - main script (colors + inline comments added)
START_TIME=''
END_TIME=''
HOME=''                # will be set to working dir inside RUNSTRINGS
MEM_DUMP=''            # full path provided by user
OUT_DIR_NAME=''        # user-provided project name
OUT_DIR_PATH=''        # user-provided parent path for project
MEM_FILE=''            # basename of MEM_DUMP
NETWORK_FILE=''        # path to first found pcap/pcapng (if any)

# Color helper comment:
# tput setaf N -> set color; tput sgr0 -> reset color
# Color mapping used in this script: 1=red,2=green,3=yellow,4=blue,6=cyan

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

    # Validate memory dump file exists
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

    # Change to parent / create project directory if needed
    cd "$OUT_DIR_PATH" || { tput setaf 1; echo "Cannot cd to $OUT_DIR_PATH"; tput sgr0; exit 1; }

    if [ -d "$OUT_DIR_NAME" ]; then
        tput setaf 3 # Yellow
        echo "Directory $OUT_DIR_NAME already exists in $OUT_DIR_PATH." # Warn: dir exists
        tput sgr0
    else
        tput setaf 2 # Green
        mkdir -p "$OUT_DIR_NAME"     # create directory safely
        echo "Directory Created..." # Success: dir created
        tput sgr0
    fi

    # move memdump into project dir and cd there
    mv "$MEM_DUMP" "$OUT_DIR_PATH/$OUT_DIR_NAME"
    cd "$OUT_DIR_PATH/$OUT_DIR_NAME" || exit 1
    tput setaf 6 # Cyan
    pwd # Show current path (detail)
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
        cd || exit 1
        sudo rm -rf "$OUT_DIR_PATH/$OUT_DIR_NAME" # delete project dir
        tput setaf 4 # Blue
        echo "Re-unzipping memory dump file..." # Important output: re-unzipping
        tput sgr0
        sleep 2
        cd "$OUT_DIR_PATH" || exit 1
        unzip memory_file.zip # re-extract testing archive (if present)
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
    if ! command -v binwalk > /dev/null; then
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
    if ! command -v bulk_extractor > /dev/null; then
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
    if ! command -v foremost > /dev/null; then
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
    if ! command -v strings > /dev/null; then
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
    
    tput setaf 2 # Green
    figlet "ALL NEEDED TOOLS INSTALLED!" # ASCII art: all tools installed
    tput sgr0

    VOLSETUP
}

function VOLSETUP()
{
    tput setaf 4 # Blue
    echo "Seting up Volatility... " # Info: copy volatility helper
    tput sgr0

    # Copy the standalone volatility binary into the working dir
    cd "$OUT_DIR_PATH/Volatililty_for_Linux/volatility_2.5.linux.standalone" || exit 1
    sleep 1
    cp "$OUT_DIR_PATH/Volatililty_for_Linux/volatility_2.5.linux.standalone/vol" "$OUT_DIR_PATH/$OUT_DIR_NAME"
    cd "$OUT_DIR_PATH/$OUT_DIR_NAME" || exit 1
    figlet "VOLATILITY IS ALL SET!"
    RUNSTRINGS
}

function RUNSTRINGS()
{
    HOME=$(pwd) # set HOME for strings outputs to working dir
    MEM_FILE=$(basename "$MEM_DUMP") # get only filename
    tput setaf 6 # Cyan
    echo "$MEM_FILE" # Show memory dump filename (detail)
    tput sgr0

    tput setaf 4 # Blue
    echo "Creating strings output directory" # Creating output dir
    tput sgr0
    sleep 1
    mkdir -p STRINGS_DUMP # use -p to avoid errors

    tput setaf 4 # Blue
    echo "Running full strings scan on $MEM_FILE" # Running strings scan
    tput sgr0
    strings "$MEM_FILE" > "$HOME/STRINGS_DUMP/strings-full.txt"
    tput setaf 2 # Green
    echo "[*SCAN COMPLETE*]" # Scan complete
    tput sgr0
    ls "$HOME/STRINGS_DUMP"

    # Search and save specific patterns (username, password, address, etc.)
    tput setaf 4; echo "Scanning for username in $MEM_FILE..."; tput sgr0
    sleep 1
    STRINGS_USERNAME=$(strings "$MEM_FILE" | grep -i 'username' || true)
    echo "$STRINGS_USERNAME" > "$HOME/STRINGS_DUMP/strings-username.txt"
    ls "$HOME/STRINGS_DUMP"
    tput setaf 2; echo "[*SCAN COMPLETE*]"; tput sgr0
    sleep 1

    tput setaf 4; echo "Scanning for password in $MEM_FILE..."; tput sgr0
    sleep 1
    STRINGS_PASSWORD=$(strings "$MEM_FILE" | grep -i 'password' || true)
    echo "$STRINGS_PASSWORD" > "$HOME/STRINGS_DUMP/strings-password.txt"
    ls "$HOME/STRINGS_DUMP"
    tput setaf 2; echo "[*SCAN COMPLETE*]"; tput sgr0
    sleep 1

    tput setaf 4; echo "Scanning for address in $MEM_FILE..."; tput sgr0
    sleep 1
    STRINGS_ADDRESS=$(strings "$MEM_FILE" | grep -i 'address' || true)
    echo "$STRINGS_ADDRESS" > "$HOME/STRINGS_DUMP/strings-address.txt"
    ls "$HOME/STRINGS_DUMP"
    tput setaf 2; echo "[*SCAN COMPLETE*]"; tput sgr0
    sleep 1

    tput setaf 4; echo "Scanning for user in $MEM_FILE..."; tput sgr0
    sleep 1
    STRINGS_USER=$(strings "$MEM_FILE" | grep -i 'user' || true)
    echo "$STRINGS_USER" > "$HOME/STRINGS_DUMP/strings-user.txt"
    ls "$HOME/STRINGS_DUMP"
    tput setaf 2; echo "[*SCAN COMPLETE*]"; tput sgr0
    sleep 1

    tput setaf 4; echo "Scanning for IP in $MEM_FILE..."; tput sgr0
    sleep 1
    STRINGS_IP=$(strings "$MEM_FILE" | grep -i 'IP' || true)
    echo "$STRINGS_IP" > "$HOME/STRINGS_DUMP/strings-IP.txt"
    ls "$HOME/STRINGS_DUMP"
    tput setaf 2; echo "[*SCAN COMPLETE*]"; tput sgr0
    sleep 1

    tput setaf 4; echo "Scanning for connect in $MEM_FILE..."; tput sgr0
    sleep 1
    STRINGS_CONNECT=$(strings "$MEM_FILE" | grep -i 'connect' || true)
    echo "$STRINGS_CONNECT" > "$HOME/STRINGS_DUMP/strings-connect.txt"
    ls "$HOME/STRINGS_DUMP"
    tput setaf 2; echo "[*SCAN COMPLETE*]"; tput sgr0
    sleep 1

    tput setaf 4; echo "Scanning for network in $MEM_FILE..."; tput sgr0
    sleep 1
    STRINGS_NETWORK=$(strings "$MEM_FILE" | grep -i 'network' || true)
    echo "$STRINGS_NETWORK" > "$HOME/STRINGS_DUMP/strings-network.txt"
    ls "$HOME/STRINGS_DUMP"
    tput setaf 2; echo "[*SCAN COMPLETE*]"; tput sgr0
    sleep 1

    tput setaf 4; echo "Scanning for .exe in $MEM_FILE..."; tput sgr0
    sleep 1
    STRINGS_EXE=$(strings "$MEM_FILE" | grep -i '.exe' || true)
    echo "$STRINGS_EXE" > "$HOME/STRINGS_DUMP/strings-exe.txt"
    ls "$HOME/STRINGS_DUMP"
    tput setaf 2; echo "[*SCAN COMPLETE*]"; tput sgr0
    sleep 1

    RUNBINWALK
}

function RUNBINWALK()
{
    HOME=$(pwd)                 # ensure HOME points to working dir
    MEM_FILE=$(basename "$MEM_DUMP")
    tput setaf 4; echo "Running binwalk..." ; tput sgr0
    sleep 1
    mkdir -p BINWALK_DUMP
    ls
    sleep 2
    binwalk "$MEM_FILE" > "$HOME/BINWALK_DUMP/binwalk_scan.txt"
    cat "$HOME/BINWALK_DUMP/binwalk_scan.txt"
    tput setaf 4; echo "Extracting files from binwalk scan..." ; tput sgr0
    sleep 2
    binwalk -e -C "$HOME/BINWALK_DUMP" --run-as=root "$MEM_FILE"
    ls "$HOME/BINWALK_DUMP"
    sleep 2
    RUNBULK
}

function RUNBULK()
{
    MEM_FILE=$(basename "$MEM_DUMP")                                 # get filename from full path
    tput setaf 4                                                      # blue
    echo "Running bulk-extractor"                                     # info: starting bulk_extractor
    tput sgr0                                                         # reset color
    sleep 1

    # bulk_extractor writes into a 'BULK_DUMP' directory relative to current working dir
    bulk_extractor -o BULK_DUMP "$MEM_FILE"

    tput setaf 2                                                      # green
    echo "bulk-extractor completed..PATH: $OUT_DIR_PATH/$OUT_DIR_NAME/BULK_DUMP"  # success + path
    tput sgr0                                                         # reset color
    sleep 1

    tput setaf 4                                                      # blue
    echo "Looking for network file..."                                # info: searching for pcap/pcapng
    tput sgr0                                                         # reset color
    sleep 1

    # Search for the first .pcap or .pcapng file under project BULK_DUMP (absolute path)
    NETWORK_FILE=$(find "$OUT_DIR_PATH/$OUT_DIR_NAME/BULK_DUMP" -type f \( -iname '*.pcap' -o -iname '*.pcapng' \) -print -quit 2>/dev/null)

    if [ -n "$NETWORK_FILE" ]; then
        tput setaf 2                                                  # green
        echo "Network File *FOUND* Location: $NETWORK_FILE"            # found message (full path)
        tput sgr0  
        FILE_LISTING=$(ls -l -- "$NETWORK_FILE" | awk '{print $5}')    # capture file size (bytes) safely
        tput setaf 6                                                  # cyan
        echo "File size: $FILE_LISTING"
        tput sgr0
    else
        tput setaf 1                                                  # red
        echo "Network file not found"                                 # not found message
        tput sgr0                                                     # reset color
    fi

    RUNFOREMOST                                                        # continue pipeline
}

function RUNFOREMOST()
{
    tput setaf 4; echo "Starting foremost..." ; tput sgr0
    sleep 1
    foremost -i "$MEM_FILE" -o FOREMOST_DUMP
    tput setaf 2; echo "[*COMPLETE!*]" ; tput sgr0
    ls "$OUT_DIR_PATH/$OUT_DIR_NAME/FOREMOST_DUMP"
    sleep 3

    RUNVOL
}

function RUNVOL()
{
    tput setaf 4; echo "Running volatility..." ; tput sgr0
    sleep 2
    mkdir -p VOLATILITY_DUMP
    ./vol -f "$MEM_FILE" --output-file="$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/imageinfo.txt" imageinfo
    cat "$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/imageinfo.txt"

    tput setaf 4; echo "Getting profile..." ; tput sgr0
    sleep 1
    SYSPROF=$(./vol -f "$MEM_FILE" imageinfo | grep -i profile | awk '{print $4}' | tr -d ',') # detect profile
    echo "$SYSPROF"
    sleep 2

    tput setaf 4; echo "Geting list of running proccesses...." ; tput sgr0
    sleep 1
    ./vol -f "$MEM_FILE" --profile="$SYSPROF" --output-file="$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/pslist.txt" pslist
    cat "$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/pslist.txt"
    sleep 1

    tput setaf 4; echo "Getting list of network connections...." ; tput sgr0
    if [ "$SYSPROF" != "WinXPSP2x86" ] && [ "$SYSPROF" != "Win2003SP2x64" ]; then
        ./vol -f "$MEM_FILE" --profile="$SYSPROF" --output-file="$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/netscan.txt" netscan
        cat "$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/netscan.txt"
    else 
        tput setaf 3; echo "Invalid profile for netscan, trying connections instead...." ; tput sgr0
        ./vol -f "$MEM_FILE" --profile="$SYSPROF" --output-file="$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/connections.txt" connections
        cat "$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/connections.txt"
    fi

    tput setaf 4; echo "Looking for registery information...." ; tput sgr0
    ./vol -f "$MEM_FILE" --profile="$SYSPROF" --output-file="$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/hivelist.txt" hivelist
    cat "$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/hivelist.txt"

    tput setaf 4; echo "Extracting registery files...." ; tput sgr0
    mkdir -p "$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/REGDUMP"
    ./vol -f "$MEM_FILE" --profile="$SYSPROF" --dump-dir="$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/REGDUMP" dumpregistry
    ls "$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/REGDUMP"
    sleep 2
    
    GENERATE_REPORT
}

function GENERATE_REPORT()
{
    REPORT_FILE="$OUT_DIR_PATH/$OUT_DIR_NAME/REPORT.txt"
    mkdir -p "$OUT_DIR_PATH/$OUT_DIR_NAME"

    START_TIME=${START_TIME:-$(stat -c %y "$OUT_DIR_PATH/$OUT_DIR_NAME" 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')}
    END_TIME=$(date '+%Y-%m-%d %H:%M:%S')

    {
        echo "========================================"
        echo "AutoDF Findings Report"
        echo "Generated: $END_TIME"
        echo "========================================"
        echo
        echo "Start time: $START_TIME"
        echo "End time:   $END_TIME"
        echo

        echo "Memory dump"
        MEM_PATH="$OUT_DIR_PATH/$OUT_DIR_NAME/$MEM_FILE"
        echo "  Name: $MEM_FILE"
        if [ -f "$MEM_PATH" ]; then
            du -h --max-depth=0 "$MEM_PATH" 2>/dev/null | awk '{print "  Path: " $2 "\n  Size: " $1}'
        else
            echo "  Path: $MEM_PATH (not found)"
        fi
        echo

        echo "Overall output directory"
        du -sh "$OUT_DIR_PATH/$OUT_DIR_NAME" 2>/dev/null | awk '{print "  Path: " $2 "\n  Total size: " $1}'
        echo

        echo "Per-tool summaries:"
        for DIR in STRINGS_DUMP BINWALK_DUMP BULK_DUMP FOREMOST_DUMP VOLATILITY_DUMP VOLATILITY_DUMP/REGDUMP; do
            FULL="$OUT_DIR_PATH/$OUT_DIR_NAME/$DIR"
            if [ -d "$FULL" ]; then
                echo "  $DIR"
                du -sh "$FULL" 2>/dev/null | awk '{print "    Size: " $1}'
                echo -n "    Files: "
                find "$FULL" -type f 2>/dev/null | wc -l | awk '{print $1}'
            fi
        done
        echo

        echo "Top 10 largest files in output dir:"
        du -ah "$OUT_DIR_PATH/$OUT_DIR_NAME" 2>/dev/null | sort -hr | head -n 10
        echo

        echo "Network capture(s) (pcap/pcapng) found:"
        NETWORK_FILE=${NETWORK_FILE:-$(find "$OUT_DIR_PATH/$OUT_DIR_NAME/BULK_DUMP" -type f \( -iname '*.pcap' -o -iname '*.pcapng' \) -print -quit 2>/dev/null)}
        if [ -n "$NETWORK_FILE" ]; then
            du -h "$NETWORK_FILE" 2>/dev/null | awk '{print "  " $2 " : " $1}'
        else
            echo "  None found"
        fi
        echo

        echo "Volatility information (if available):"
        IMGINFO="$OUT_DIR_PATH/$OUT_DIR_NAME/VOLATILITY_DUMP/imageinfo.txt"
        if [ -f "$IMGINFO" ]; then
            echo "  imageinfo (excerpt):"
            sed -n '1,40p' "$IMGINFO" | sed 's/^/    /'
            echo
        else
            echo "  imageinfo not available"
            echo
        fi

        echo "Counts by common extensions (excerpt):"
        for EXT in txt log pcap pcapng exe dll jpg png gif sh py; do
            CNT=$(find "$OUT_DIR_PATH/$OUT_DIR_NAME" -type f -iname "*.$EXT" 2>/dev/null | wc -l)
            [ "$CNT" -gt 0 ] && echo "  .$EXT : $CNT"
        done
        echo

        echo "Quick file age summary (newest 5 files):"
        find "$OUT_DIR_PATH/$OUT_DIR_NAME" -type f -printf '%TY-%Tm-%Td %TH:%TM:%TS %p\n' 2>/dev/null | sort -r | head -n 5 | sed 's/^/  /'
        echo

        echo "End of report."
    } > "$REPORT_FILE"

    tput setaf 6 2>/dev/null || true
    echo "Report written to: $REPORT_FILE"
    tput sgr0 2>/dev/null || true

    # Print report to stdout for immediate inspection
    cat "$REPORT_FILE"

    ZIPOUTPUT
}

function ZIPOUTPUT()
{
    cd "$OUT_DIR_PATH" || exit 1
    zip -r "$OUT_DIR_NAME.zip" "$OUT_DIR_PATH"
    ls
    RESETLAB
}

CHECKROOT 

# Use different carvers to automatically extract data.
# Attempt to extract network traffic; if found, display to the user the location and size.
# Check for human-readable (exe files, passwords, usernames, etc.).