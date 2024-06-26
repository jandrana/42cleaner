#!/bin/bash

INSTALL_DIR=$HOME/.42cleaner

# Remove the .42cleaner folder from the home directory
rm -rf $INSTALL_DIR

# Remove the 'clean' alias from the shell configuration
case $SHELL in
	/bin/bash)
		ALIAS_FILE="$HOME/.bashrc"
		;;
	/bin/zsh)
		ALIAS_FILE="$HOME/.zshrc"
		;;
	*)
		echo -e "Unknown shell. Please remove the following alias manually:"
		echo -e "alias clean='$INSTALL_DIR/clean.sh'"
		exit 1
		;;
esac

# Check if the alias exists
if grep -q "alias clean=" $ALIAS_FILE; then
	existing_alias=$(grep "alias clean=" $ALIAS_FILE)
	expected_alias="alias clean='$INSTALL_DIR/clean.sh'"
	if [ "$existing_alias" == "$expected_alias" ]; then
		# Use sed to remove the line containing the alias
		sed -i '/alias clean=/d' $ALIAS_FILE
	else
		echo -e "Failed to remove alias 'clean' from $ALIAS_FILE"
		echo -e "Possible reasons:"
		echo -e "\t3. An alias 'clean' exists in your $ALIAS_FILE file but is not for the clean.sh script. No actions needed, such alias has not been removed, since is not from this script"
	fi
else
	echo -e "INFO: No alias was removed from $ALIAS_FILE"
	echo -e "If you believe this might be an error, consider the following cases:"
	echo -e "\t1. The alias 'clean' doesn't exist in $ALIAS_FILE. No actions needed"
	echo -e "\t2. An alias for the clean.sh exists in $ALIAS_FILE but is not named 'clean'. Please, remove it manually by editing the $ALIAS_FILE file"
fi

echo -e "SUCCESS: Successfully uninstalled"
echo -e "WARNING: Please restart any open shell sessions for the changes to take effect."