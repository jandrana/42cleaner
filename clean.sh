#!/bin/bash

# TODO
# Add interactive mode
# Add option of all paths (extended version of paths to clean)
# Check functionality of -D, -u, -r flags

# Paths to clean
PATHS_TO_CLEAN=(
    # General .cache directory
    "$HOME/.cache"

    # Cache directory for Google Chrome
	"$HOME/.var/app/com.google.Chrome/cache/"
    
    #"$HOME/.cache/google-chrome/Default/Cache"


    ## .CONFIG CACHE ## 
    # Cache directories for Visual Studio Code
    "$HOME/.config/Code/Cache"
    "$HOME/.config/Code/Shared Dictionary/cache"
    "$HOME/.config/Code/WebStorage/5/CacheStorage"
    "$HOME/.config/Code/CachedData"
    
    # Cache directories for GitKraken
    "$HOME/.config/GitKraken/Cache"
    "$HOME/.config/GitKraken/Shared Dictionary/cache"
    
    # Cache directories for Google Chrome
    "$HOME/.config/google-chrome/Default/Shared Dictionary/cache"


    ## SNAP CACHE ##
    # Cache directories for Slack
    "$HOME/snap/slack/common/.cache"
    "$HOME/snap/slack/149/.config/Slack/Cache"
    # Cache directories for Visual Studio Code
    "$HOME/snap/code/common/.cache"

    # Cache directories for Obsidian
    "$HOME/snap/obsidian/common/.cache"

    # Cache directories for GitKraken
    "$HOME/snap/gitkraken/common/.cache"


    ## OTHER ##
    # Temporary files created by francinette when running tests (42)
    "$HOME/francinette/temp"
    # Trash directory
    "$HOME/.local/share/Trash"

    # Test directories
    "$HOME/holas/"
)

declare -A ALL_PATHS_TO_CLEAN=(
    ["$HOME/.cache"]="none"
    ["$HOME/.var/app/com.google.Chrome/cache/"]="google-chrome"
    ["$HOME/.config/Code/Cache"]="code"
    ["$HOME/.config/Code/Shared Dictionary/cache"]="code"
    ["$HOME/.config/Code/WebStorage/5/CacheStorage"]="code"
    ["$HOME/.config/Code/CachedData"]="code"
    ["$HOME/.config/GitKraken/Cache"]="gitkraken"
    ["$HOME/.config/GitKraken/Shared Dictionary/cache"]="gitkraken"
    ["$HOME/.config/google-chrome/Default/Shared Dictionary/cache"]="google-chrome"
    ["$HOME/snap/slack/common/.cache"]="slack"
    ["$HOME/snap/slack/149/.config/Slack/Cache"]="slack"
    ["$HOME/snap/code/common/.cache"]="code"
    ["$HOME/snap/obsidian/common/.cache"]="obsidian"
    ["$HOME/snap/gitkraken/common/.cache"]="gitkraken"
    ["$HOME/francinette/temp"]="none"
    ["$HOME/.local/share/Trash"]="none"
    ["$HOME/holas/"]="none"
)

# Color and bold formats
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

# Initialize variables
total_freed=0
total_skipped=0
verbose=0
dry_run=0
interactive=0
list_only=0
force=0
safe_mode=0
process_size=0
custom_directory=""

# Default configuration values
DEFAULT_VERBOSE=0
DEFAULT_DRY_RUN=0
DEFAULT_INTERACTIVE=0
DEFAULT_FORCE=0
DEFAULT_LIST_ONLY=0

# Load defaults from configuration file if it exists
CONFIG_FILE="$HOME/.config/clean.conf" # ! CHANGE THIS
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    verbose=$DEFAULT_VERBOSE
    dry_run=$DEFAULT_DRY_RUN
    interactive=$DEFAULT_INTERACTIVE
    force=$DEFAULT_FORCE
    list_only=$DEFAULT_LIST_ONLY
fi


### FUNCTIONS ###

# Update configuration file with new default values
update_config_file() {
    echo "DEFAULT_VERBOSE=$DEFAULT_VERBOSE" > "$CONFIG_FILE"
    echo "DEFAULT_DRY_RUN=$DEFAULT_DRY_RUN" >> "$CONFIG_FILE"
    echo "DEFAULT_INTERACTIVE=$DEFAULT_INTERACTIVE" >> "$CONFIG_FILE"
    echo "DEFAULT_FORCE=$DEFAULT_FORCE" >> "$CONFIG_FILE"
    echo "DEFAULT_LIST_ONLY=$DEFAULT_LIST_ONLY" >> "$CONFIG_FILE"
}

