#!/bin/bash

# TODO
# Add more directories and files to clean (for flag -a)
# Add color variation depending on file size cleaned

# Paths to clean
PATHS_TO_CLEAN=(

    # Cache directory for Google Chrome
	"$HOME/.var/app/com.google.Chrome/cache/"
    
	# General .cache directory
    "$HOME/.cache"
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
    ["$HOME/.var/app/com.google.Chrome/cache/"]="google-chrome"
    ["$HOME/.cache"]="none"
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
    echo -e "\t -n \t Dry run: Only show what would be deleted without actually deleting anything"
    echo -e "\t\t Dry run also enables verbose mode"
    echo -e "\t -l \t ONLY List all directories and files to be cleaned without deleting"
    echo -e ""
}

# Get storage usage of home directory in a readable format
get_storage_usage() {
    df -h "$HOME" | awk 'NR==2 {print $4}'
}

print_storage_usage() {
    echo -e "\tAvailable space in $HOME: ${BOLD}$(get_storage_usage)${NORMAL}"
}

# Check if any of the processes are running
check_running_process() {
    local path=$1
    local process=$2
    local path_size=$(du -sb "$path" | awk '{print $1}')
    if [ "$process" != "none" ] && pgrep -x "$process" > /dev/null; then
        echo -e "\n${BOLD}${RED}Warning:${NORMAL} $process is running.\nIt is recommended to close this application before cleaning its cache.${NORMAL}"
        echo -e "${BOLD}${YELLOW}SIZE\tPATH${NORMAL}"
        echo -e "${YELLOW}$(numfmt --to=iec --suffix=B "$path_size")\t$path${NORMAL}"
        read -p "Do you want to proceed with cleaning cache for $process? (y/n) " yn
        case $yn in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo "Please answer yes or no." ;;
        esac
    fi
    return 0
}

# Initialize variables
total_freed=0
verbose=0
dry_run=0
list_only=0

# Parse command/script flags
while getopts ":hvnl" opt; do
    case ${opt} in
        h)
            print_help
            exit 0
            ;;
        v)
            echo -e "${YELLOW}Verbose mode enabled${NORMAL}"
            verbose=1
            ;;
        n)
            echo -e "${YELLOW}Dry run mode enabled${NORMAL}"
            echo -e "${YELLOW}Verbose mode enabled${NORMAL}"
            dry_run=1
            verbose=1
            ;;
        l)
            echo -e "${YELLOW}List only mode enabled${NORMAL}"
            list_only=1
            dry_run=1
            ;;
        \?)
            echo -e "${RED}Invalid option: -$OPTARG${NORMAL}"
            print_help
            exit 1
            ;;
    esac
done

# Print the current storage available of home directory
if [ "$list_only" -eq 0 ]; then
    echo -ne "\t${RED}${BOLD}BEFORE:${NORMAL}${RED}"
fi
print_storage_usage


# Function to calculate space without deleting any paths
calculate_space() {
    local path=$1
    if [ -e "$path" ]; then
        local path_size_before=$(du -sb "$path" | awk '{print $1}')
        total_freed=$((total_freed + path_size_before))

        if [ "$path_size_before" -gt 0 ]; then
            echo -e "\t${MAGENTA}$(numfmt --to=iec --suffix=B "$path_size_before")\t$path${NORMAL}"
        fi
    fi
}

# Function to delete files and folders and calculate freed space
clean_paths() {
    local path=$1
    if [ -e "$path" ]; then
        local path_size_before=$(du -sb "$path" | awk '{print $1}')
        #if [ "$dry_run" -eq 0 ]; then
        #    rm -rf "$path"
        #fi
        total_freed=$((total_freed + path_size_before))

        if [ "$verbose" -eq 1 ] && [ "$path_size_before" -gt 0 ]; then
            echo -e "\t${MAGENTA}$(numfmt --to=iec --suffix=B "$path_size_before")\t$path${NORMAL}"
        fi
    fi
}

# Function to handle processes that are running and want to be cleaned
handle_process_check() {
    echo -e "\n${YELLOW}${BOLD}Checking for running processes...${NORMAL}"
    for path in "${!ALL_PATHS_TO_CLEAN[@]}"; do
        process="${ALL_PATHS_TO_CLEAN[$path]}"
        if ! check_running_process "$path" "$process"; then
            echo -e "${RED}Skipping cleaning for $path due to running process.${NORMAL}"
            ALL_PATHS_TO_CLEAN["$path"]="skip"
        fi
    done
}

if [ "$list_only" -eq 0 ]; then
    handle_process_check
fi

# Print verbose output if enabled
if [ "$verbose" -eq 1 ]; then
    echo -e "\n${BOLD}${MAGENTA}VERBOSE:${NORMAL}"
    if [ "$dry_run" -eq 1 ]; then
        echo -e "\t${BOLD}${MAGENTA}SPACE\tPATH TO DELETE${NORMAL}"
    else
        echo -e "\t${BOLD}${MAGENTA}FREED\tDELETED${NORMAL}"
    fi
elif [ "$list_only" -eq 1 ]; then
    echo -e "\n${BOLD}${MAGENTA}LIST ONLY:${NORMAL}"
    echo -e "\t${BOLD}${MAGENTA}PATHS TO CLEAN${NORMAL}"
fi

for path in "${!ALL_PATHS_TO_CLEAN[@]}"; do
    if [ "${ALL_PATHS_TO_CLEAN[$path]}" == "skip" ]; then
        continue
    fi
    if [ "$list_only" -eq 1 ]; then
        echo -e "\t$path"
    elif [ "$dry_run" -eq 1 ]; then
        calculate_space "$path"
    else
        clean_paths "$path"
    fi
done

# Convert total freed to readable format
total_freed_read=$(numfmt --to=iec --suffix=B "$total_freed")

if [ "$list_only" -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}After:${NORMAL}${GREEN}"

    # Print total freed space
    if [ "$dry_run" -eq 0 ]; then
        echo -e "\tTotal space freed: ${BOLD}$total_freed_read${NORMAL}${GREEN}"
    else
        echo -e "\tTotal space available to free: ${BOLD}$total_freed_read${NORMAL}${GREEN}"
    fi

    # Print the current storage available of home directory
    print_storage_usage
fi
echo -e "${NORMAL}"