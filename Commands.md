# Useful Commands

## Zsh

```sh
history # Show command history
alias # List zsh personal aliases (command shortcuts)
```

## Vim
```vim

" NORMAL MODE

" Search
/pattern " Search forward for `pattern`
?pattern " Search backward for `pattern`
n " Search in the same direction
N " Search in the opposite direction
* " Search forwart for the word under the cursor
:noh " Clear the last search highlight

" Other
yy " Yank (copy) a line
dd " Delete a line
p " Paste
u " Undo
<Ctrl+r> " Redo

" autocompletion
<Ctrl+n> " autocompletion (next match)
<Ctrl+p> " autocompletion (previous match)

:help i_CTRL-N " Documentation for autocompletion (normal mode)

" Advanced autocompletion (omni completion) (see .vimrc to enable)
<Ctrl+x> " Invoke omni completion
	<Ctrl+l> " Whole line completion
	<Ctrl+]> " Tags file completion
	<Ctrl+d> " Definition completion
	<Ctrl+f> " Filename completion (based on files in $PWD)
	<Ctrl+i> " Path pattern completion
	<Ctrl+k> " Dictionary completion
	<Ctrl+n> " Keyword local completion
	<Ctrl+o> " Omni completion completion
	<Ctrl+v> " Command line completion
```


## VSCode
```js
// settings.json
editor.rulers : [80]  // Add vertical ruler in VSC settings
```

##### Keyboard shortcuts
- <kbd>Shift</kbd> + <kbd>Alt</kbd> + <kbd>↑↓</kbd>: Multi cursor selection by line position
- <kbd>Alt</kbd> + <kbd>Left 🖱</kbd>: Multi cursor selection by mouse position
- <kbd>Ctrl</kbd> + <kbd>D</kbd>: Multi cursor selection by Search
- <kbd>Alt</kbd> + <kbd>↑↓</kbd>: Move line up and down
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>V</kbd>: Open Markdown Preview
- <kbd>Ctrl</kbd> + <kbd>K</kbd>: Enter Zen Mode
- <kbd>Esc</kbd> <kbd>Esc</kbd>: Exit Zen Mode 
- <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>: Show command palette


## Git 
- `git init`: Initialize a new Git repository
- `git branch`: List all branches
- `git branch develop`: Create new branch "develop"
- `git checkout develop`: Switch to branch "develop"
- `git merge develop`: Merge branch "develop" with current branch
- `git diff`: Show changes between commits, commit and working tree
- `git stash`: Stash changes in a dirty working directory
- `git stash pop`: Apply stashed changes
- `git rm file.txt`: Remove "file.txt" from the working directory and from the index

#### Git config commands

- List of git configurations
	```sh
	git config --list`
	```

- Create new git configuration
	```sh
	git config --global CATEGORY.NAME "value"

	# Examples
	git config --global user.name "Ana Alejandra" # Name for commits
	git config --global alias.lstcon "config --list" # New alias

	# New alias usage:
	git lstcon # Show list of configured git
	```
- Delete git configuration
	```sh
	git config --global --unset CATEGORY.NAME

	# Example
	git config --global --unset alias.lstcon
	```
# Configuration files

## Git (.gitconfig)
```ini

# Personal
[core]
	editor = vim # Sets vim as default editor for Gir
	excludesfile = ~/.gitignore # Sets global .gitignore file
[credential]
	helper = store # Stores credential
[user]
	name = Ana Alejandra Castillejo # Name for commit messages
	email = yo@anaalejandra.com # Email for commit messages
	username = jandrana # Username for commit messages
	signingkey = /home/ana-cast/.ssh/github.pub # Path to SSH key for signing commits
[gpg]
	format = ssh # Format for GPG key
[commit]
	gpgsign = true # Automatically sign commits
[gpg "ssh"]
	allowedSignersFile = /home/ana-cast/.config/git/allowed_signers # Path to allowed signers file

# Aliases
[alias]
	alias = ! git config --get-regexp ^alias\\. | sed -e s/^alias\\.// -e s/\\ /\\ =\\ / # List all aliases
	rmal = config --global --unset # Remove a global configuration setting
	lol = log --oneline # Shows log in one line
	lolg = log --oneline --graph --decorate # Shows log in one line with graph
	smartlog = log --graph --pretty=format:'commit: %C(bold red)%h%Creset %C(red)<%H>%Creset %C(bold magenta)%d %Creset%ndate: %C(bold yellow)%cd %Creset%C(yellow)%cr%Creset%nauthor: %C(bold blue)%an%Creset %C(blue)<%ae>%Creset%n%C(cyan)%s%n%Creset' # Custom log format
	me = smartlog --author='Ana Alejandra Castillejo' # Shows smartlog for specific author
	lstauth = shortlog -s -n # List authors by number of commits
	lstcon = config --list # List all git configurations
	uncommit = reset --soft HEAD^ # Uncommit last commit, leaving changes staged
	chm = checkout main # Checkout main branch
	chd = checkout develop # Checkout develop branch

# Colors
[color]
	ui = auto # Enables color output
[color "branch"]
	current = green bold # Color for current branch
	local = cyan # Color for local branches
	remote = yellow # Color for remote branches
[color "diff"]
	meta = yellow bold # Color for metadata in diffs
	frag = magenta bold # Color for fragment marks in diffs
	old = red bold # Color for removed lines in diffs
	new = green bold # Color for added lines in diffs
	whitespace = red reverse # Color for whitespace errors in diffs
```
- Structure of configurations:
	```ini
	[<CATEGORY>]
		<name> = <value>
		...
	```

## ZSH (.zshrc)
```sh
### PERSONAL CONFIGURATIONS ###

	# Set vim as default editor
	export EDITOR=vim
	export VISUAL="$EDITOR"

	## ALIASES ## 
	# Create new alias
	alias name='command'
	# Francinette aliases
	alias francinette="$HOME"/francinette/tester.sh
	alias paco="$HOME"/francinette/tester.sh
	# Personal zsh aliases
	alias st_av='df -h $HOME' # Show available storage
	alias st_us='du -sh $(ls -A) -t 1M -c | sort -hr' # Show storage 

```
- List zsh configured aliases
	```sh
	alias
	```

## Vim (.vimrc)
```sh
### PERSONAL CONFIGURATIONS ###

	# Syntax and other visual configurations
	syntax on # Enable syntax highlighting
	set number # Display line numbers
	set mouse=a # Enable mouse usage
	set ruler # Display cursor position

	# Indentation
	set autoindent # Auto-indent new lines
	set copyindent # Copy indent from current line

	# Command maps
	command! Q q # Map Q to q command
	command! W w # Map W to w command

	# Line lenght alerts
	set colorcolumn=80 # Highlight 80th column
	highlight ColorColumn ctermbg=0 guibg=lightgrey # Set color for ColorColum
	match ColorColumn "\%>79v.\+" # Highlight characters beyond 80th column
	# Searching commands
	set ignorecase # Make searches case-insensitive
	set hlsearch # Highlights all search matches
	set incsearch # Shows search matches as you type
	# Other
	set showmatch # Shows matching brackets
	set wildmenu # Enables command-line completion
	set nowritebackup # Don't create backup before writing
```
