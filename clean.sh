#!/bin/bash

# Author: Ana Alejandra Castillejo
# Description: Script to clean cache and temporary files for 42 students with Linux/Ubuntu
# Last Update: 26/08/2024

# List of default paths to clean along with their process name 
declare -A DEF_PATHS_TO_CLEAN=(
    ["$HOME/.cache"]="none"
    ["$HOME/.var/app/com.google.Chrome/cache/"]="chrome"
    ["$HOME/.config/Code/Cache"]="code"
    ["$HOME/.config/Code/WebStorage/5/CacheStorage"]="code"
    ["$HOME/.config/Code/CachedData"]="code"
    ["$HOME/.config/GitKraken/Cache"]="gitkraken"
    ["$HOME/snap/slack/common/.cache"]="slack"
    ["$HOME/snap/slack/149/.config/Slack/Cache"]="slack"
    ["$HOME/snap/slack/153/.config/Slack/Cache"]="slack"
    ["$HOME/snap/slack/155/.config/Slack/Cache"]="slack"
    ["$HOME/snap/slack/158/.config/Slack/Cache"]="slack"
    ["$HOME/snap/slack/149/.config/Slack/Service\ Worker/CacheStorage"]="slack"
    ["$HOME/snap/slack/155/.config/Slack/Service\ Worker/CacheStorage"]="slack"
    [$HOME/snap/slack/153/.config/Slack/Service\ Worker/CacheStorage]="slack"
    ["$HOME/snap/slack/158/.config/Slack/Service Worker/CacheStorage"]="slack"
    ["$HOME/snap/code/common/.cache"]="code"
    ["$HOME/snap/obsidian/common/.cache"]="obsidian"
    ["$HOME/snap/gitkraken/common/.cache"]="gitkraken"
    ["$HOME/francinette/temp"]="none"
    ["$HOME/.local/share/Trash"]="none"
    # Add more paths to clean here with the same format use "none" as process name if not needed
)

# ---------------- INIT VARIABLES ---------------- #

CONFIG_FILE="$HOME/.42cleaner/clean.conf"
COLOR_FILE="$HOME/.42cleaner/colors.bash"

# Space usage variables
total_freed=0
total_skipped=0
process_size=0

# Flags/mode variables
safe_mode=1
verbose=0
dry_run=0
interactive=0
list_only=0
force=0
colors=true

# At the end, stays to 1 if there is at least one path != skip/empty
need_clean=0

# Default configuration values
DEFAULT_SAFE=1 # fixme reconsider this default value (makes -f not work) or delete condition where -s --> force=0
DEFAULT_VERBOSE=0
DEFAULT_DRY_RUN=0
DEFAULT_INTERACTIVE=0
DEFAULT_FORCE=0
DEFAULT_LIST_ONLY=0
DEFAULT_COLORS=true

# SOURCE FILES

if [ -f "$COLOR_FILE" ]; then
	source "colors.bash"
# else
#     echo -e "ERROR: Could not find $COLOR_FILE file"
#     exit 1
fi

# shellcheck source="$HOME/.42cleaner/clean.conf"
if [ -f "$CONFIG_FILE" ]; then
	source "$CONFIG_FILE"
fi

# ----------------------------------------------- #
#                    FUNCTIONS                    #
# ----------------------------------------------- #

# ---------------- CONFIGURATION FILE ---------------- #

# Update file with default configuration variables values
update_config_file() {
	local append_conf
	local var_name

    echo "DEFAULT_SAFE=$DEFAULT_SAFE" > "$CONFIG_FILE"
    append_conf=("VERBOSE" "DRY_RUN" "INTERACTIVE" "FORCE" "LIST_ONLY" "COLORS")
    for var in "${append_conf[@]}"; do
        var_name="DEFAULT_$var"
        echo "$var_name=${!var_name}" >> "$CONFIG_FILE"
    done
}

# Load defaults from configuration file if it exists or create it with default values
CONFIG_DIR=$(dirname "$CONFIG_FILE")
mkdir -p "$CONFIG_DIR"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    safe_mode=$DEFAULT_SAFE
    verbose=$DEFAULT_VERBOSE
    dry_run=$DEFAULT_DRY_RUN
    interactive=$DEFAULT_INTERACTIVE
    force=$DEFAULT_FORCE
    list_only=$DEFAULT_LIST_ONLY
    colors=$DEFAULT_COLORS
