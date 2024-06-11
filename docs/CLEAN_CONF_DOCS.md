# File Documentation for clean.conf

## Index

- [Overview](#overview)
- [Important Note](#important-note)
- [Default Configuration](#default-configuration)
  - [Explanation of Options](#explanation-of-options)
- [How to Modify Configuration](#how-to-modify-configuration)
  - [Direct Modification](#direct-modification)
  - [Using Script Flags](#using-script-flags)
- [Conclusion](#conclusion)

## Overview

The `clean.conf` file contains default configuration values for various options used by the `clean.sh` script. These options control the behavior of the script, including verbosity, dry run, interactive mode, force mode, and list only mode. Each option is assigned a default value of `0`, indicating that it is disabled by default.

## Important Note

The `clean.conf` file located in the repository is not the one that needs to be changed. The configuration file that is actually being processed by the `clean.sh` script is the copy made by the installer in the `$HOME/.config` directory. You can change the file location by modifying the line `CONFIG_FILE="$HOME/.config/clean.conf"` in the `clean.sh` script and by moving the `$HOME/.config/clean.conf` file or by copying the `clean.conf` file from the repository into the new location.

## Default Configuration

The default configuration values in the `clean.conf` file are:

```bash
DEFAULT_VERBOSE=0
DEFAULT_DRY_RUN=0
DEFAULT_INTERACTIVE=0
DEFAULT_FORCE=0
DEFAULT_LIST_ONLY=0
```

### Explanation of Options

- **DEFAULT_VERBOSE**: Controls whether the script runs in verbose mode.
  - `0`: Verbose mode is disabled.
  - `1`: Verbose mode is enabled.

- **DEFAULT_DRY_RUN**: Controls whether the script runs in dry run mode.
  - `0`: Dry run mode is disabled.
  - `1`: Dry run mode is enabled (no files will be deleted).

- **DEFAULT_INTERACTIVE**: Controls whether the script runs in interactive mode.
  - `0`: Interactive mode is disabled.
  - `1`: Interactive mode is enabled (asks for confirmation before deleting each file or directory).

- **DEFAULT_FORCE**: Controls whether the script runs in force mode.
  - `0`: Force mode is disabled.
  - `1`: Force mode is enabled (deletes cache without asking for confirmation of running processes).

- **DEFAULT_LIST_ONLY**: Controls whether the script lists the directories and files to be cleaned without deleting.
  - `0`: List only mode is disabled.
  - `1`: List only mode is enabled (only lists directories and files to be cleaned).

## How to Modify Configuration

### Direct Modification

You can directly modify the `clean.conf` file to change the default values. Simply edit the file and update the values as needed.

Example:

```bash
DEFAULT_VERBOSE=1
DEFAULT_DRY_RUN=0
DEFAULT_INTERACTIVE=1
DEFAULT_FORCE=0
DEFAULT_LIST_ONLY=0
```

### Using Script Flags

Alternatively, you can use the `clean.sh` script with specific flags to override the default values:

1. **Set Default Mode**:
   - To set a flag as the default mode, use the `-D` flag followed by the appropriate flag.
   - Example: To set the force mode as the default mode, run:
		```bash
		clean -D f
		```

2. **Unset Default Mode**:
   - To unset a configuration and revert it to its original default value, use the `-u` flag followed by the appropriate flag.
   - Example: To unset the force mode as the default mode, run:
		```bash
    	clean -u f
		```

3. **Reset All Configurations**:
   - To reset all configurations to their original default values, use the `-r` flag.
   - Example: To reset all configurations, run:
		```bash
		clean -r
	 	```

## Conclusion

The `clean.conf` file provides a flexible way to manage the default behavior of the `clean.sh` script. By modifying this file directly or using the appropriate script flags, you can customize how the script operates to suit your needs.
