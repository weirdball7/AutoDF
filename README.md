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

Lightweight wrapper script to run quick memory-dump forensics (strings / binwalk / bulk-extractor) and collect outputs into a user-specified directory. Outputs are colorized in the terminal for important messages.

## Prerequisites
- Run as root (script checks and exits if not root).
- Tools required (script will attempt to install missing ones):
  - binwalk
  - bulk-extractor
  - foremost
  - binutils (for `strings`)
- Bash shell (Ubuntu / WSL recommended for this environment).

## How it works (high level)
1. Prompts for full path to memory dump.
2. Prompts for output directory name and location; moves memdump into that directory.
3. Ensures directories and runs toolchains:
   - Strings extraction -> `STRINGS_DUMP/`
   - Binwalk output -> `BINWALK_DUMP/`
   - bulk_extractor output -> `BULK_DUMP/`
4. Looks for network capture files (pcap / pcapng) inside `BULK_DUMP` and reports location & size.
5. Prompts to reset testing environment (delete and optionally re-unzip).

## Usage
1. Make script executable:
   sudo chmod +x script.sh
2. Run:
   sudo ./script.sh
3. Follow prompts:
   - Provide full path to memory dump (e.g. /home/user/dumps/memdump.mem)
   - Provide output directory name (e.g. ProjectDump)
   - Provide output directory path (e.g. /home/user/forensics)

## Output layout
After run (example):
- /path/to/OUT_DIR_NAME/
  - STRINGS_DUMP/
    - strings-full.txt
    - strings-username.txt
    - ...
  - BINWALK_DUMP/
    - binwalk_scan.txt
  - BULK_DUMP/
    - packets.pcap (if found)
    - other bulk_extractor files

## Common issues & quick fixes
- "User is root!...Continuing..." vs "User is not root....Exiting...."  
  Script enforces root; run with sudo or as root.

- "command not found" on constructs like `=memdump.mem` or `$VAR=`:  
  Assignment must be `VAR=value` (no `$` on left side).

- "No such file or directory" when cd-ing into BULK_DUMP:  
  bulk_extractor writes to the directory where it was invoked. Ensure script runs bulk_extractor from the target directory or use absolute paths. Confirm `OUT_DIR_PATH` and `OUT_DIR_NAME` values.

- Want file size stored in a variable:  
  Safe pattern already used in script:
  FILE_LISTING=$(ls -l -- "$NETWORK_FILE")  
  FILE_SIZE_BYTES=$(stat -c%s -- "$NETWORK_FILE" 2>/dev/null || awk '{print $5}' <<< "$FILE_LISTING")

- Avoid piping `cd` into other commands (e.g. `cd dir | ls`) — it doesn't change the working directory for following commands.

## Notes on colors & comments
- Script uses `tput setaf` + `tput sgr0` to color messages (blue info, green success, red errors, cyan details).
- Inline comments are present in the script for clarity.

## Debug tips
- Enable Bash debug to trace variable values:
  set -x
  ./script.sh
  set +x
- Inspect current working dir and variables during run:
  pwd; echo "$OUT_DIR_PATH" "$OUT_DIR_NAME" "$MEM_DUMP"

## License / Disclaimer
For educational / lab use only. Verify legality before analyzing memory images.
