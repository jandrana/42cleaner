#!/bin/bash

# Author: Ana Alejandra Castillejo
# Description: Script to clean cache and temporary files for 42 students with Linux/Ubuntu
# Last Update: 26/06/2024

# List of default paths to clean along with their process name 
declare -A DEF_PATHS_TO_CLEAN=(
    ["$HOME/.cache"]="none"
    ["$HOME/.var/app/com.google.Chrome/cache/"]="chrome"
    ["$HOME/.config/Code/Cache"]="code"
    ["$HOME/.config/Code/Shared Dictionary/cache"]="code"
    ["$HOME/.config/Code/WebStorage/5/CacheStorage"]="code"
    ["$HOME/.config/Code/CachedData"]="code"
    ["$HOME/.config/GitKraken/Cache"]="gitkraken"
    ["$HOME/.config/GitKraken/Shared Dictionary/cache"]="gitkraken"
    ["$HOME/.config/google-chrome/Default/Shared Dictionary/cache"]="chrome"
    ["$HOME/snap/slack/common/.cache"]="slack"
    ["$HOME/snap/slack/149/.config/Slack/Cache"]="slack"
    ["$HOME/snap/code/common/.cache"]="code"
    ["$HOME/snap/obsidian/common/.cache"]="obsidian"
    ["$HOME/snap/gitkraken/common/.cache"]="gitkraken"
    ["$HOME/francinette/temp"]="none"
    ["$HOME/.local/share/Trash"]="none"
    # Add more paths to clean here with the same format use "none" as process name if not needed
)

# Initialize variables
CONFIG_FILE="$HOME/.42cleaner/clean.conf"
total_freed=0
total_skipped=0
verbose=0
dry_run=0
interactive=0
list_only=0
force=0
safe_mode=0
process_size=0

# Default configuration values
DEFAULT_VERBOSE=0
DEFAULT_DRY_RUN=0
DEFAULT_INTERACTIVE=0
DEFAULT_FORCE=0
DEFAULT_LIST_ONLY=0
DEFAULT_COLORS=true

### CONFIGURATION FILE ###
# Update configuration file with new default values
update_config_file() {
    echo "DEFAULT_VERBOSE=$DEFAULT_VERBOSE" > "$CONFIG_FILE"
    echo "DEFAULT_DRY_RUN=$DEFAULT_DRY_RUN" >> "$CONFIG_FILE"
    echo "DEFAULT_INTERACTIVE=$DEFAULT_INTERACTIVE" >> "$CONFIG_FILE"
    echo "DEFAULT_FORCE=$DEFAULT_FORCE" >> "$CONFIG_FILE"
    echo "DEFAULT_LIST_ONLY=$DEFAULT_LIST_ONLY" >> "$CONFIG_FILE"
    echo "DEFAULT_COLORS=$colors" >> "$CONFIG_FILE"
}

# Load defaults from configuration file if it exists or create it with default values
CONFIG_DIR=$(dirname "$CONFIG_FILE")
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
fi
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    verbose=$DEFAULT_VERBOSE
    dry_run=$DEFAULT_DRY_RUN
    interactive=$DEFAULT_INTERACTIVE
    force=$DEFAULT_FORCE
    list_only=$DEFAULT_LIST_ONLY
    colors=$DEFAULT_COLORS
else
    colors=true
    touch "$CONFIG_FILE"
    update_config_file
fi

### FUNCTIONS ###

# Update Script
update_script() {
    local repo_dir=$(find $HOME -type d -name '42cleaner' -print -quit)

    if [ -z "$repo_dir" ]; then
        echo -e "${RED}Repository directory not found in $HOME.${NORMAL}"
        echo -e "Please make sure the repository is cloned and called '42cleaner'."
        exit 1
    fi

    # Navigate to the repository directory
    cd "$repo_dir" || exit

    # Fetch the latest changes from the remote repository (to check if the script is up-to-date)
    git fetch

    # Compare the local and remote hashes and act accordingly
    local local_hash=$(git rev-parse HEAD)
    local remote_hash=$(git rev-parse @{u})
    if [ "$local_hash" == "$remote_hash" ]; then
        echo -e "${GREEN}The script is already up-to-date.${NORMAL}"
    else
        # Pull the latest changes
        git pull origin main

        # Copy the updated script to $HOME
        cp clean.sh $HOME/.42cleaner/clean.sh
        echo -e "${GREEN}Script updated successfully from the repository.${NORMAL}"
    fi
    exit 0
}

