To - Do (LINUX NEW OS FOR 42)

 - Clave SSH:
	- Home Computer: authentication + signing key Github
	- Add VSCode signing commits

- Install francinette (see Steamo message in Slack at 42malaga_global_general 13/02/2024 at 7:18PM)

- Git config stuff:
	- https://git-scm.com/book/sv/v2/Customizing-Git-Git-Configuration

- VSCode See extension: Warm Up - Typing test

- See https://www.jessesquires.com/blog/2021/10/24/git-aliases-to-improve-productivity/#:~:text=Git%20aliases%20can%20be%20entire,global%20%2D%2Dunset%20alias.NAME%20.

- See https://github.com/rothgar/mastering-zsh/blob/master/docs/helpers/aliases.md


- See GitKraken

- See Oh My ZSH

Add github extensions to VSCode

Done: 

 - Added git config: credentials + email + name
	- vim ~/.git-credentials -> https://username:TOKEN@github.com
	- git config --global user.[name/user/email] "..."
 - Added Configured VSCode Extensions: 
	- 42: 42 C-Format | 42 ft count line | 42 Header | 42 Norminette
	- C: C/C++ & Extension Pack & Themes | CMake & Tools | Makefile Tools
	- Web: HTML CSS Support | Markdown Preview Github Styling
	- Themes: Material Icon Theme | One Dark Pro
	- Github: Wakatime
 - Added vertical ruler to VSCode
	- VSCode Settings >> ruler >> 80
 - Configured AutoSave VSCode
 - Configured Tabulations in VSCode (Editor Detect Indentation | Insert Spaces)
	- VSCode Settings >> Editor Detect Indentation && !Insert Spaces
 - Added Smooth Scrolling to VSCode Settings (editor, workbench & terminal)
 - Added Cursor Blinking (smooth)
 - Enabled cursor smooth caret animation (when moving cursor between lines)
 - Set vim as default editor (in .zshrc)
	- export EDITOR=vim
	- export VISUAL="$EDITOR"
 - Set aliases for francinette (in .zshrc) and others, see below
	- alias francinette="$HOME"/francinette/tester.sh
	- alias paco="$HOME"/francinette/tester.sh
 - Added config for .vimrc
 - SSH:
	- ssh-keygen (see slack links)
	- 42: Vogsphere, authentication + signing key Github
	

Useful commands:
 - git config --list (see list of configured git)
 - git config credential.helper store (credentials in .git-credentials)
 - VSCode Multi cursor selection
	- Shift+Alt+Up / Shift+Alt+Down / Alt+LeftClick
 - VSCode Multi cursor by Search
	- Ctrl+D
 - VSCode Move line up and down
	- Alt+Up & Alt+Down
 - VSCode Open Markdown Preview
	- Ctrl+Shift+V 
 - VSCode Add Vertical Rulers (Settings "editor.rulers" : [80])
 - Zen Mode
	- Entering: Ctrl+K Z || Exiting: Esc Esc
 - See available storage:
	- df -h $HOME
 - See storage usage by directory (+single subdirectory)
	- du -sh */*/ | sort -hr
	- du -sh .*/ */ | sort -hr
	- du -sh $(ls -A) | sort -hr (best one)
	- du -sh $(ls -A) -t 1M -c | sort -hr (best one)
		du command for estimated file space usage
		-s to display only a total of each folder (not include all files)
		-h to show sizes in human readable format
		(ls -A) to also see storage usage of hidden files/folders
		-t 1M to see only files/folders that are bigger than 1MB
		-c to see a grand total at the begginning of the list
		| sort -hr to sort from biggest to smallest

ZSH ALIASSES
	- alias (list of zsh aliases)
	- st_av (see available storage in HOME)
	- st_us (see storage usage by directory)

GIT ALIASES
Add alias alias to list aliases in git:
- git config --global alias.alias "! git config --get-regexp ^alias\. | sed -e s/^alias\.// -e s/\ /\ =\ /"

Remove alias in git:

git config --global --unset alias.NAME_ALIAS

Remove alias alias in aliases s_list
- git rmal alias.NAME_ALIAS