# Display help message
print_help() {
    echo -e "${BOLD}NAME${NORMAL}"
    echo -e "\t $0 - clean cache and temporary files"
    echo -e "${BOLD}DESCRIPTION${NORMAL}"
    echo -e "\t Clean cache and temporary files for 42 students with Linux/Ubuntu"
    echo -e "${BOLD}USAGE${NORMAL}"
    echo -e "\t clean [options] // clean.sh [options]"
    echo -e "${BOLD}OPTIONS${NORMAL}"
    echo -e "\t -h \t Display this help message"
    echo -e "\t -v \t Verbose mode: Show files deleted/to delete and their sizes"
    echo -e "\t -n \t Dry run mode: Only show what would be deleted without\n\t\t actually deleting anything. Dry run also enables verbose mode"
    echo -e "\t -i \t Interactive mode: Ask for confirmation before deleting\n\t\t each file or directory"
    echo -e "\t -l \t List mode: ONLY List all directories and files to be\n\t\t cleaned without deleting"
    echo -e "\t -f \t Force mode: Delete cache without asking for confirmation\n\t\t of runnning processes"
    echo -e "\t -s \t Safe mode: When force mode enabled it temporarily\n\t\t disables it and checks the running processes"
    echo -e "\n\t Configuring default modes:"
    echo -e "\t -D \t Set default mode of script to the provided mode\n\t\t (e.g. -D v to enable verbose mode by default)"
    echo -e "\t -u \t Unset default mode of script for the provided mode\n\t\t (e.g. -u v to disable verbose mode by default)"
    echo -e "\t -r \t Reset default modes of script to the original values"
    echo -e "\t\t These configurations are available with the following options:"
    echo -e "\t\t v: Verbose mode | n: Dry run mode | i: Interactive mode\n\t\t f: Force mode | l: List mode"
    echo -e ""
}


get_size_color() {
    local size=$1
    # for files smaller than 1MB
    if [ "$size" -lt $((1024 * 1024)) ]; then
        echo "${BLUE}"
    # for files smaller than 50MB
    elif [ "$size" -lt $((50 * 1024 * 1024)) ]; then
        echo "${GREEN}"
    # for files smaller than 100MB
    elif [ "$size" -lt $((100 * 1024 * 1024)) ]; then
        echo "${RED}"
    # for files bigger than 100MB
    else
        echo "${MAGENTA}"
    fi
}

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

# Function to get the size of a path
get_path_size() {
    local path=$1
    if [ -e "$path" ]; then
        du -sb "$path" | awk '{print $1}'
    else
        echo 0
    fi
}

# Function to sort an array of paths by their size from biggest to smallest
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

# Function to sort an array of paths by their size from biggest to smallest
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
    for path in "${!ALL_PATHS_TO_CLEAN[@]}"; do
        # skip paths that are already marked to be skipped
        if [ "${ALL_PATHS_TO_CLEAN[$path]}" == "skip" ]; then
            continue
        fi
        process="${ALL_PATHS_TO_CLEAN[$path]}"
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
                ALL_PATHS_TO_CLEAN["$path"]="skip"
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
        #if [ "$dry_run" -eq 0 ]; then
            #rm -rf "$path"
        #fi
        total_freed=$((total_freed + path_size_before))

        if [ "$verbose" -eq 1 ] && [ "$path_size_before" -gt 0 ]; then
            echo -e "\t$(print_size_color "$path_size_before")\t$path"
        fi
    fi
}