# Update color variables value depending on user configuration
update_color_variables() {
    if [ "$colors" == "true" ] || [ "$colors" == "1" ] ; then
        BOLD=$(tput bold)
        NORMAL=$(tput sgr0)
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        BLUE=$(tput setaf 4)
        MAGENTA=$(tput setaf 5)
        CYAN=$(tput setaf 6)
        WHITE=$(tput setaf 7)
    else
        BOLD=""
        NORMAL=""
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        MAGENTA=""
        CYAN=""
        WHITE=""
    fi
}

update_color_variables

# Display help message
print_help() {
    repo_path=$(find $HOME -type d -name '42cleaner' -print -quit)
    echo -e "${BOLD}DESCRIPTION${NORMAL}"
    echo -e "\tThis script cleans cache and temporary files for 42 students using Linux/Ubuntu."
    echo -e "\tIt helps to free up disk space and maintain system performance by removing unnecessary files from various directories."
    echo -e "${BOLD}USAGE${NORMAL}"
    echo -e "\tclean [options]"
    echo -e "${BOLD}OPTIONS${NORMAL}"
    echo -e "\t-h, --help"
    echo -e "\t\tDisplay this help message."
    echo -e "\t-u, --update"
    echo -e "\t\tUpdate the script from the repository."
    echo -e "\t-v, --verbose"
    echo -e "\t\tVerbose mode. Show files deleted/to delete and their sizes."
    echo -e "\t-n, --dry-run"
    echo -e "\t\tDry run mode. Only show what would be deleted without actually deleting anything. Enables verbose mode."
    echo -e "\t-i, --interactive"
    echo -e "\t\tInteractive mode. Ask for confirmation before deleting each file or directory."
    echo -e "\t-l, --list"
    echo -e "\t\tList mode. ONLY list all directories and files to be cleaned without deleting."
    echo -e "\t-f, --force"
    echo -e "\t\tForce mode. Delete cache without asking for confirmation of running processes."
    echo -e "\t-s, --safe"
    echo -e "\t\tSafe mode. Temporarily disables force mode and checks the running processes."
    echo -e "\t-D [mode]"
    echo -e "\t\tSet default mode of the script to the provided mode (e.g., -D v to enable verbose mode by default)."
    echo -e "\t-U [mode]"
    echo -e "\t\tUnset default mode of the script for the provided mode (e.g., -u v to disable verbose mode by default)."
    echo -e "\t-R"
    echo -e "\t\tReset default modes of the script to the original values."
    echo -e "\t--color [${GREEN}true${NORMAL}|${RED}false${NORMAL}]"
    echo -e "\t\tEnable or disable color output. Valid values are \`true\`, \`1\`, \`false\`, \`0\`."
    echo -e "\t--set-default-color [${GREEN}true${NORMAL}|${RED}false${NORMAL}]"
    echo -e "\t\tSet the default color output in the configuration file. Valid values are \`true\`, \`1\`, \`false\`, \`0\`."
    echo -e "${BOLD}CONFIGURATION${NORMAL}"
    echo -e "\tThe script uses a configuration file located at \`$HOME/.42cleaner/clean.conf\` for default settings."
    echo -e "\tYou can modify this file directly to change the default behavior of the script."
    echo -e "\tAlternatively, use the \`-D\`, \`-U\`, \`-R\` and \`--set-default-color\` options to configure defaults from the command line."
    echo -e "${BOLD}MORE HELP${NORMAL}"
    echo -e "\tFor more detailed documentation, please refer to the Documentation files in the repository."
    #  Looking for the repository directory in $HOME and print the path if found
    if [ -z  "$repo_path" ]; then
        echo -e "\tRepository not found locally. You can find the Documentatation files at:"
        echo -e "\t- clean.sh docs: https://github.com/jandrana/42cleaner/blob/main/docs/CLEAN_SH_DOCS.md"
        echo -e "\t- clean.conf docs: https://github.com/jandrana/42cleaner/blob/main/docs/CLEAN_CONF_DOCS.md"
        echo -e "\t- proces_name docs: https://github.com/jandrana/42cleaner/blob/main/docs/PROCESS_NAME_DOCS.md"
    else
        echo -e "\tRepository found at: $repo_path"
        echo -e "\t- clean.sh docs: $repo_path/docs/CLEAN_SH_DOCS.md"
        echo -e "\t- clean.conf docs: $repo_path/docs/CLEAN_CONF_DOCS.md"
        echo -e "\t- proces_name docs: $repo_path/docs/PROCESS_NAME_DOCS.md"
    fi
    echo -e "${BOLD}SEE ALSO${NORMAL}"
    echo -e "\tRefer to \`clean.conf\`, and \`process_name.sh\` as auxiliary files for additional functionalities "
    echo -e "\tYou can find these files inside the /utils folder of the repository."
    
    echo -e "${BOLD}AUTHOR${NORMAL}"
    echo -e "\tDeveloped by: Jandrana"
    echo -e "\t      GitHub: https://github.com/jandrana"
    echo -e "\t     42 user: ana-cast"
    
    echo -e "${BOLD}COPYRIGHT${NORMAL}"
    echo -e "\tThis project is licensed under the MIT License."
}


