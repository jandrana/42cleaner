#!/bin/bash

INSTALL_DIR=$HOME/.42cleaner

# Remove the .42cleaner folder from the home directory
if [ -d "$INSTALL_DIR" ]; then
	rm -rf $INSTALL_DIR
	echo -e "SUCCESS: $INSTALL_DIR found and deleted\n"
else
	echo -e "WARNING: The folder '.42cleaner/' could not be found in the home directory.\n\t If the folder is located elsewhere or named differently, delete it manually.\n"
fi

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
		# 'sed' used to remove the lines containing the alias and its comment
		sed -i '/Alias for clean.sh/d' $ALIAS_FILE
		sed -i '/alias clean=/d' $ALIAS_FILE
		echo -e "SUCCESS: Alias 'clean' removed from $ALIAS_FILE file\n"
	else
		echo -e "INFO: No alias removed from $ALIAS_FILE"
		echo -e "\tAn alias 'clean' exists in your configuration file but is not for the clean.sh script."
		echo -e "\tSuch alias has not been removed, since it is not from the 42cleaner\n"
	fi
else
	echo -e "WARNING: No alias was removed from $ALIAS_FILE"
	echo -e "\tPossible reasons:"
	echo -e "\t1. The alias 'clean' doesn't exist. No actions needed"
	echo -e "\t2. An alias for the clean.sh exists but is not named 'clean'"
	echo -e "\t   Please, remove it manually by editing the $ALIAS_FILE file\n"
fi

echo -e "SUCCESS: Successfully uninstalled"
echo -e "WARNING: Please restart any open shell sessions for the changes to take effect."