else
    touch "$CONFIG_FILE"
    update_config_file
fi

# ---------------- ERROR HANDLER ---------------- #

put_error() {
    local type="UNEXPECTED"
    local name="$2"
    local arg="$3"
    local err_msg

    if [[ -n $1 ]]; then type="$1"; fi
    err_msg="${ERROR}$type ERROR${NC}"

    if [[ $type != "UNEXPECTED" ]]; then
        if [[ $name == "EXC_FLAG" ]]; then
            err_msg+=": Too many arguments for exclusive flag"
        elif [[ $name == "REP_NOTFOUND" ]]; then
            err_msg+=": Repository directory not found at $HOME"
            err_msg+="\nPlease make sure the repository is correctly cloned and called '42cleaner'."
        else
            err_msg+=": Unexpected error $name"
        fi
    fi
    if [[ -n $arg ]]; then err_msg+=" \`$arg\`"; fi

    echo -e "$err_msg"
    exit 1;
}

# ---------------- UPDATE FUNCTIONS ---------------- #

update_script() {
	local repo_dir
	local local_hash
	local remote_hash

	repo_dir=$(find "$HOME" -type d -name '42cleaner' -print -quit)

	if [ -z "$repo_dir" ]; then put_error "UPDATE" "REP_NOTFOUND"; fi
	cd "$repo_dir" || exit
	git fetch

	# Compare the local and remote hashes (check if is up-to-date)
	local_hash=$(git rev-parse HEAD)
	remote_hash=$(git rev-parse @{u})
	if [ "$local_hash" == "$remote_hash" ]; then
		echo -e "${GREEN}The script is already up-to-date.${NC}"
	else
		git pull origin main
		cp clean.sh "$HOME"/.42cleaner/clean.sh
		echo -e "${GREEN}Script updated successfully from the repository.${NC}"
	fi
}

auto_update_script() {
	local repo_dir
	local local_hash
	local remote_hash

	repo_dir=$(find "$HOME" -type d -name '42cleaner' -print -quit)

	if [ -z "$repo_dir" ]; then put_error "UPDATE" "REP_NOTFOUND"; fi
	cd "$repo_dir" || exit
	git fetch

	# Compare the local and remote hashes (check if is up-to-date)
	local_hash=$(git rev-parse HEAD)
	remote_hash=$(git rev-parse @{u})
	if [ "$local_hash" != "$remote_hash" ]; then
		echo -e "A new version of the script has been found"
		read -r -p "Do you want to update the script? $proc_msg (y/n) " yn
			case $yn in
				[Yy]* ) update_script; exit 0;;
			esac
	fi
}

auto_update_script

# Update color variables value depending on user configuration
update_color_variables() {
	if [ "$colors" == "true" ] || [ "$colors" == "1" ] && [[ -t 1 ]] && [ -f "$COLOR_FILE" ]; then
		activate_color
	else
		colors=false
	fi
}

update_color_variables

# ---------------- HELP MESSAGE FUNCTIONS ---------------- #
# Functions for displaying help message (option -h/--help)

# Print usage example depending on if there is an existing alias or not
print_usage() {
	alias_name=$($SHELL -ic alias | grep "='\$HOME/.42cleaner/clean.sh" | awk -F'=' '{print $1}' )
	if [ -z "$alias_name" ]; then
		echo "./clean.sh"
	else
		echo "$alias_name"
	fi
}

