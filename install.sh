#!/bin/bash

REPO_DIR=$HOME/42cleaner
INSTALL_DIR=$HOME/.42cleaner
INSTALL_DIR_BCK=\$HOME/.42cleaner

# Check if the repository already exists in the home directory
if [ -d "$REPO_DIR" ]; then
	read -p "The 42cleaner repository already exists. Do you want to update it? (y/n) " update
	case $update in
		[Yy]* ) cd "$REPO_DIR"; git pull ;;
		* ) printf "No changes made to the repository.\n" ;;
	esac
else
	git clone https://github.com/jandrana/42cleaner "$REPO_DIR"
fi

echo ""

# Navigate to the repository
cd "$REPO_DIR" || { printf "Failed to navigate to the repository directory. Exiting...\n"; exit 1; }

# Check if clean.sh exists
if [ ! -f "clean.sh" ]; then
	printf "clean.sh not found in the current directory. Make sure the repository is correctly cloned.\n"
	exit 1
fi

# Give execution permissions to clean.sh, uninstall.sh and utils/ scripts
chmod +x clean.sh uninstall.sh utils/process_name.sh utils/find_cache.sh

# Create the .42cleaner directory in the home directory
mkdir -p "$INSTALL_DIR"

# Copy the clean.sh script to the install directory
cp clean.sh "$INSTALL_DIR/clean.sh"

# Copy the auxiliary scripts (if they exist) to the install directory
if [ ! -f "utils/process_name.sh" ]; then
	cp utils/process_name.sh "$INSTALL_DIR/process_name.sh"
fi
if [ ! -f "utils/find_cache.sh" ]; then
	cp utils/find_cache.sh "$INSTALL_DIR/find_cache.sh"
fi

# Copy the configuration file (if it exists) to the install directory
if [ -f "utils/clean.conf" ]; then
	cp utils/clean.conf "$INSTALL_DIR"
fi

# Add an alias 'clean' to the shell configuration
case $SHELL in
	/bin/bash)
		ALIAS_FILE="$HOME/.bashrc"
		;;
	/bin/zsh)
		ALIAS_FILE="$HOME/.zshrc"
		;;
	*)
		printf "Unknown shell. Please add the following alias manually to your shell configuration file:\n"
		printf "alias clean='$HOME/clean.sh'\n"
		printf "alias process_name='$HOME/process_name.sh'\n"
		printf "alias find_cache='$HOME/find_cache.sh'\n"
		exit 1
		;;
esac

# Helper function for managing multiple alias found in $ALIAS_FILE (duplicated aliases)
manage_duplicate_alias() {
	printf "WARNING: Found duplicated aliases corresponding to 42cleaner:\n"
	printf "$cleaner_alias\n\n"
	read -p "Do you want to delete them and create a single alias (avoiding duplication errors)? (y/n) " rem_duplicate
	case $rem_duplicate in
		[Yy]* )
			echo "$cleaner_alias" | while read -r line; do
				sed -i "\|$line|d" "$ALIAS_FILE"
			done
			printf "INFO: Duplicate aliases deleted\n\n"
			;;
		* )
			printf "INFO: No alias deleted\n\n"
			;;
	esac	
}

create_alias() {
	new_alias="alias $alias_name='$INSTALL_DIR_BCK/$alias_script'"
	cleaner_alias=$(grep "='$INSTALL_DIR_BCK/$alias_script'" "$ALIAS_FILE")
	printf "$create_alias $alias_name"
	# Handles different cases if the alias already exists
	if grep -q "alias $alias_name=" $ALIAS_FILE; then
		if [ $(grep "='$INSTALL_DIR_BCK/$alias_script'" $ALIAS_FILE | wc -l) -gt 1 ]; then
			manage_multiple_alias
		fi
		if grep -q "$new_alias" $ALIAS_FILE; then
			printf " - INFO: Alias '$alias_name' for the \`$alias_script\` already exists. No changes made.\n"
			create_alias=0
		elif grep -q "alias $alias_name=" $ALIAS_FILE; then
			read -p "The alias $alias_name exists but is not for the 42Cleaner. Do you want to overwrite it? (y/n) " overwrite
			case $overwrite in
				[Yy]* ) 
					sed -i "/alias $alias_name=/d" $ALIAS_FILE
					;;
				[Nn]* ) 
					read -p "Do you want to use another name for the alias? (y/n) " rename
					case $rename in
						[Yy]* ) 
							read -p "Enter the new alias name: " new_alias_name
							alias_name=$new_alias_name
							new_alias="alias $alias_name='$INSTALL_DIR_BCK/$alias_script'"
							;;
						* ) 
							create_alias=0
							printf " - INFO: No alias added for $alias_script. You can add it manually later using: $new_alias\n"
							;;
					esac
					;;
				* ) 
					create_alias=0
					printf " - INFO: No alias added for $alias_script. You can add it manually later using $new_alias\n"
					;;
			esac
		fi
	fi

	if [ $create_alias -ne 0 ]; then
		if [ $num_aliases -eq 0 ]; then
			sed -i "/Aliases for 42cleaner scripts/d" $ALIAS_FILE
			echo "# Aliases for 42cleaner scripts (Github: Jandrana)" >> "$ALIAS_FILE"
		fi
		num_aliases=$((num_aliases + 1))
		printf "$new_alias\n" >> "$ALIAS_FILE"
		printf " - INFO: Created alias '$alias_name' for running \`$alias_script\`\n"
	fi
}

# Define the pairs of alias names and alias files
alias_pair="clean clean.sh process_name process_name.sh find_cache find_cache.sh"

# Loop through each pair and call create_alias after initializing variables
num_aliases=0

printf "CONFIGURING ALIASES AT: $ALIAS_FILE\n"

set -- $alias_pair
while [ "$#" -gt 0 ]; do
	create_alias=1
	alias_name=$1
	alias_script=$2
	create_alias
	shift 2
done

if [ $num_aliases -ge 1 ]; then
	printf " - TIP: You can directly modify the created aliases in the $ALIAS_FILE file\n"
fi

printf "\nSUCCESS: Installation completed\n"
printf "WARNING: Please restart any open shell sessions for the changes to take effect."
echo ""