get_size_color() {
    local size=$1
    # files smaller than 1MB
    if [ "$size" -lt $((1024 * 1024)) ]; then
        echo "${BLUE}"
    # files smaller than 50MB
    elif [ "$size" -lt $((50 * 1024 * 1024)) ]; then
        echo "${GREEN}"
    # files smaller than 100MB
    elif [ "$size" -lt $((100 * 1024 * 1024)) ]; then
        echo "${RED}"
    # files bigger than 100MB
    else
        echo "${MAGENTA}"
    fi
}

# Print given size in a readable format with color
print_size_color() {
    local size=$1
    local size_color=$(get_size_color "$size")
    echo -e "${size_color}$(numfmt --to=iec --suffix=B "$size")${NORMAL}"
}

# Get storage usage of home directory in a readable format
get_storage_usage() {
    df -h "$HOME" | awk 'NR==2 {print $4}'
}

# Print storage usage of home directory
print_storage_usage() {
    echo -e "\tAvailable space in $HOME: ${BOLD}$(get_storage_usage)${NORMAL}"
}

# Function to get the size of a given path
get_path_size() {
    local path=$1
    if [ -e "$path" ]; then
        du -sb "$path" | awk '{print $1}'
    else
        echo 0
    fi
}

# Function to sort and print an array of paths by their size from biggest to smallest
print_paths_sorted() {
    local paths=("$@")
    declare -A path_sizes

    # Calculate sizes of paths
    for path in "${paths[@]}"; do
        path_sizes["$path"]="$(get_path_size "$path")"
    done

    # Sort paths by size
    sorted_paths=($(for path in "${!path_sizes[@]}"; do
        echo "${path_sizes[$path]} $path"
    done | sort -nr | awk '{print $2}'))

    # Print sorted paths with their sizes
    for path in "${sorted_paths[@]}"; do
        echo -e "$(print_size_color $(get_path_size "$path"))\t$path"
    done
}

# Function to return an array after sorting given array of paths by their size from biggest to smallest
sort_paths_by_size() {
    local paths=("$@")
    declare -A path_sizes

    # Calculate sizes of paths
    for path in "${paths[@]}"; do
        path_sizes["$path"]="$(get_path_size "$path")"
    done

    # Sort paths by size
    sorted_paths=($(for path in "${!path_sizes[@]}"; do
        echo "${path_sizes[$path]} $path"
    done | sort -nr | awk '{print $2}'))

    # Return sorted paths
    echo "${sorted_paths[@]}"
}