# Parse command/script flags
while getopts ":hvnilfsD:u:r" opt; do # FIX THIS
    case ${opt} in
        D)
            # Check that -D flag is used exclusively to avoid conflicts
            if (( OPTIND <= $# )); then
                echo -e "${RED}-D flag must be used exclusively.${NORMAL}"
                exit 1
            fi
            DEFAULT_MODE=$OPTARG
            echo -e "${YELLOW}Setting default mode to $DEFAULT_MODE${NORMAL}"
            # Set new defaults based on the provided modes
            if [[ "$DEFAULT_MODE" == *v* ]]; then
                DEFAULT_VERBOSE=1
            fi
            if [[ "$DEFAULT_MODE" == *n* ]]; then
                DEFAULT_DRY_RUN=1
            fi
            if [[ "$DEFAULT_MODE" == *i* ]]; then
                DEFAULT_INTERACTIVE=1
            fi
            if [[ "$DEFAULT_MODE" == *f* ]]; then
                DEFAULT_FORCE=1
            fi
            if [[ "$DEFAULT_MODE" == *l* ]]; then
                DEFAULT_LIST_ONLY=1
            fi
            # Update the configuration file
            update_config_file
            # Exit after setting the new defaults
            exit 0
            ;;
        u)
            # Check that -u flag is used exclusively to avoid conflicts
            if (( OPTIND <= $# )); then
                echo -e "${RED}-u flag must be used exclusively.${NORMAL}"
                exit 1
            fi
            DEFAULT_MODE=$OPTARG
            echo -e "${YELLOW}Unsetting default mode $DEFAULT_MODE${NORMAL}"
            # Unset defaults based on the provided modes
            if [[ "$DEFAULT_MODE" == *v* ]]; then
                DEFAULT_VERBOSE=0
            fi
            if [[ "$DEFAULT_MODE" == *n* ]]; then
                DEFAULT_DRY_RUN=0
            fi
            if [[ "$DEFAULT_MODE" == *i* ]]; then
                DEFAULT_INTERACTIVE=0
            fi
            if [[ "$DEFAULT_MODE" == *f* ]]; then
                DEFAULT_FORCE=0
            fi
            if [[ "$DEFAULT_MODE" == *l* ]]; then
                DEFAULT_LIST_ONLY=0
            fi
            # Update the configuration file
            update_config_file
            # Exit after unsetting the new defaults
            exit 0
            ;;
        r)
            # Check that -r flag is used exclusively to avoid conflicts
            if (( OPTIND <= $# )); then
                echo -e "${RED}-r flag must be used exclusively.${NORMAL}"
                exit 1
            fi
            echo -e "${YELLOW}Resetting default modes to original values${NORMAL}"
            # Reset defaults to original values
            DEFAULT_VERBOSE=0
            DEFAULT_DRY_RUN=0
            DEFAULT_INTERACTIVE=0
            DEFAULT_FORCE=0
            DEFAULT_LIST_ONLY=0
            # Update the configuration file
            update_config_file
            # Exit after resetting the defaults
            exit 0
            ;;
        h)
            print_help
            exit 0
            ;;
        v)
            echo -e "Verbose mode enabled"
            verbose=1
            ;;
        n)
            echo -e "Dry run mode enabled"
            echo -e "Verbose mode enabled"
            echo -e "\n\t\t${RED}${BOLD}WARNING:${NORMAL} THIS IS A SIMULATION MODE"
            echo -e "\t\t\tNO FILES WILL BE DELETED"
            dry_run=1
            verbose=1
            ;;
        i)
            echo -e "Interactive mode enabled"
            interactive=1
            verbose=1
            ;;
        l)
            echo -e "List only mode enabled"
            list_only=1
            dry_run=1 # Check if I can delete this
            ;;
        f)
            echo -e "Force mode enabled"
            force=1
            ;;
        s)
            echo -e "Safe mode enabled"
            safe_mode=1
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
        ALL_PATHS_TO_CLEAN["$path"]="skip"
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
    print_storage_usage
    interactive=0
fi

for path in "${!ALL_PATHS_TO_CLEAN[@]}"; do
    if [ "${ALL_PATHS_TO_CLEAN[$path]}" == "skip" ]; then
        continue
    else
        if [ "$interactive" -eq 1 ] && [ "$list_only" -eq 0 ]; then
            while true; do
                read -p "Do you want to delete: $path for $(print_size_color $(get_path_size "$path"))? (y/n) " yn
                case $yn in
                    [Yy]* ) final_paths_to_clean+=("$path"); break ;;
                    [Nn]* ) ALL_PATHS_TO_CLEAN["$path"]="skip"; break;;
                    * ) echo "Please answer yes or no." ;;
                esac
            done
        else
            final_paths_to_clean+=("$path")
        fi
    fi
done

# Print verbose output if enabled
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

# Sort paths by size
sorted_paths_list=($(sort_paths_by_size "${final_paths_to_clean[@]}"))

for path in "${sorted_paths_list[@]}"; do
    if [ "$list_only" -eq 1 ]; then
        #echo -e "\t$path"
        echo -e "\t$(print_size_color $(get_path_size $path))\t$path"
    else
        clean_paths "$path"
    fi
done

# List skipped paths in verbose mode
sorted_all_paths=($(sort_paths_by_size "${!ALL_PATHS_TO_CLEAN[@]}"))
if [ "$verbose" -eq 1 ]; then
    if [ "$list_only" -eq 1 ]; then
        echo -e "\n\t${BOLD}${MAGENTA}IGNORED PATHS FOR SIZE (< 1KB)${NORMAL}"
    else
        echo -e "\n\t${RED}${BOLD}SIZE\tSKIPPED${NORMAL}"
    fi
    for path in "${sorted_all_paths[@]}"; do
        if [ "${ALL_PATHS_TO_CLEAN[$path]}" == "skip" ]; then
            total_skipped=$((total_skipped + $(get_path_size $path)))
            echo -e "\t$(print_size_color $(get_path_size $path))\t$path"
        fi
    done
    echo -e "\n\t$(get_size_color "$total_skipped")TOTAL SKIPPED: ${BOLD}$(print_size_color "$total_skipped")"
fi

# Convert total freed to readable format
total_freed_read=$(print_size_color "$total_freed")

if [ "$list_only" -eq 0 ]; then
    echo -e "\t$(get_size_color "$total_freed")TOTAL CLEAN: ${BOLD}$total_freed_read\n"
    echo -ne "${RED}${BOLD}BEFORE: ${NORMAL}"
    echo -e "Available space in $HOME: ${BOLD}${before_cleaning}${NORMAL}"
    echo -ne "${GREEN}${BOLD}AFTER:${NORMAL}"
    # Print the current storage available of home directory
    print_storage_usage
fi
echo -e "${NORMAL}"