print_help() {
	repo_path=$(find "$HOME" -type d -name '42cleaner' | sort | awk 'NR==1{print}')
	clean_cmd=$(print_usage)
	echo -e "${BOLD}DESCRIPTION${NC}"
	echo -e "\tThis script cleans cache and temporary files in Linux/Ubuntu"
	echo -e "\tIt helps to free up disk space and maintain system performance"
	echo -e "${BOLD}USAGE${NC}"
	echo -e "\t $clean_cmd [options]"
	echo -e "${BOLD}OPTIONS${NC}"
	echo -e "\t-h, --help"
	echo -e "\t\tDisplay this help message."
	echo -e "\t-u, --update"
	echo -e "\t\tForces script update from the repository."
	echo -e "\t-v, --verbose"
	echo -e "\t\tVerbose mode."
	echo -e "\t\tShow files deleted/to delete and their sizes."
	echo -e "\t-n, --dry-run"
	echo -e "\t\tDry run mode (Also enables verbose mode)"
	echo -e "\t\tOnly show what would be deleted without actually deleting anything."
	echo -e "\t-i, --interactive"
	echo -e "\t\tInteractive mode."
	echo -e "\t\tAsk for confirmation before deleting each file or directory."
	echo -e "\t-l, --list"
	echo -e "\t\tList mode."
	echo -e "\t\tONLY list all directories and files to be cleaned without deleting."
	echo -e "\t-f, --force"
	echo -e "\t\tForce mode."
	echo -e "\t\tDelete cache without asking for confirmation of running processes."
	echo -e "\t-s, --safe"
	echo -e "\t\tSafe mode."
	echo -e "\t\tTemporarily disables force mode and checks the running processes."
	echo -e "\t-D [mode]"
	echo -e "\t\tSet default mode of the script to the provided mode"
	echo -e "\t\tExample: '$clean_cmd -D v' enables verbose mode by default"
	echo -e "\t-U [mode]"
	echo -e "\t\tUnset default mode of the script for the provided mode"
	echo -e "\t\tExample: '$clean_cmd -u v' to disable verbose mode by default"
	echo -e "\t-R"
	echo -e "\t\tReset default modes of the script to the original values."
	echo -e "\t--color [${GREEN}true${NC}|${RED}false${NC}]"
	echo -e "\t\tEnable or disable color output."
	echo -e "\t\tValid values are \`true\`, \`1\`, \`false\`, \`0\`."
	echo -e "\t--set-default-color [${GREEN}true${NC}|${RED}false${NC}]"
	echo -e "\t\tSet the default color output in the configuration file."
	echo -e "\t\tValid values are \`true\`, \`1\`, \`false\`, \`0\`."
	echo -e "${BOLD}CONFIGURATION${NC}"
	echo -e "\tConfiguration file for modifying the default behaviour of the script"
	echo -e "\tFile location: \`$HOME/.42cleaner/clean.conf\`."
	echo -e "\tIn order to modify it you can:"
	echo -e "\t\t1. Manually modify the file directly"
	echo -e "\t\t2. Use the following options of $clean_cmd in the command line:"
	echo -e "\t\t  \`-D\`, \`-U\`, \`-R\` and \`--set-default-color\`"
	echo -e "\t\tThey allow to change behaviour from the command line."
	echo -e "${BOLD}MORE HELP${NC}"
	echo -e "\tFor more information, please refer to the project's Documentation at:"
	#  Looking for the repository directory in $HOME and print the path if found
	if [ -z  "$repo_path" ]; then
		echo -e "\tRepository not found locally. You can find the Documentation files online"
	else
		echo -e "\tLocally: $repo_path/docs/"
	fi
	echo -e "\tOnline: https://github.com/jandrana/42cleaner/blob/main/docs"
	echo -e "${BOLD}SEE ALSO${NC}"
	echo -e "\tThe /utils folder contains auxiliary files with additional functionalities."
	echo -e "\tFiles: \`clean.conf\`, \`process_name.sh\` and \`find_cache.sh\`"
	echo -e "\tFor more details, refer to their specific documentation at /docs"

	echo -e "${BOLD}AUTHOR${NC}"
	echo -e "\tDeveloped by: Jandrana"
	echo -e "\t      GitHub: https://github.com/jandrana"
	echo -e "\t     42 user: ana-cast"

	echo -e "${BOLD}COPYRIGHT${NC}"
	echo -e "\tThis project is licensed under the MIT License."
}

# ---------------- STORAGE/SIZE RELATED FUNCTIONS ---------------- #

# Calculate color output depending on given number of bytes (size)
get_size_color() {
	local size=$1
	if [ "$size" -lt $((1024 * 1024)) ]; then # < 1MB
		echo "${BLUE}"
	elif [ "$size" -lt $((50 * 1024 * 1024)) ]; then # 1MB-50MB
		echo "${GREEN}"
	elif [ "$size" -lt $((100 * 1024 * 1024)) ]; then # 50MB-100MB
		echo "${RED}"
	else # > 100MB
		echo "${MAGENTA}"
	fi
}