# Function to handle processes that are running and want to be cleaned
check_running_process() {
    declare -A running_processes
    declare -A process_decision

    echo -e "\n${YELLOW}${BOLD}Checking for running processes...${NORMAL}"
    for path in "${!DEF_PATHS_TO_CLEAN[@]}"; do
        # skip paths that are already marked to be skipped
        if [ "${DEF_PATHS_TO_CLEAN[$path]}" == "skip" ]; then
            continue
        fi
        process="${DEF_PATHS_TO_CLEAN[$path]}"
        if [ "$process" != "none" ] && pgrep -x "$process" > /dev/null; then
            if [ -z "${running_processes[$process]}" ]; then
                running_processes["$process"]="$path"
            else
                running_processes["$process"]+=";$path"
            fi
        fi
    done

    for process in "${!running_processes[@]}"; do
        process_size=0
        if [ -z "${process_decision[$process]}" ]; then
            echo -e "\n${BOLD}${RED}Warning:${NORMAL}${BOLD} $process${NORMAL} is running.\nIt is recommended to close this application before cleaning its cache.${NORMAL}"
            echo -e "${BOLD}SIZE\tPROCESS PATHS${NORMAL}"
            IFS=';' read -ra paths <<< "${running_processes[$process]}"
            print_paths_sorted "${paths[@]}"
            for path in "${paths[@]}"; do
                path_size=$(get_path_size "$path")
                process_size=$((process_size + path_size))
            done
            echo -e "\n$(get_size_color "$process_size")TOTAL $process:${NORMAL}${YELLOW} $(print_size_color "$process_size")\n"
            while true; do
                read -p "Do you want to proceed with cleaning cache for $process? (y/n) " yn
                case $yn in
                    [Yy]* ) process_decision["$process"]="yes"; break ;;
                    [Nn]* ) process_decision["$process"]="no"; break ;;
                    * ) echo "Please answer yes or no." ;;
                esac
            done
        fi
    done

    for process in "${!running_processes[@]}"; do
        if [ "${process_decision[$process]}" == "no" ]; then
            IFS=';' read -ra paths <<< "${running_processes[$process]}"
            for path in "${paths[@]}"; do
                DEF_PATHS_TO_CLEAN["$path"]="skip"
            done
            echo -e "${RED}Skipping cleaning for paths with: $process process${NORMAL}"
        else
            echo -e "${GREEN}Cleaning cache for paths with: $process process${NORMAL}"
        fi
    done
    return 0
}

# Function to delete files and folders and calculate freed space
clean_paths() {
    local path=$1
    if [ -e "$path" ]; then
        local path_size_before=$(get_path_size "$path")
        if [ "$dry_run" -eq 0 ]; then
            rm -rf "$path"
        fi
        total_freed=$((total_freed + path_size_before))

        if [ "$verbose" -eq 1 ] && [ "$path_size_before" -gt 0 ]; then
            echo -e "\t$(print_size_color "$path_size_before")\t$path"
        fi
    fi
}


# Array of options to be passed to getopt
OPTIONS=$(getopt -o hvnilfsD:U:Ru --long help,verbose,dry-run,interactive,list,force,safe,update,color:,set-default-color: -n 'clean' -- "$@")

if [ $? != 0 ]; then
    echo "Failed to parse options." >&2
    exit 1
fi

eval set -- "$OPTIONS"

