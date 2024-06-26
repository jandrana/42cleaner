# Script Documentation process_name.sh
## Index

- [Overview](#overview)
- [Features](#features)
- [Usage](#usage)
  - [Command-line Arguments](#command-line-arguments)
  - [Examples](#examples)
  - [Importance of Application State](#importance-of-application-state)
- [Path Selection for Better Results](#path-selection-for-better-results)
  - [Good Paths vs. Bad Paths](#good-paths-vs-bad-paths)
  - [Extensive List of Directory Paths](#extensive-list-of-directory-paths)
- [Detailed Script Explanation](#detailed-script-explanation)
- [Conclusion](#conclusion)


## Overview

The `process_name.sh` script, located in the `utils` folder, is designed to identify the process names and their corresponding PIDs that are accessing files within a specified directory. This is particularly useful for enhancing the `clean.sh` script by helping you determine the correct process names for new paths added to the `DEF_PATHS_TO_CLEAN` array. By identifying the processes that are actively using specific directories, you can accurately configure `clean.sh` to manage cache and temporary files for a wider range of applications.

## Features

- Identifies processes accessing files in a specified directory.
- Can use a default directory or a user-provided directory.
- Outputs the PID and command name of the processes.

## Usage

Go to the script location folder (42cleaner/utils by default).

### Command-line Arguments

- If a path is provided as an argument, the script will use that directory.
- If no path is provided, the script will use the default directory specified within the script.

### Examples

- To use the default directory:
  `./process_name.sh`

- To specify a custom directory directly using the command:
  `./process_name.sh /path/to/custom/directory`

### Importance of Application State

- **Running applications:**
  - To successfully identify an specific process name, the application which process name you want to know, **must be running**. If the application is closed, the script is unlikely to find any processes accessing the specified directory.

## Path Selection for Better Results

### Good Paths vs. Bad Paths

Choosing the right directory to monitor significantly impacts the likelihood of correctly identifying the process name. Here's why:

**Application Paths:**

- **Good Path (high chance of success):** `~/.config/Code/` or `~/snap/slack/`
  - This paths include the main configuration directory for the application, which is more likely to be accessed by the main process of the application.
- **Bad Path (low chance of success):** `~/.config/Code/Shared Dictionary/cache` or `~/snap/slack/149/.config/Slack/Cache`
  - This are more specific subdirectories, often used for temporary cache files. The main application process may not frequently access these files directly.

### Extensive list of Directory Paths

To improve the chances of successfully identifying process names for applications, use paths such as these, depending on their directory locations (.config | .var/app | snap):

- **Code**:
  - .config: `~/.config/Code/`
  - snap: `~/snap/code/`

- **Google Chrome**:
  - .config: `~/.config/google-chrome/`
  - .var/app: `~/.var/app/com.google.Chrome/`

- **Firefox**:
  - .config: `~/.mozilla/firefox/`
  - snap: `~/snap/firefox/`

- **Brave Browser**:
  - .config: `~/.config/BraveSoftware/Brave-Browser/`

- **Discord**:
  - .config: `~/.config/discord/`

- **Spotify**:
  - .config: `~/.config/spotify/`
  - snap: `~/snap/spotify/`

- **VLC Media Player**:
  - .config: `~/.config/vlc/`
  - .var/app: `~/.var/app/org.videolan.VLC/`

- **Gnome Terminal**:
  - .config: `~/.config/gnome-terminal/`

- **JetBrains**:
  - .config: `~/.config/JetBrains/`

- **Zoom**:
  - .config: `~/.config/zoom/`
  - snap: `~/snap/zoom/`

- **Skype for Linux**:
  - .config: `~/.config/skypeforlinux/`

- **Slack**:
  - .config: `~/.config/Slack/`
  - snap: `~/snap/slack/`

- **Telegram Desktop**:
  - .config: `~/.config/TelegramDesktop/`

- **Microsoft Teams**:
  - .config: `~/.config/teams/`

- **Obsidian**:
  - snap: `~/snap/obsidian/`

- **GitKraken**:
  - snap: `~/snap/gitkraken/`

- **Chromium**:
  - snap: `~/snap/chromium/`

- **GIMP**:
  - .var/app: `~/.var/app/org.gimp.GIMP/`

- **LibreOffice**:
  - .var/app: `~/.var/app/org.libreoffice.LibreOffice/`

- **FileZilla**:
  - .var/app: `~/.var/app/org.filezillaproject.Filezilla/`


## Detailed Script Explanation

```sh
# 1. Default Directory: Sets a default directory to use.
directory="~/.config/Code/Cache"

# 2. Custom Directory: Allows for a custom directory to be specified as an argument.
if [ $# -gt 0 ]; then
    directory="$1"
fi

# 3. Iterating Over Processes: Iterates over all PIDs in the `/proc` directory.
for pid in $(ls /proc | grep -E '^[0-9]+$'); do
    # 4. Checking File Descriptors: Checks if any file descriptor of the process points to the specified directory.
    if ls /proc/$pid/fd 2>/dev/null | xargs -I {} readlink -f /proc/$pid/fd/{} 2>/dev/null | grep -q "$directory"; then
        # 5. Retrieving Command Name: Retrieves the command name of the process.
        cmd=$(ps -p $pid -o comm=)
        # 6. Printing the Results: Prints the PID and command name.
        echo "$pid $cmd"
    fi
done
```

## Conclusion

The `process_name.sh` script is a useful tool for identifying processes accessing a specific directory. By choosing the appropriate paths and ensuring the target application is running, users can maximize the effectiveness of this script. Use broader application paths rather than specific cache directories to increase the chances of accurately identifying the process names.