# Print given size in a readable format with color
print_size_color() {
	local size=$1
	local size_color

	size_color=$(get_size_color "$size")
	echo -e "${size_color}$(numfmt --to=iec --suffix=B "$size")${NC}"
}

print_size() {
	local size=$1
	echo -e "${BOLD}$(numfmt --to=iec --suffix=B "$size")${NC}"
}

# Get storage usage of home directory in a readable format
get_storage_usage() {
	df -h "$HOME" | awk 'NR==2 {print $4}'
}

# Print storage usage of home directory
print_storage_usage() {
	echo -e "\tAvailable space in $HOME: ${BOLD}$(get_storage_usage)${NC}"
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
	local indent="$1"
	shift
	local paths=("$@")
	local sorted

	# Print sorted paths with their sizes
	mapfile -t sorted < <(sort_paths_by_size "${paths[@]}")
	for path in "${sorted[@]}"; do
		echo -e "$indent$(print_size "$(get_path_size "$path")")\t$path"
	done
}

# Function to return an array after sorting given array of paths by their size from biggest to smallest
sort_paths_by_size() {
    local paths=("$@")
    local sorted_paths
    declare -A path_sizes

    # Calculate sizes of paths
    for path in "${paths[@]}"; do
        path_sizes["$path"]="$(get_path_size "$path")"
    done

    # Sort paths by size and handle spaces correctly
    while IFS= read -r line; do
        sorted_paths+=("$line")
    done < <(for path in "${!path_sizes[@]}"; do
        echo "${path_sizes[$path]}:$path"
    done | sort -t: -nrk1 | cut -d: -f2-)

    # Return sorted paths
    printf "%s\n" "${sorted_paths[@]}"
}


get_process_decision() {
	local proc_msg
	if [[ ${#running_processes[@]} != 0 ]]; then
		echo -en "${WARNING}SAFE MODE:${NC}"
		echo -e " It is recommended to close ${WARNING}${!running_processes[*]}${NC} before cleaning cache"
	fi
	for process in "${!running_processes[@]}"; do
		process_size=0
		if [ -z "${process_decision[$process]}" ]; then
			echo -e "${WARNING}   - $process${NC}${NC} is running: It is recommended to close it before cleaning its cache.${NC}"
			IFS=';' read -ra paths <<< "${running_processes[$process]}"
			for path in "${paths[@]}"; do
				path_size=$(get_path_size "$path")
				process_size=$((process_size + path_size))
			done
			# echo -e "\t${BOLD}SIZE\tPROCESS PATHS"
			print_paths_sorted "\t" "${paths[@]}"
			proc_msg="(${BOLD}TOTAL${NC}=$(print_size_color "$process_size"))"
			while true; do
				read -r -p "	Do you want to delete paths related to ${BOLD}$process${NC}? $proc_msg (y/n) " yn
				case $yn in
					[Yy]* ) process_decision["$process"]="yes"; break ;;
					[Nn]* ) process_decision["$process"]="no"; break ;;
					* ) echo "Please answer yes or no." ;;
				esac
			done
		fi
	done
}

