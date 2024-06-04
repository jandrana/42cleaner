#!/bin/bash

# Remove the clean.sh script from the $HOME directory
rm -f $HOME/clean.sh

# Remove the clean.conf configuration file from the $HOME/.config directory
rm -f $HOME/.config/clean.conf

# Remove the 'clean' alias from the shell configuration
case $SHELL in
	/bin/bash)
		ALIAS_FILE="$HOME/.bashrc"
		;;
	/bin/zsh)
		ALIAS_FILE="$HOME/.zshrc"
		;;
	*)
		echo "Unknown shell. Please remove the following alias manually:"
		echo "alias clean='$HOME/clean.sh'"
		exit 1
		;;
esac

# Check if the alias exists
if grep -q "alias clean=" $ALIAS_FILE; then
	existing_alias=$(grep "alias clean=" $ALIAS_FILE)
	expected_alias="alias clean='$HOME/clean.sh'"
	if [ "$existing_alias" == "$expected_alias" ]; then
		# Use sed to remove the line containing the alias
		sed -i '/alias clean=/d' $ALIAS_FILE
	else
		echo "The existing 'clean' alias is not the one from the clean.sh script. It will not be removed."
	fi
fi

echo "Uninstallation complete. Please restart any open shell sessions for the changes to take effect."