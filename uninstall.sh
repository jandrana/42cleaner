#!/bin/bash

INSTALL_DIR=$HOME/.42cleaner
INSTALL_DIR_BCK=\$HOME/.42cleaner

# Remove the .42cleaner folder from the home directory
if [ -d "$INSTALL_DIR" ]; then
	rm -rf $INSTALL_DIR
	printf "SUCCESS: $INSTALL_DIR found and deleted\n\n"
else
	printf "WARNING: The folder '.42cleaner/' could not be found in the home directory.\n\t If the folder is located elsewhere or named differently, delete it manually.\n\n"
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
		printf "Unknown shell. Please remove the following alias manually:\n"
		printf "alias clean='$INSTALL_DIR/clean.sh'\n"
		exit 1
		;;
esac

# Check if the alias exists
cleaner_alias="='$INSTALL_DIR_BCK/clean.sh'"
if grep -q $cleaner_alias $ALIAS_FILE; then
	printf "Alias(es) from 42Cleaner found:\n"
	printf "$(grep $cleaner_alias $ALIAS_FILE)\n\n"
	read -p "Do you want to delete them? (y/n) " rem_alias
	case $rem_alias in
		[Yy]* )
			sed -i "/Alias for clean.sh/d" $ALIAS_FILE
			echo "$cleaner_alias" | while read -r line; do
				sed -i "\|$line|d" "$ALIAS_FILE"
			done
			printf "SUCCESS: Aliases from 42Cleaner removed from $ALIAS_FILE\n\n"
			;;
	esac
else
	printf "INFO: No alias from 42cleaner found/deleted in $ALIAS_FILE file\n\n"
fi

printf "SUCCESS: Successfully uninstalled\n"
printf "WARNING: Please restart any open shell sessions for the changes to take effect.\n"