assign_process_decision() {
	local skipping
	local cleaning
	for process in "${!running_processes[@]}"; do
		if [ "${process_decision[$process]}" == "no" ]; then
			IFS=';' read -ra paths <<< "${running_processes[$process]}"
			for path in "${paths[@]}"; do
				DEF_PATHS_TO_CLEAN["$path"]="skip"
			done
			skipping+="$process "
		else
			IFS=';' read -ra paths <<< "${running_processes[$process]}"
			for path in "${paths[@]}"; do
				DEF_PATHS_TO_CLEAN["$path"]="delete"
			done
			cleaning+="$process "
		fi
	done
	if [[ ${#running_processes[@]} != 0 ]]; then
		echo -en "${BORANGE}SUMMARY: ${NC}"
		if [[ -n $skipping ]]; then
			echo -en "Skipping ${RED}$skipping${NC}"
		fi
		if [[ -n $cleaning ]]; then
			echo -en "Cleaning ${GREEN}$cleaning${NC}"
		fi
		echo -e "\n"
	fi
}

# Function to handle processes that are running and want to be cleaned
check_running_process() {
	declare -A process_decision
	declare -A running_processes

	for path in "${!DEF_PATHS_TO_CLEAN[@]}"; do
		if [ "${DEF_PATHS_TO_CLEAN[$path]}" == "skip" ] || [ "${DEF_PATHS_TO_CLEAN[$path]}" == "empty" ]; then
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
	get_process_decision
	assign_process_decision
	return 0
}

# Function to delete files and folders and calculate freed space
clean_paths() {
	local path=$1
	local path_size_before

	if [ -e "$path" ]; then
		path_size_before=$(get_path_size "$path")
		if [ "$dry_run" -eq 0 ]; then
			rm -rf "$path"
		fi
		total_freed=$((total_freed + $path_size_before))

		if [ "$verbose" -eq 1 ] && [ "$path_size_before" -gt 0 ]; then
			echo -e "\t$(print_size_color "$path_size_before")\t$path"
		fi
	fi
}

put_new_default() {
    local mode=$1
    local opt="set"
    if [ "$2" -eq 0 ]; then
        opt="unset"
    fi
    echo -en "${ORANGE}Default mode"
    if [[ "$mode" == *\ * ]]; then
        echo -en "s"
    fi
    echo -e " $opt to:$mode"
}

# Array of options to be passed to getopt

SHORT_OPTIONS='hvnilfsD:U:Ru'
LONG_OPTIONS='help,verbose,dry-run,interactive,list,force,safe,update,color:,set-default-color:'

# getopt reported failure
if ! OPTIONS=$(getopt -o $SHORT_OPTIONS --long $LONG_OPTIONS -n "${ERROR}USAGE ERROR${NC}" -- "$@"); then
    echo -e "Try '$(basename "$0") --help' for more information." 1>&2
    exit 1
fi

eval set -- "$OPTIONS"

# Parse command/script flags
while true; do
    case "$1" in
        -D|-U)
            if [ $# -ne 3 ]; then
                put_error "USAGE" "EXC_FLAG" "$1"
            fi

            if [[ $1 == "-D" ]]; then
                DEFAULT_VALUE=1
            else
                DEFAULT_VALUE=0
            fi
            # Set new defaults based on the provided modes
            message=${NC};
            if [[ "$2" == *s* ]]; then DEFAULT_SAFE=$DEFAULT_VALUE; message+="\n - Safe"; fi
            if [[ "$2" == *v* ]]; then DEFAULT_VERBOSE=$DEFAULT_VALUE; message+="\n - Verbose"; fi
            if [[ "$2" == *n* ]]; then DEFAULT_DRY_RUN=$DEFAULT_VALUE; message+="\n - Dry-run"; fi
            if [[ "$2" == *i* ]]; then DEFAULT_INTERACTIVE=$DEFAULT_VALUE; message+="\n - Interactive"; fi
            if [[ "$2" == *f* ]]; then DEFAULT_FORCE=$DEFAULT_VALUE; message+="\n - Force"; fi
            if [[ "$2" == *l* ]]; then DEFAULT_LIST_ONLY=$DEFAULT_VALUE; message+="\n - List-only"; fi

            if [[ $message != "${NC}" ]]; then put_new_default "$message" $DEFAULT_VALUE;
            else echo -e "${WARNING}INFO:${NC} No valid modes provided, no changes made"; fi

            update_config_file
            exit 0
            ;;
        -R)
            if [ $# -ne 2 ]; then
                put_error "USAGE" "EXC_FLAG" "$1"
            fi
            echo -e "${ORANGE}Resetting default modes to original values${NC}"
            DEFAULT_SAFE=1
            DEFAULT_VERBOSE=0
            DEFAULT_DRY_RUN=0
            DEFAULT_INTERACTIVE=0
            DEFAULT_FORCE=0
            DEFAULT_LIST_ONLY=0
            DEFAULT_COLORS=true

            update_config_file
            exit 0
            ;;
        --color)
            shift
            case "$1" in
                true|1|false|0)
                    colors=$1
                    update_color_variables
                    echo -e "Setting color output to ${GREEN}$1${NC}"
                    shift
                    ;;
                *)
                    echo -e "${RED}Invalid value for --color. Expected: true, 1, false, 0.${NC}"
                    exit 1
                    ;;
            esac
            ;;
        --set-default-color)
            if [ $# -ne 3 ]; then
                echo -e "${RED}$1 flag must be used exclusively.${NC}"
                exit 1
            fi
            shift
            case "$1" in
                true|1|false|0)
                    colors=$1
                    update_color_variables
                    update_config_file
                    echo -e "Setting default color output to ${GREEN}$1${NC}"
                    shift
                    ;;
                *)
                    echo -e "${RED}Invalid value for --set-default-color. Valid values are true, 1, false, 0.${NC}"
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
            verbose=1
            shift
            ;;
        -n|--dry-run)
            dry_run=1
            shift
            ;;
        -i|--interactive)
            interactive=1
            verbose=1
            shift
            ;;
        -l|--list)
            list_only=1
            dry_run=1
            shift
            ;;
        -f|--force)
            force=1
            shift
            ;;
        -s|--safe)
            safe_mode=1
            shift
            ;;
        --)
            shift
            break
            ;;
        \?)
            echo -e "${ERROR}USAGE ERROR${NC}: invalid option -- $OPTARG"
            echo -e "Try '$(basename "$0") --help' for more information." 1>&2
            exit 1
            ;;
    esac