# Parse command/script flags
while true; do
    case "$1" in
        -D)
            if [ $# -ne 3 ]; then
                echo -e "${RED}$1 flag must be used exclusively.${NORMAL}"
                exit 1
            fi
            DEFAULT_MODE="$2"
            # Set new defaults based on the provided modes
            if [[ "$DEFAULT_MODE" == *v* ]]; then
                DEFAULT_VERBOSE=1
                echo -e "${YELLOW}Setting default mode to verbose ${NORMAL}"
            fi
            if [[ "$DEFAULT_MODE" == *n* ]]; then
                DEFAULT_DRY_RUN=1
                echo -e "${YELLOW}Setting default mode to dry-run ${NORMAL}"
            fi
            if [[ "$DEFAULT_MODE" == *i* ]]; then
                DEFAULT_INTERACTIVE=1
                echo -e "${YELLOW}Setting default mode to interactive ${NORMAL}"
            fi
            if [[ "$DEFAULT_MODE" == *f* ]]; then
                DEFAULT_FORCE=1
                echo -e "${YELLOW}Setting default mode to force ${NORMAL}"
            fi
            if [[ "$DEFAULT_MODE" == *l* ]]; then
                DEFAULT_LIST_ONLY=1
                echo -e "${YELLOW}Setting default mode to list only ${NORMAL}"
            fi
            # Update the configuration file
            update_config_file
            # Exit after setting the new defaults
            exit 0
            ;;
        -U)
            if [ $# -ne 3 ]; then
                echo -e "${RED}$1 flag must be used exclusively.${NORMAL}"
                exit 1
            fi
            DEFAULT_MODE="$2"
            # Unset defaults based on the provided modes
            if [[ "$DEFAULT_MODE" == *v* ]]; then
                DEFAULT_VERBOSE=0
                echo -e "${YELLOW}Unsetting default verbose mode${NORMAL}"
            fi
            if [[ "$DEFAULT_MODE" == *n* ]]; then
                DEFAULT_DRY_RUN=0
                echo -e "${YELLOW}Unsetting default dry-run mode${NORMAL}"
            fi
            if [[ "$DEFAULT_MODE" == *i* ]]; then
                DEFAULT_INTERACTIVE=0
                echo -e "${YELLOW}Unsetting default interactive mode${NORMAL}"
            fi
            if [[ "$DEFAULT_MODE" == *f* ]]; then
                DEFAULT_FORCE=0
                echo -e "${YELLOW}Unsetting default force mode${NORMAL}"
            fi
            if [[ "$DEFAULT_MODE" == *l* ]]; then
                DEFAULT_LIST_ONLY=0
                echo -e "${YELLOW}Unsetting default list only mode${NORMAL}"
            fi
            # Update the configuration file
            update_config_file
            # Exit after unsetting the new defaults
            exit 0
            ;;
        -R)
            if [ $# -ne 2 ]; then
                echo -e "${RED}$1 flag must be used exclusively.${NORMAL}"
                exit 1
            fi
            echo -e "${YELLOW}Resetting default modes to original values${NORMAL}"
            # Reset defaults to original values
            DEFAULT_VERBOSE=0
            DEFAULT_DRY_RUN=0
            DEFAULT_INTERACTIVE=0
            DEFAULT_FORCE=0
            DEFAULT_LIST_ONLY=0
            colors=true
            # Update the configuration file
            update_config_file
            # Exit after resetting the defaults
            exit 0
            ;;
        --color)
            shift
            case "$1" in
                true|1|false|0)
                    colors=$1
                    update_color_variables
                    echo -e "Setting color output to ${GREEN}$1${NORMAL}"
                    shift
                    ;;
                *)
                    echo -e "${RED}Invalid value for --color. Valid values are true, 1, false, 0.${NORMAL}"
                    exit 1
                    ;;
            esac
            ;;
        --set-default-color)
            if [ $# -ne 3 ]; then
                echo -e "${RED}$1 flag must be used exclusively.${NORMAL}"
                exit 1
            fi
            shift
            case "$1" in
                true|1|false|0)
                    colors=$1
                    update_color_variables
                    update_config_file
                    echo -e "Setting default color output to ${GREEN}$1${NORMAL}"
                    shift
                    ;;
                *)
                    echo -e "${RED}Invalid value for --set-default-color. Valid values are true, 1, false, 0.${NORMAL}"
                    exit 1
                    ;;
            esac
            exit 0
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        -u|--update)
            echo -e "Updating script from the repository"
            update_script
            exit 0
            ;;
        -v|--verbose)
            echo -e "Verbose mode enabled"
            verbose=1
            shift
            ;;
        -n|--dry-run)
            echo -e "Dry run mode enabled"
            echo -e "Verbose mode enabled"
            echo -e "\n\t\t${RED}${BOLD}WARNING:${NORMAL} THIS IS A SIMULATION MODE"
            echo -e "\t\t\tNO FILES WILL BE DELETED"
            dry_run=1
            verbose=1
            shift
            ;;
        -i|--interactive)
            echo -e "Interactive mode enabled"
            interactive=1
            verbose=1
            shift
            ;;
        -l|--list)
            echo -e "List only mode enabled"
            list_only=1
            dry_run=1
            shift
            ;;
        -f|--force)
            echo -e "Force mode enabled"
            force=1
            shift
            ;;
        -s|--safe)
            echo -e "Safe mode enabled"
            safe_mode=1
            shift
            ;;
        --)
            shift
            break
            ;;
        \?)
            echo -e "${RED}Invalid option: -$OPTARG${NORMAL}"
            print_help
            exit 1
            ;;
    esac
done

# Ensure that safe mode overrides force mode when enabled
if [ "$safe_mode" -eq 1 ]; then
    force=0
fi

# Skip cleaning of paths that are less than 1KB
for path in "${PATHS_TO_CLEAN[@]}"; do
    if [ $(get_path_size "$path") -lt $((1024)) ]; then
        DEF_PATHS_TO_CLEAN["$path"]="skip"
    fi
done

