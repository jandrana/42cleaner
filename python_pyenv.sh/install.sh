#!/bin/bash

# This script is for installing Python unsing pyenv which is necessary for francinette tester to be installed 
# in environments where Python is not installed and you do not have root access.

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "Starting installation...\n"
# Check if pyenv is already installed
if [ ! -d "$HOME/.pyenv" ]; then
	# Install pyenv
	echo -e "Installing pyenv in $HOME/.pyenv"
	git clone https://github.com/pyenv/pyenv.git ~/.pyenv
else
	echo -e "pyenv is already installed in $HOME/.pyenv. No changes were made."
fi

# Add environment variables to the shell configuration
case $SHELL in
	/bin/bash)
		ALIAS_FILE="$HOME/.bashrc"
		;;
	/bin/zsh)
		ALIAS_FILE="$HOME/.zshrc"
		;;
	*)
		echo -e "${RED}Unknown shell. Please add the following lines manually to your shell configuration file:${NC}"
		echo 'export PATH="$PYENV_ROOT/bin:$PATH"'
		echo 'export PYENV_ROOT="$HOME/.pyenv"'
		echo 'eval "$(pyenv init --path)"'
		echo -e "${RED}Then restart your shell.${NC}"
		echo -e "\n If you need further assistance, please refer to the\n \e]8;;https://github.com/pyenv/pyenv?tab=readme-ov-file#set-up-your-shell-environment-for-pyenv\apyenv installation guide:\e]8;;\a"
		exit 1
		;;
esac

# Check if the environment variables already exist
if grep -q "PYENV_ROOT" $ALIAS_FILE; then
	echo -e "The environment variables for pyenv already exist. No changes were made."
else
	echo -e '\n# pyenv environment variables' >> $ALIAS_FILE
	echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> $ALIAS_FILE
	echo 'export PYENV_ROOT="$HOME/.pyenv"' >> $ALIAS_FILE
	echo 'eval "$(pyenv init --path)"' >> $ALIAS_FILE
	source $ALIAS_FILE
	echo -e "${GREEN}Environment variables added to $ALIAS_FILE and sourced.${NC}"
fi

# Source the shell configuration to apply the changes or restart any open shells for changes to take effect

# Install Python 3.10 using pyenv
echo -e "\nInstalling Python 3.10... This may take a while"
# Check if a version of Python 3.10 is already installed
if [ -n "$(find $(pyenv root)/versions -type d -name '3.10.*')" ]; then
    echo -e "Python 3.10 is already installed. No changes were made."
else
    pyenv install 3.10
	echo -e "${GREEN}Python 3.10 installed.${NC}"
fi

# Verify the installation with pyenv versions and python --version
echo -e "\nVerifying installation..."
if [ "$(pyenv versions | grep -c 3.10)" -eq 0 ]; then
	echo -e "${RED}Python 3.10 installation failed. Please check the output for any errors.${NC}"
	exit 1
else
	echo -e "${GREEN}Python version found: $(python --version)${NC}"
fi

# Set Python 3.10 as the global version
echo -e "\nSetting Python 3.10 as the global version"
pyenv global 3.10

# Check if the global version is set to Python 3.10
if [ "$(pyenv global)" != "3.10" ]; then
	echo -e "${RED}Setting Python 3.10 as the global version failed. Please check the output for any errors.${NC}"
	exit 1
else
	echo -e "${GREEN}Python 3.10 set as the global version.${NC}"
fi

echo -e "\n${GREEN}Installation complete. Please restart any open shell sessions for the changes to take effect.${NC}"
