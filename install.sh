#!/bin/bash

REPO_DIR=$HOME/42cleaner
INSTALL_DIR=$HOME/.42cleaner

# Check if the repository already exists in the home directory
if [ -d "$REPO_DIR" ]; then
	read -p "The 42cleaner repository already exists. Do you want to update it? (y/n) " update
	case $update in
		[Yy]* ) cd "$REPO_DIR"; git pull; printf "" ;;
		* ) printf "No changes were made to the repository.\n\n" ;;
	esac
else
	git clone https://github.com/jandrana/42cleaner "$REPO_DIR"
fi

# Navigate to the repository
cd "$REPO_DIR" || { printf "Failed to navigate to the repository directory. Exiting..."; exit 1; }

# Check if clean.sh exists
if [ ! -f "clean.sh" ]; then
	printf "clean.sh not found in the current directory. Make sure the repository is correctly cloned.\n"
	exit 1
fi

# Give execution permissions to clean.sh, process_name.sh and uninstall.sh scripts
chmod +x clean.sh utils/process_name.sh uninstall.sh

# Create the .42cleaner directory in the home directory
mkdir -p "$INSTALL_DIR"

# Copy the clean.sh script to the home directory
cp clean.sh "$INSTALL_DIR/clean.sh"

# Check if the configuration file exists in the utils directory, if so, copy it to $INSTALL_DIR
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
		printf "Unknown shell. Please add the following alias manually to your shell configuration file:"
		printf "alias clean='$HOME/clean.sh'"
		exit 1
		;;
esac

# Check if the alias already exists
if grep -q "alias clean=" $ALIAS_FILE; then
	existing_alias=$(grep "alias clean=" $ALIAS_FILE)
	new_alias="alias clean='$INSTALL_DIR/clean.sh'"
	if [ "$existing_alias" == "$new_alias" ]; then
		printf "INFO: The alias 'clean' already exists and is the same as the one being installed. No changes made.\n"
	else
		read -p "The alias 'clean' already exists but is different. Do you want to overwrite it? (y/n) " overwrite
		case $overwrite in
			[Nn]* )
				read -p "Do you want to use another name for the alias? (y/n) " rename
				case $rename in
					[Yy]* )
						read -p "Enter the new alias name: " new_alias_name
						printf "alias $new_alias_name='$INSTALL_DIR/clean.sh'" >> "$ALIAS_FILE"
						printf "INFO: New alias '$new_alias_name' created in $ALIAS_FILE for running the clean.sh script"
						printf "\t alias $new_alias_name='$INSTALL_DIR/clean.sh'\n"
						;;
					* )
						printf "INFO: No alias added. You can add it manually later using 'alias clean=$INSTALL_DIR/clean.sh'\n"
						;;
				esac
				;;
			* )
				sed -i '/alias clean=/d' $ALIAS_FILE
				printf "alias clean='$INSTALL_DIR/clean.sh'" >> "$ALIAS_FILE"
				printf "INFO: New alias 'clean' created in $ALIAS_FILE for running the clean.sh script"
				printf "\t alias clean='$INSTALL_DIR/clean.sh'\n"
				;;
		esac
	fi
else
	printf "# Alias for clean.sh (42cleaner by Jandrana)" >> "$ALIAS_FILE"
	printf "alias clean='$INSTALL_DIR/clean.sh'" >> "$ALIAS_FILE"
	printf "INFO: New alias 'clean' created in $ALIAS_FILE for running the clean.sh script"
	printf "\t alias clean='$INSTALL_DIR/clean.sh'\n"
fi

printf "SUCCESS: Installation completed"
printf "WARNING: Please restart any open shell sessions for the changes to take effect."
