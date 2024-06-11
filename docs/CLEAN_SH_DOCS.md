# Script documentation for clean.sh

## Overview

The `clean.sh` script is designed to clean cache and temporary files for 42 students using Linux/Ubuntu. It helps to free up disk space and maintain system performance by removing unnecessary files from various directories. The script supports various modes including verbose, dry run, interactive, force, and safe modes.

## Index

- [Overview](#overview)
- [Features](#features)
- [How to Use](#how-to-use)
  - [Command-line Options](#command-line-options)
  - [Examples](#examples)
    - [Safe Mode Example](#safe-mode-example)
- [Detailed Explanation of the Script](#detailed-explanation-of-the-script)
  - [Initial Setup](#initial-setup)
  - [Functions](#functions)
- [Adding Custom Paths](#adding-custom-paths)
  - [How to Determine the Process Name of a Path](#how-to-determine-the-process-name-of-a-path)
  - [Using the Process Name in `DEF_PATHS_TO_CLEAN`](#using-the-process-name-in-def_paths_to_clean)
- [Conclusion](#conclusion)

## Features

- Clean cache and temporary files from multiple applications.
- Interactive mode to confirm deletions.
- Dry run mode to simulate the cleaning process without actually deleting any files.
- Verbose mode to display detailed information about deleted files.
- Safe mode to ensure safe operation when force mode is enabled.
- Customizable paths to clean.

## How to Use

### Command-line Options

- `-h` : Display the help message.
- `-v` : Verbose mode. Show files deleted/to delete and their sizes.
- `-n` : Dry run mode. Only show what would be deleted without actually deleting anything. Enables verbose mode.
- `-i` : Interactive mode. Ask for confirmation before deleting each file or directory.
- `-l` : List mode. ONLY list all directories and files to be cleaned without deleting.
- `-f` : Force mode. Delete cache without asking for confirmation of running processes.
- `-s` : Safe mode. Temporarily disables force mode and checks the running processes.
- `-D [mode]` : Set default mode of the script to the provided mode (e.g., `-D v` to enable verbose mode by default).
- `-u [mode]` : Unset default mode of the script for the provided mode (e.g., `-u v` to disable verbose mode by default).
- `-r` : Reset default modes of the script to the original values.

### Examples

- To clean caches in verbose mode:
  
  ```sh
  clean -v
  ```
- To perform a dry run (no files will be deleted):
  
  ```sh
  clean -n
  ```
- To clean caches in interactive mode:
  
  ```sh
  clean -i
  ```
- To list all directories and files to be cleaned without deleting:
  
  ```sh
  clean -l
  ```
- To forcefully clean caches without confirmation:
  
  ```sh
  clean -f
  ```

#### Safe Mode Example
Safe mode is particularly useful if you have set force mode as the default in your configuration file but want to run the script while checking for running processes without having to change the default configuration. This can be achieved by using the -s option.

For example, if you want to run the cleaning script in safe mode to ensure it checks for running processes despite force mode being enabled by default, you can use:
```sh
clean -s
```

This command will temporarily disable force mode and check for running processes, ensuring safe operation for this execution.

## Detailed Explanation of the Script

### Initial Setup
- **Default Paths:** The script starts by declaring an associative array DEF_PATHS_TO_CLEAN that holds the default paths to be cleaned along with their associated process names.

- **Colors and Formatting:** Various color and bold formatting options are set up for better readability of the output.

- **Configuration:** The script initializes several variables and loads default configuration values from clean.conf if it exists.

### Functions

#### Table Format

| Function Name          | Description                                                |
|------------------------|------------------------------------------------------------|
| `update_config_file`   | Updates the configuration file with new default values.    |
| `print_help`           | Displays the help message with usage instructions and options. |
| `get_size_color`       | Determines the color based on the size of the files.       |
| `print_size_color`     | Prints the size in a readable format with color.           |
| `get_storage_usage`    | Gets the storage usage of the home directory in a readable format. |
| `print_storage_usage`  | Prints the storage usage of the home directory.            |
| `get_path_size`        | Gets the size of a given path.                             |
| `print_paths_sorted`   | Sorts and prints an array of paths by their size from biggest to smallest. |
| `sort_paths_by_size`   | Sorts given array of paths by their size from biggest to smallest. |
| `check_running_process`| Checks for running processes and handles them according to user input. |
| `clean_paths`          | Deletes files and folders and calculates the freed space.  |

## Adding Custom Paths
You can add custom paths to the `DEF_PATHS_TO_CLEAN` array in the `clean.sh` script. This allows you to specify additional directories to be cleaned. Here’s how to add a custom path:

1. **Locate the `DEF_PATHS_TO_CLEAN` array:**
  ```sh
  declare -A DEF_PATHS_TO_CLEAN=(
	# (...)
    ["$HOME/.cache"]="none"
    ["$HOME/.var/app/com.google.Chrome/cache/"]="google-chrome"
    # Add more paths here
  )
  ```

1. **Add your custom path(s):**
  ```sh
  declare -A DEF_PATHS_TO_CLEAN=(
	["$HOME/custom/path"]="process-name"
  )
  ```
  - Replace `$HOME/custom/path` with the actual path you want to clean.
  - Replace `process-name` with the name of the process that uses this path. If no specific process is associated, use `"none"`.

### How to Determine the Process Name of a Path

To find the process name associated with a specific path, you can use the `process_name.sh` script included in this project. This script helps identify which processes are accessing files within a specified directory.

For detailed instructions on how to use the `process_name.sh` script, please refer to the [PROCESS_NAME_DOCS.md](PROCESS_NAME_DOCS.md) documentation.

#### Using the Process Name in `DEF_PATHS_TO_CLEAN`

Once you have identified the process name using the `process_name.sh` script, you can add it to the `DEF_PATHS_TO_CLEAN` array in the `clean.sh` script.

Example:

```sh
declare -A DEF_PATHS_TO_CLEAN=(
  ["$HOME/.config/Code/"]="code"
  ["$HOME/.config/google-chrome/Default/Cache"]="chrome"
  # Add more paths here
)
```

By identifying the processes that are actively using specific directories, you can accurately configure `clean.sh` to manage cache and temporary files for a wider range of applications.
