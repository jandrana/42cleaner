#!/bin/bash

REPO_DIR=$HOME/42cleaner
INSTALL_DIR=$HOME/.42cleaner

# Check if the repository already exists in the home directory
if [ -d "$REPO_DIR" ]; then
	read -p "The 42cleaner repository already exists. Do you want to update it? (y/n) " update
	if [[ $update =~ ^[Yy]$ ]]; then
		cd "$REPO_DIR"
		git pull
	else
		echo "No changes were made to the repository."
	fi
else
	git clone https://github.com/jandrana/42cleaner "$REPO_DIR"
fi

# Navigate to the repository
cd "$REPO_DIR" || { echo "Failed to navigate to the repository directory. Exiting..."; exit 1; }

# Check if clean.sh exists
if [ ! -f "clean.sh" ]; then
	echo "clean.sh not found in the current directory. Make sure the repository is correctly cloned."
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
		echo "Unknown shell. Please add the following alias manually to your shell configuration file:"
		echo "alias clean='$HOME/clean.sh'"
		exit 1
		;;
esac

# Check if the alias already exists
if grep -q "alias clean=" "$ALIAS_FILE"; then
	existing_alias=$(grep "alias clean=" "$ALIAS_FILE")
	new_alias="alias clean='$INSTALL_DIR/clean.sh'"
	if [ "$existing_alias" == "$new_alias" ]; then
		echo "INFO: The alias 'clean' already exists and is the same as the one being installed. No changes were made."
	else
		read -p "The alias 'clean' already exists but is different. Do you want to overwrite it? (y/n) " overwrite
		if [[ $overwrite =~ ^[Nn]$ ]]; then
			read -p "Do you want to use another name for the alias? (y/n) " rename
			if [[ $rename =~ ^[Yy]$ ]]; then
				read -p "Enter the new alias name: " new_alias_name
				echo "alias $new_alias_name='$INSTALL_DIR/clean.sh'" >> "$ALIAS_FILE"
				echo "INFO: New alias '$new_alias_name' created in $ALIAS_FILE for running the clean.sh script"
				echo -e "\t alias $new_alias_name='$INSTALL_DIR/clean.sh'"
			else
				echo "No alias added. You can add it manually later using 'alias clean=$INSTALL_DIR/clean.sh'"
			fi
		else
			echo "alias clean='$INSTALL_DIR/clean.sh'" >> "$ALIAS_FILE"
			echo "INFO: New alias 'clean' created in $ALIAS_FILE for running the clean.sh script"
			echo -e "\t alias clean='$INSTALL_DIR/clean.sh'"
		fi
	fi
else
	echo "alias clean='$INSTALL_DIR/clean.sh'" >> "$ALIAS_FILE"
	echo "INFO: New alias 'clean' created in $ALIAS_FILE for running the clean.sh script"
	echo -e "\t alias clean='$INSTALL_DIR/clean.sh'"
fi

echo -e "SUCCESS: Installation completed"
echo -e "WARNING: Please restart any open shell sessions for the changes to take effect."
