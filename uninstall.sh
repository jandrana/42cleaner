#!/bin/bash

# Remove the .42cleaner directory from home directory
rm -rf ~/.42cleaner

# Remove the 'clean' alias from the shell configuration
case $SHELL in
	/bin/bash)
		ALIAS_FILE="~/.bashrc"
		;;
	/bin/zsh)
		ALIAS_FILE="~/.zshrc"
		;;
	*)
		echo "Unknown shell. Please remove the following alias manually:"
		echo "alias clean='~/.42cleaner/clean.sh'"
		exit 1
		;;
esac

# Check if the alias exists
if grep -q "alias clean=" $ALIAS_FILE; then
	existing_alias=$(grep "alias clean=" $ALIAS_FILE)
	expected_alias="alias clean='~/.42cleaner/clean.sh'"
	if [ "$existing_alias" == "$expected_alias" ]; then
		# Use sed to remove the line containing the alias
		sed -i '/alias clean=/d' $ALIAS_FILE
	else
		echo "The existing 'clean' alias is not the one from the clean.sh script. It will not be removed."
	fi
fi

echo "Uninstallation complete. Please restart any open shell sessions for the changes to take effect."