# 42Cleaner

42Cleaner is a script designed to clean cache and temporary files for 42 students using Linux/Ubuntu. It helps to free up disk space and maintain system performance by removing unnecessary files from various directories.

## Index

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Options](#options)
  - [Examples](#examples)
  - [Safe Mode Example](#safe-mode-example)
- [Configuration](#configuration)
  - [Default Configuration](#default-configuration)
  - [Custom Paths](#custom-paths)
- [Uninstall](#uninstall)
- [Future Features](#future-features)
- [Contributing](#contributing)
- [License](#license)
- [Documentation](#documentation)

## Features

- Detailed documentation for each file (clean.sh/clean.conf/process_name.sh) in the docs folder
- Clean cache and temporary files from multiple applications.
- Interactive mode to confirm deletions.
- Dry run mode to simulate the cleaning process without actually deleting any files.
- Verbose mode to display detailed information about deleted files.
- Safe mode to ensure safe operation when force mode is enabled.
- Customizable paths to clean.

## Installation

To install 42Cleaner, open your terminal and run the following command:

```bash
git clone https://github.com/jandrana/42cleaner && cd 42cleaner && chmod +x install.sh && ./install.sh
```

Command explanation:

1. Clone the 42Cleaner repository.
2. Navigate into the `42cleaner` directory.
3. Give execute permissions to the `install.sh` script.
4. Run the `install.sh` script to set up 42Cleaner on your system.

## Usage

After installation, you can use the `clean` command (the default alias) to run the cleaning script. If you chose a different name for the alias during installation, use that alias instead. If no alias was added, you can run the script by running it from your home directory.

Usage example (using alias `clean`):
```bash
clean [options]
```

Usage example (without using aliases):
```bash
$HOME/clean.sh [options]
```


### Options

For detailed information about available options, refer to the [CLEAN_SH_DOCS.md](docs/CLEAN_SH_DOCS.md) under the Command-line Options section.

## Configuration

The default behavior of the script can be configured by editing the `clean.conf` file located in `~/.config/clean.conf`. For more detailed information, refer to the [CLEAN_CONF_DOCS.md](docs/CLEAN_CONF_DOCS.md).


### Custom Paths
Custom paths can be added in the `clean.sh` script under the `DEF_PATHS_TO_CLEAN` array. See the script documentation and comments for further instructions on how to add custom paths. For more information, refer to the [CLEAN_SH_DOCS.md](docs/CLEAN_SH_DOCS.md).

## Uninstall
To uninstall 42Cleaner, run the following command:
```sh
cd $(find $HOME -type d -name '42cleaner' -print -quit) && chmod +x uninstall.sh && ./uninstall.sh
```
Command explanation:

1. Finds the first directory named '42cleaner' found within the `$HOME` directory or any of its subdirectories.
2. Navigate into the first `42cleaner` found directory.
3. Give execute permissions to the `uninstall.sh` script.
4. Run the `uninstall.sh` script to remove the 42Cleaner setup from your system, including the `clean.sh` script, the configuration file, and the alias from your shell configuration.

## Future Features

- **GUI Interface**: Develop a graphical user interface to make the script more user-friendly.
- **Enhanced Safety Checks**: Improve safety checks to avoid accidental deletion of critical files.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with any improvements or bug fixes.


## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Documentation

For detailed information about the scripts and configuration files used in this project, refer to the following documents:

- [CLEAN_SH_DOCS.md](docs/CLEAN_SH_DOCS.md): Detailed documentation for the `clean.sh` script.
- [CLEAN_CONF_DOCS.md](docs/CLEAN_CONF_DOCS.md): Detailed documentation for the `clean.conf` configuration file.
- [PROCESS_NAME_DOCS.md](docs/PROCESS_NAME_DOCS.md): Detailed documentation for the `process_name.sh` script.