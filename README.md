# AutoDF 🔍

![Bash](https://img.shields.io/badge/Built%20with-Bash-4EAA25?logo=gnu-bash&logoColor=white) ![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey) ![Status](https://img.shields.io/badge/Status-Active-success)

Lightweight Bash wrapper to automate quick memory-dump forensic workflows. AutoDF runs common tools (strings, binwalk, bulk_extractor, foremost, Volatility helper), organizes outputs per tool, and produces a concise REPORT.txt plus an outputs.zip archive.

Table of contents
- Quick summary
- Features
- Prerequisites
- Quick start
- Typical output layout
- How it works (high level)
- Notes & safety
- Contributing & license
- Acknowledgements

Quick summary
- Purpose: fast, repeatable memory image triage and artifact extraction for training/research/authorized investigations.
- Intended use: Linux (Debian/Ubuntu recommended), run as root (sudo).

Features
- Prompts for a memory image and a project directory; optionally moves the image into the project folder (destructive — copy first if needed).
- Runs: strings, binwalk, bulk_extractor, foremost, and optional Volatility helper.
- Per-tool output directories, REPORT.txt summary, and outputs.zip archive.
- Optional RESETLAB helper to reinitialize a project workspace.
- Colorized terminal output and inline comments for clarity.

Prerequisites
- Linux environment (Debian/Ubuntu recommended).
- Run with root privileges: sudo.
- Utilities used (script checks and can attempt apt install):
  - binwalk
  - bulk-extractor
  - foremost
  - binutils (strings)
  - figlet (optional)
  - unzip
- Optional: Volatility standalone binary directory (Volatility_for_Linux/) — script can use VOLSETUP to install or reference it.

Quick start
1. Make a safe copy of the memory image (recommended).
2. Run the script as root:
   sudo ./AutoDF.sh
3. Follow prompts:
   - Enter the path to the memory dump.
   - Enter an output project directory name.
   - Confirm whether to move the image into the project.
4. Script behavior:
   - Checks/installs dependencies via apt (prompts before install).
   - Runs the configured tools and saves outputs under the project directory.
   - Generates REPORT.txt and optionally compresses results into outputs.zip.

Example run (interactive)
- Launch:
  sudo ./AutoDF.sh
- Prompts:
  - Enter memory dump path: /path/to/image.dd
  - Enter project directory name: my_project
  - Move image into project? (y/n)

What each tool produces
- STRINGS_DUMP: printable strings from the image.
- BINWALK_DUMP: binwalk scan and any extracted files.
- BULK_DUMP: bulk_extractor artifacts (email, URLs, metadata, potential PII).
- FOREMOST_DUMP: carved files by type (images, docs, etc.).
- VOLATILITY_DUMP: Volatility outputs (requires binary and appropriate symbol files).
- REPORT.txt: summary (file size, timestamps, which tools ran, basic counts).
- outputs.zip: compressed archive of the project outputs.

Typical output layout
OUT_DIR_NAME/
- STRINGS_DUMP/
- BINWALK_DUMP/
- BULK_DUMP/
- FOREMOST_DUMP/
- VOLATILITY_DUMP/
- REPORT.txt
- outputs.zip

How it works (high level)
- CHECKROOT(): verify script runs with root privileges.
- GETFILE(): prompt for the image and project dir; optionally move the image.
- GETTOOLS(): check (and optionally install) required tools.
- VOLSETUP(): prepare bundled Volatility if present.
- RUNSTRINGS(), RUNBINWALK(), RUNBULK(), RUNFOREMOST(), RUNVOL(): execute tools and collect outputs.
- ZIPOUTPUT(): create outputs.zip.
- RESETLAB(): reinitialize a project workspace for repeated labs.

Notes and limitations
- Volatility analysis requires appropriate OS-specific profiles/symbols for deep analysis — AutoDF provides convenience wrappers, not exhaustive OS-specific workflows.
- Some tools (bulk_extractor, foremost) can create very large outputs depending on image size — ensure sufficient disk space.
- The script may attempt apt installs; confirm before allowing package changes.

Important safety note
Memory dumps can contain sensitive information (passwords, keys, PII). Analyze images only in isolated, authorized environments. Always keep an untouched backup before allowing the script to move or modify files.

Contributing
- Fork the repo, create a branch, add changes and tests, and submit a PR with a clear description of changes.
- Do not add real or sensitive memory images to the repository.

Acknowledgements
- Volatility, Bulk Extractor, Binwalk, Foremost, and GNU binutils — thank you for the tools that make automation possible.
- Built as a convenience automation for common memory-dump triage workflows.
