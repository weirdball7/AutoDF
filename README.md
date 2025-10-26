# AutoDF 
![Bash](https://img.shields.io/badge/Built%20with-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey)
![Status](https://img.shields.io/badge/Status-Active-success)

AutoDF (work-in-progress) — a small collection of tooling and scripts to help automate basic memory-forensics tasks on a Linux host. The repository currently contains a Bash script (script.sh) that guides the user through preparing an output workspace, checks for and installs several common forensics utilities, runs a full strings extraction on a provided memory dump, performs keyword-focused string searches, and provides a simple reset helper to re-create a testing environment.

This README describes what the script does, how to run it, prerequisites, and suggested improvements.

## Current contents (high level)
- script.sh — main Bash script that:
  - enforces running as root,
  - prompts for a memory-dump file full path and output directory,
  - moves the memory file into the output directory,
  - checks for/installs tools (binwalk, bulk-extractor, foremost, strings/binutils),
  - creates a STRINGS_DUMP directory and writes:
    - strings-full.txt (full strings output)
    - strings-username.txt, strings-password.txt, strings-address.txt, strings-user.txt, strings-IP.txt, strings-connect.txt, strings-network.txt (keyword-filtered outputs)
  - includes a RESETLAB helper that can remove the output directory and re-unzip a `memory_file.zip` for testing.
- README.md — this file (updated)
- (future) Volatility integration is noted as TODO in the script

Script source: https://github.com/weirdball7/AutoDF/blob/main/script.sh

## Quickstart / Usage

1. Make script executable:
   chmod +x script.sh

2. Run the script as root (script checks this and will exit if not root):
   sudo ./script.sh

3. When prompted:
   - Provide the full path to the memory dump file you want analyzed (e.g. /home/user/dumps/memdump.raw).
   - Provide a name for the output directory.
   - Provide a full path where that output directory should be created.

4. Results:
   - The script moves the memory dump into the created output directory and runs a strings scan.
   - A directory called STRINGS_DUMP will be created inside the output dir and will contain:
     - strings-full.txt
     - strings-username.txt
     - strings-password.txt
     - strings-address.txt
     - strings-user.txt
     - strings-IP.txt
     - strings-connect.txt
     - strings-network.txt

5. To re-create the test environment (used by the script):
   - The RESETLAB function expects a `memory_file.zip` at the output path and will:
     - delete the output directory,
     - unzip `memory_file.zip` back into the output path,
     - display the directory listing.
   - Be careful: RESETLAB will rm -rf the output directory.

## Required / optional packages
The script attempts to install the following (using apt) if missing:
- binwalk
- bulk-extractor
- foremost
- binutils (for strings)
Additionally the script uses figlet and tput (for colored / ASCII-art output). On many systems figlet is not installed by default.

Before running the script ensure you have:
- sudo privileges (the script installs packages and expects root)
- apt available (Debian/Ubuntu)
- enough disk space for string outputs and carved files

Install common dependencies manually if you prefer:
sudo apt update
sudo apt install -y binwalk bulk-extractor foremost binutils figlet unzip

## Security & Safety notes
- The script must be run as root. Running analysis scripts as root increases risk—follow your lab policies and use isolated VMs for forensic work.
- The script moves the memory dump into the output directory. If you want to keep the original copy, make a safe copy first.
- The script uses apt to install packages; network access and package trust are required.

## Known limitations / TODOs
- Volatility (or similar memory analysis frameworks) is not installed or integrated — the script has a TODO for adding Volatility installation and plugin runs.
- The script uses interactive prompts; add a non-interactive mode or CLI flags (getopts) to integrate into pipelines.
- Filename and path handling may break with spaces or tabs (some commands are not fully quoted).
- The script calls sudo inside functions; better design is to require the user start the script with sudo and avoid nested sudo.
- RESETLAB expects a file named `memory_file.zip`; make this configurable or detect available archives automatically.
- Improve error handling (check return values from commands), add logging, and optionally archive results (tar/zip).
- Add unit/integration tests and a CI pipeline.

## Development & contribution
- This project is a WIP. If you'd like to contribute:
  - Open issues describing desired features (e.g., Volatility integration, non-interactive CLI).
  - Propose PRs with small, focused changes (improve quoting, add CLI args, implement Volatility install).
  - Keep changes tested in a disposable VM and avoid running unknown memory dumps on a host machine.

## Example improvements you can make
- Convert the script to support --input and --output CLI flags and add --non-interactive.
- Add a safer mode that copies the memory dump instead of moving it.
- Add configurable keyword list instead of hardcoded keyword greps.
- Integrate Volatility and extract process/registry/web-credentials artifacts.
- Make the tool OS-agnostic (support Fedora/RHEL by adding alternative package manager calls).

## License
No license file in the repository yet. Add a LICENSE (e.g. MIT) if you want to open-source this project.

## Contact
Maintainer: weirdball7 (GitHub)
Open an issue in this repository for questions or improvements.

---

Lightweight Bash wrapper to run quick memory-dump forensics (strings, binwalk, bulk-extractor, foremost, volatility helper). The script colorizes important terminal output and includes inline comments for clarity.

## Prerequisites
- Run as root (script enforces this in `CHECKROOT`).
- Bash (tested on Ubuntu / WSL).
- Tools the script checks/installs:
  - binwalk
  - bulk-extractor (checked as `bulk_extractor`)
  - foremost
  - binutils (for `strings`)
  - figlet (optional, used for banners)
  - unzip (used by `RESETLAB`)

## How the script works (high level)
1. `CHECKROOT` — exit if current user is not root.
2. `GETFILE` — prompts for:
   - full path to memory dump (`MEM_DUMP`)
   - output directory name (`OUT_DIR_NAME`)
   - output directory path (`OUT_DIR_PATH`)
   Moves the memdump into: `$OUT_DIR_PATH/$OUT_DIR_NAME` and cds there.
3. `GETTOOLS` → `VOLSETUP` — checks/installs tools and prepares volatility helper files, then proceeds to extraction functions.
4. `RUNSTRINGS` — sets `HOME=$(pwd)`, creates `STRINGS_DUMP/` and runs multiple `strings` scans creating:
   - `strings-full.txt`
   - `strings-username.txt`
   - `strings-password.txt`
   - `strings-address.txt`
   - `strings-user.txt`
   - `strings-IP.txt`
   - `strings-connect.txt`
   - `strings-network.txt`
   - `strings-exe.txt`
   Files are written under `$HOME/STRINGS_DUMP` (where `HOME` is the script's current working directory).
5. `RUNBINWALK` — creates `BINWALK_DUMP/`, runs `binwalk` and `binwalk -e` and saves scans to `$HOME/BINWALK_DUMP`.
6. `RUNBULK` — runs `bulk_extractor -o BULK_DUMP <memfile>` (relative to the current working dir), then searches:
   - `"$OUT_DIR_PATH/$OUT_DIR_NAME/BULK_DUMP"` for `.pcap` / `.pcapng`
   - first hit is stored in `NETWORK_FILE`
   - file size is captured into a variable using `FILE_LISTING=$(ls -l -- "$NETWORK_FILE" | awk '{print $5}')`
7. `RUNFOREMOST` — runs `foremost -i $MEM_FILE -o FOREMOST_DUMP`.
8. `RUNVOL` — runs the volatility helper `./vol` against `$MEM_FILE` and writes `imageinfo` to `VOLATILITY_DUMP`.
9. `RESETLAB` — prompts to delete output dir and can re-unzip `memory_file.zip` for testing.

## Output layout (example)
Given OUT_DIR_PATH=/some/path and OUT_DIR_NAME=ProjectDump:
- /some/path/ProjectDump/
  - STRINGS_DUMP/
    - strings-full.txt
    - strings-username.txt
    - ...
  - BINWALK_DUMP/
    - binwalk_scan.txt
    - (extracted files)
  - BULK_DUMP/
    - packets.pcap (if found)
    - bulk_extractor outputs
  - FOREMOST_DUMP/
  - VOLATILITY_DUMP/

## Color convention (tput)
- Red (1) = errors / destructive actions
- Blue (4) = info / prompts
- Green (2) = success / completion
- Cyan (6) = details / listings
- Yellow (3) = warnings

## Usage
1. Make script executable:
   sudo chmod +x script.sh
2. Run:
   sudo ./script.sh
3. Follow prompts:
   - Full path to memdump (e.g. `/home/user/memdump.mem`)
   - Output directory name (e.g. `ProjectDump`)
   - Output directory path (e.g. `/home/user/forensics`)

## Important notes & caveats (based on script behavior)
- The script moves the supplied memdump into the chosen output folder and runs tools from there. `bulk_extractor` is invoked with a relative `-o BULK_DUMP`, so outputs appear under the working directory where the command runs.
- `RUNSTRINGS` sets `HOME=$(pwd)` and writes string outputs to `$HOME/STRINGS_DUMP`. Expect `HOME` here to be the working dir, not the system user home.
- `RUNBULK` finds network captures using `find "$OUT_DIR_PATH/$OUT_DIR_NAME/BULK_DUMP" ... -print -quit` and stores the first match in `NETWORK_FILE`.
- File size for found network captures is captured using `ls -l -- "$NETWORK_FILE" | awk '{print $5}'` and printed as `File size`.
- Many commands in the script rely on the current working directory being `$OUT_DIR_PATH/$OUT_DIR_NAME`. If you change working directories outside the script, outputs/paths may differ.
- Variable assignment must not include `$` on the left side (use `VAR=value`).
- Some commands in the script use unquoted variables (e.g. `$MEM_FILE` in a few places). Be careful with paths containing spaces.

## Debug tips
- Enable shell tracing:
  set -x
  sudo ./script.sh
  set +x
- Print relevant variables during run:
  echo "OUT_DIR_PATH='$OUT_DIR_PATH' OUT_DIR_NAME='$OUT_DIR_NAME' MEM_DUMP='$MEM_DUMP'"

## License / Disclaimer
For lab / educational use only. Verify legal authority before analyzing memory images.
