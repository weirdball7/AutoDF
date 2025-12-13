# AutoDF 🔍
![Bash](https://img.shields.io/badge/Built%20with-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey)
![Status](https://img.shields.io/badge/Status-Active-success)

Lightweight Bash wrapper to run quick memory-dump forensic workflows. AutoDF helps automate the common steps of memory-dump examination (strings, binwalk, bulk-extractor, foremost, and a Volatility helper). The script colorizes terminal output and includes inline comments to improve readability and traceability.

📋 Quick highlights
Script enforces running as root (via CHECKROOT).
Prompts for a memory dump path and an output project directory, then moves the memory dump into that project directory (destructive — make a copy if needed).
Runs multiple forensic tools and collects outputs into per-tool directories under the project directory (STRINGS_DUMP, BINWALK_DUMP, BULK_DUMP, FOREMOST_DUMP, VOLATILITY_DUMP).
Generates a REPORT.txt with result summaries and will create a ZIP of outputs using ZIPOUTPUT.
Includes a RESETLAB helper to reinitialize a project directory (useful for labs).
⚙️ Prerequisites
A Linux environment (Debian/Ubuntu recommended). The script uses apt to install missing dependencies.
The script must be run as root (use sudo).
Installed or installable packages:
binwalk
bulk-extractor (invoked in shell as bulk_extractor)
foremost
binutils (provides strings)
figlet (optional — used for banners)
unzip (used by RESETLAB for example archives)
Optional: A local copy of the Volatility standalone Linux binary is included in Volatility_for_Linux/ in this repo — volatility_2.5_linux_x86. The script has a VOLSETUP step that can use this.
Install dependencies (optional manual step):

Note: If you're using a non-Debian distribution, either install the equivalent packages using your distro’s package manager or install the tools manually.

🔒 Important Safety Note
Memory dumps can contain private or sensitive data (passwords, keys, personal data). Always analyze memory images in a controlled, isolated environment, ideally offline or on a designated analysis host. Make a backup copy of the memory dump before allowing a script to move or modify it.

🚀 Usage
Copy or create a working directory and place the memory image in a safe place:

The script will prompt for the memory dump path (absolute/relative).
It will ask for an output project directory name (e.g., my_project).
The script will move the specified memory file into the project directory (this is destructive — use a copy if you want to preserve the original).
It checks for (and offers to install) missing dependencies via apt.
Script workflow: After setup, the script will run per-tool analysis steps and save their results under OUT_DIR/OUT_DIR_NAME (e.g., OUT_DIR_NAME/BINARY_DUMP). When complete, REPORT.txt and a ZIP of the outputs will be created.

🧭 What each tool does
strings (via binutils): extracts printable strings from the memory image. Creates STRINGS_DUMP with textual data.
binwalk: scans for embedded files and filesystem structures; extracts any findings to BINWALK_DUMP.
bulk-extractor: extracts email addresses, credit card numbers, URLs, and other artifacts into BULK_DUMP.
foremost: carves common files (images, documents, etc.) out of the memory image into FOREMOST_DUMP.
Volatility: memory forensics framework (script includes a helper wrapper to use the bundled Volatility binary). Outputs results into VOLATILITY_DUMP.
figlet: used to print banners for readability (optional).
🔁 Script function summary (what happens internally)
CHECKROOT(): Validate script is being run as root. Exits with error otherwise.
GETFILE(): Prompt user to enter memory dump path and output project directory. Moves the file into the output directory if confirmation received.
RESETLAB(): Optionally reinitialize a project directory (cleans previous output and restores a lab environment from included sample resources).
GETTOOLS(): Check installed packages, try to install missing ones using apt.
VOLSETUP(): If a Volatility binary is present locally (e.g., Volatility_for_Linux/volatility_2.5.linux.standalone/volatility_2.5_linux_x86), copy/install it to VOLATILITY_DUMP or ensure it is available on PATH for use by RUNVOL().
RUNSTRINGS(): Run strings on the memory file and place output in STRINGS_DUMP.
RUNBINWALK(): Use binwalk to analyze and extract embedded files; outputs to BINWALK_DUMP.
RUNBULK(): Run bulk_extractor to extract artifacts into BULK_DUMP.
RUNFOREMOST(): Run foremost and store carved files in FOREMOST_DUMP.
RUNVOL(): Run volatility commands to collect system/process information; store results in VOLATILITY_DUMP.
ZIPOUTPUT(): Compress the per-tool output directories into a single .zip file for archival.
📁 Expected Output Directory Structure
After completion, the output directory will contain:

🧪 Example Run (copy-paste)
📁 Expected Output Directory Structure
After completion, the output directory will contain:
Insufficient disk space: Memory analysis can produce large recoveries. Ensure sufficient space before running.
Output not found: Check OUT_DIR_NAME in the working directory for logs and generated output directories.
Network/privilege-specific analyses: Some Volatility plugins require symbol files or knowledge of the OS version. This script provides a convenience wrapper rather than comprehensive OS-specific analysis.
🧾 Report generation details
REPORT.txt summarizes:
Memory file size, path, and timestamp.
Which tools ran, basic result counts (e.g., number of carved files, strings hits, bulk-extractor artifacts).
Location of detailed outputs (per-tool directories).
This is created automatically after the pipeline completes.
🛡️ Security & Ethical use
This script is for research, training, or forensic use only.
Do not run it against systems or memory images you do not own or have explicit permission to analyze.
Always keep backups and work on copies of original memory images.
✅ Contributing
If you’d like to improve AutoDF:

Fork the repository.
Create a branch for your feature/fix.
Add tests or sample memory images (avoid using any real or sensitive images).
Submit a PR with a clear description and steps to reproduce.
📜 License
This README does not force a specific license for your project — add your license file to the repo if you want to publicize one.

Suggested: MIT License (create LICENSE file if needed).
👋 Credits & Acknowledgements
Volatility (Volatility Foundation) — used as the memory analysis engine.
Bulk Extractor — artifact extraction.
Binwalk — embedded file extraction.
Foremost — carving utility.
strings — string extraction (provided by binutils).