done

check_valid_paths() {
    local empty=1
    if [[ ${#DEF_PATHS_TO_CLEAN[@]} -ne 0 ]]; then
        for path in "${!DEF_PATHS_TO_CLEAN[@]}"; do
            if [[ ! -e $path ]] || [ "$(get_path_size "$path")" -lt $((1024 * 1024)) ]; then
                DEF_PATHS_TO_CLEAN["$path"]="empty"
            else
                empty=0
            fi
        done
    fi
    if [[ $empty -eq 1 ]]; then
        echo -e "${NOTE}NOTE:${NC} No paths found for cleaning\n"
    fi
}

check_valid_paths

# Ensure that safe mode overrides force mode when enabled
if [ "$safe_mode" -eq 1 ]; then
    force=0
fi

if [ "$dry_run" -eq 1 ] && [ "$list_only" -eq 0 ]; then
    verbose=1
    echo -e "${BRED}DRY-RUN:${NC} SIMULATION MODE ACTIVE. NO FILES WILL BE DELETED${RESET}\n"
fi

# Print the current storage available of home directory
if [ "$list_only" -eq 0 ]; then
    before_cleaning=$(get_storage_usage)
    if [ "$force" -eq 0 ]; then
        check_running_process
    fi
else
    interactive=0
fi

# Create an array of the final paths to clean (excluding the ones marked as "skip")
# If interactive mode is enabled
#  - Ask for confirmation before adding path to final_paths (want to delete?)
#  - Yes: add path to the final paths to clean
#  - No: mark path as "skip" in DEF_PATHS_TO_CLEAN
if [ $interactive -eq 1 ]; then
	echo -e "${NOTE}INTERACTIVE MODE:${NC} Please indicate which paths you want to delete:"
fi
for path in "${!DEF_PATHS_TO_CLEAN[@]}"; do
    if [ "${DEF_PATHS_TO_CLEAN[$path]}" == "skip" ] || [ "${DEF_PATHS_TO_CLEAN[$path]}" == "empty" ]; then
        continue
    else
        if [ "$interactive" -eq 1 ] && [ "${DEF_PATHS_TO_CLEAN[$path]}" != "delete" ]; then
            while true; do
				echo -en "\t"
                read -r -p "Delete $path for $(print_size_color "$(get_path_size "$path")")? (y/n) " yn
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
if [ $interactive -eq 1 ]; then
	echo -e ""
fi

# Use mapfile to correctly read paths with spaces
mapfile -t sorted_paths_list < <(sort_paths_by_size "${final_paths_to_clean[@]}")

if [[ ${#sorted_paths_list[@]} != 0 ]] && [[ -n "${sorted_paths_list[*]}" ]]; then # todo check 2nd condition
    need_clean=1
fi

# Print heading line before printing paths in verbose and list only mode
if [ "$list_only" -eq 1 ]; then
    echo -e "\n${BOLD}${MAGENTA}LIST ONLY:${NC}"
    if [[ $need_clean -eq 0 ]]; then
        echo -e "\t${BOLD}${MAGENTA}NO PATHS TO CLEAN${NC}"
    else
        echo -e "\t${BOLD}${MAGENTA}PATHS TO CLEAN${NC}"
    fi
elif [ "$verbose" -eq 1 ]; then
    echo -en "${BOLD}${MAGENTA}VERBOSE SUMMARY:\n\t"
    if [[ $need_clean -eq 0 ]]; then
        echo -en "NO PATHS "
    fi
    if [ "$dry_run" -eq 1 ]; then
        echo -e "TO DELETE${NC}"
    else
        echo -e "DELETED${NC}"
    fi
fi

# Clean paths in sorted order or list in list_only mode
if [ $need_clean -eq 1 ]; then
    for path in "${sorted_paths_list[@]}"; do
        if [ "$list_only" -eq 1 ] && [[ -e $path ]]; then
            echo -e "\t$(print_size_color "$(get_path_size "$path")")${NC}\t$path"
        else
            clean_paths "$path"
        fi
    done
fi

# List skipped (not cleaned) paths in verbose mode + total size of skipped paths
# Skipped paths are those that have been marked as "skip":
# - User decision:
#   - Paths that had a process running and user chose not to clean
#   - Paths that user chose not to clean in interactive mode
# - Paths that which size is less than 1KB
mapfile -t sorted_all_paths < <(sort_paths_by_size "${!DEF_PATHS_TO_CLEAN[@]}")
if [ "$verbose" -eq 1 ]; then
    if [ "$list_only" -eq 1 ]; then
        echo -e "\n\t${BOLD}${MAGENTA}IGNORED PATHS < 1M${NC}"
        for path in "${sorted_all_paths[@]}"; do
        if [ "${DEF_PATHS_TO_CLEAN[$path]}" == "empty" ]; then
            DEF_PATHS_TO_CLEAN[$path]="skip"
        fi
    done
    else
        echo -e "\n\t${NOTE}SKIPPED${NC}"
    fi
    for path in "${sorted_all_paths[@]}"; do
        if [[ -n "${DEF_PATHS_TO_CLEAN[*]}" ]] && [ "${DEF_PATHS_TO_CLEAN[$path]}" == "skip" ]; then
            total_skipped=$((total_skipped + $(get_path_size "$path")))
            echo -e "\t$(print_size_color "$(get_path_size "$path")")${NC}\t$path"
        fi
    done
	if [ "$total_skipped" -eq 0 ]; then
		echo -e "\tPATHS SMALLER THAN 1MB\n" # fixme NOT WORKING VERBOSE SKIPPED LIST (tested with flags -ni)
    else
        echo -e "\n\t$(get_size_color "$total_skipped")TOTAL SKIPPED: ${BOLD}$(print_size_color "$total_skipped")"
    fi
fi

# Convert total freed to readable format
total_freed_read=$(print_size_color "$total_freed")

# Print total freed space and home storage available before/after cleaning
if [ "$list_only" -eq 0 ]; then
    if [ $total_freed -ne 0 ]; then
        echo -e "\t$(get_size_color "$total_freed")TOTAL CLEAN: ${BOLD}$total_freed_read\n"
        echo -en "Total available space:"
        if [ "$before_cleaning" != "$(get_storage_usage)" ]; then
            echo -e "\n\t${ERROR}BEFORE: ${NC}${before_cleaning}${NC}"
            echo -ne "\t${BGREEN}AFTER: ${NC}"
        fi
    fi
fi

if [ $total_freed -eq 0 ] || [ "$list_only" -eq 1 ]; then
    echo -en "\n Total available space:"
fi
echo -e " ${BOLD}$(get_storage_usage)\n${NC}"

if [ $dry_run -eq 1 ] && [ $list_only -eq 0 ]; then
	echo -e "${BRED}DRY-RUN:${NC} END OF SIMULATION. NO FILES WERE DELETED"
fi