# Print the current storage available of home directory
if [ "$list_only" -eq 0 ]; then
    before_cleaning=$(get_storage_usage)
    if [ "$force" -eq 0 ]; then
        check_running_process
    fi
    echo -e "\nSTARTING CLEANING PROCESS"
else
    interactive=0
fi

# Create an array of the final paths to clean (excluding the ones marked as "skip")
# If interactive mode is enabled
#  - Ask for confirmation before adding path to final_paths (want to delete?)
#  - Yes: add path to the final paths to clean
#  - No: mark path as "skip" in DEF_PATHS_TO_CLEAN
for path in "${!DEF_PATHS_TO_CLEAN[@]}"; do
    if [ "${DEF_PATHS_TO_CLEAN[$path]}" == "skip" ]; then
        continue
    else
        if [ "$interactive" -eq 1 ] && [ "$list_only" -eq 0 ]; then
            while true; do
                read -p "Do you want to delete: $path for $(print_size_color $(get_path_size "$path"))? (y/n) " yn
                case $yn in
                    [Yy]* ) final_paths_to_clean+=("$path"); break ;;
                    [Nn]* ) DEF_PATHS_TO_CLEAN["$path"]="skip"; break;;
                    * ) echo "Please answer yes or no." ;;
                esac
            done
        else
            final_paths_to_clean+=("$path")
        fi
    fi
done

# Print heading line before printing paths in verbose and list only mode
if [ "$verbose" -eq 1 ]; then
    echo -e "\n${BOLD}${MAGENTA}VERBOSE:${NORMAL}"
    if [ "$dry_run" -eq 1 ]; then
        echo -e "\t${BOLD}${MAGENTA}SIZE\tPATH TO DELETE${NORMAL}"
    else
        echo -e "\t${BOLD}${MAGENTA}FREED\tDELETED${NORMAL}"
    fi
elif [ "$list_only" -eq 1 ]; then
    echo -e "\n${BOLD}${MAGENTA}LIST ONLY:${NORMAL}"
    echo -e "\t${BOLD}${MAGENTA}PATHS TO CLEAN${NORMAL}"
fi

# Sort final_paths by size
sorted_paths_list=($(sort_paths_by_size "${final_paths_to_clean[@]}"))

# Clean paths in sorted order or list in list_only mode
for path in "${sorted_paths_list[@]}"; do
    if [ "$list_only" -eq 1 ]; then
        echo -e "\t$(print_size_color $(get_path_size $path))\t$path"
    else
        clean_paths "$path"
    fi
done

# List skipped (not cleaned) paths in verbose mode + total size of skipped paths
# Skipped paths are those that have been marked as "skip":
# - User decision:
#   - Paths that had a process running and user chose not to clean
#   - Paths that user chose not to clean in interactive mode
# - Paths that which size is less than 1KB
sorted_all_paths=($(sort_paths_by_size "${!DEF_PATHS_TO_CLEAN[@]}"))
if [ "$verbose" -eq 1 ]; then
    if [ "$list_only" -eq 1 ]; then
        echo -e "\n\t${BOLD}${MAGENTA}IGNORED PATHS FOR SIZE (< 1KB)${NORMAL}"
    else
        echo -e "\n\t${RED}${BOLD}SIZE\tSKIPPED${NORMAL}"
    fi
    for path in "${sorted_all_paths[@]}"; do
        if [ "${DEF_PATHS_TO_CLEAN[$path]}" == "skip" ]; then
            total_skipped=$((total_skipped + $(get_path_size $path)))
            echo -e "\t$(print_size_color $(get_path_size $path))\t$path"
        fi
    done
    echo -e "\n\t$(get_size_color "$total_skipped")TOTAL SKIPPED: ${BOLD}$(print_size_color "$total_skipped")"
fi

# Convert total freed to readable format
total_freed_read=$(print_size_color "$total_freed")

# Print total freed space and home storage available before/after cleaning
if [ "$list_only" -eq 0 ]; then
    echo -e "\t$(get_size_color "$total_freed")TOTAL CLEAN: ${BOLD}$total_freed_read\n"
    echo -ne "${RED}${BOLD}BEFORE: ${NORMAL}"
    echo -e "Available space in $HOME: ${BOLD}${before_cleaning}${NORMAL}"
    echo -ne "${GREEN}${BOLD}AFTER:${NORMAL}"
    print_storage_usage
else
    echo -e "\n $(print_storage_usage)"
fi
echo -e "${NORMAL}"