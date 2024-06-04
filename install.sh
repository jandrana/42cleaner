#!/bin/bash

# Check if clean.sh exists
if [ ! -f "clean.sh" ]; then
	echo "clean.sh not found in the current directory. Please run this script from the directory where clean.sh is located."
	exit 1
fi

# Give execution permissions to clean.sh
chmod +x clean.sh

# Copy the clean.sh script to the $HOME directory
cp clean.sh $HOME

# Check if the configuration file exists in the current directory, if so, copy it to $HOME/.config
if [ -f "clean.conf" ]; then
	mkdir -p $HOME/.config
	cp clean.conf $HOME/.config
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
if grep -q "alias clean=" $ALIAS_FILE; then
	existing_alias=$(grep "alias clean=" $ALIAS_FILE)
	new_alias="alias clean='$HOME/clean.sh'"
	if [ "$existing_alias" == "$new_alias" ]; then
		echo "The alias 'clean' already exists and is the same as the one being installed. No changes were made."
	else
		read -p "The alias 'clean' already exists but is different. Do you want to overwrite it? (y/n) " overwrite
		if [[ $overwrite =~ ^[Nn]$ ]]; then
			read -p "Do you want to use another name for the alias? (y/n) " rename
			if [[ $rename =~ ^[Yy]$ ]]; then
				read -p "Enter the new alias name: " new_alias_name
				echo "alias $new_alias_name='$HOME/clean.sh'" >> $ALIAS_FILE
			else
				echo "No alias was added. You can add it manually later with 'alias clean=$HOME/clean.sh'"
			fi
		else
			echo "alias clean='$HOME/clean.sh'" >> $ALIAS_FILE
		fi
	fi
else
	echo "alias clean='$HOME/clean.sh'" >> $ALIAS_FILE
fi

echo "Installation complete. Please restart any open shell sessions for the changes to take effect."