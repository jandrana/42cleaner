# 42Cleaner

42Cleaner is a script designed to clean cache and temporary files for 42 students using Linux/Ubuntu. It helps to free up disk space and maintain system performance by removing unnecessary files from various directories.

## Index

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Options](#options)
- [Configuration](#configuration)
  - [Custom Paths](#custom-paths)
- [Uninstall](#uninstall)
- [Documentation](#documentation)
- [Future Features](#future-features)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

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
sh -c "$(curl -fsSL https://raw.githubusercontent.com/jandrana/42cleaner/main/install.sh)"
```

After installation, the 42cleaner folder will be in your home directory (`~/42cleaner`)

## Usage

After installation, you can use the `clean` command (the default alias) to run the cleaning script. If you chose a different name for the alias during installation, use that alias instead. If no alias was added, you can run the script by running it from your home directory.

Usage example (using alias `clean`):
```bash
clean [options]
```

Usage example (without using aliases):
```bash
$HOME/.42cleaner/clean.sh [options]
```


### Options

For detailed information about available options, refer to the [CLEAN_SH_DOCS.md](docs/CLEAN_SH_DOCS.md) under the Command-line Options section.

## Configuration

The default behavior of the script can be configured by editing the `clean.conf` file located in `~/.42cleaner/clean.conf`. For more detailed information, refer to the [CLEAN_CONF_DOCS.md](docs/CLEAN_CONF_DOCS.md).


### Custom Paths
Custom paths can be added in the `clean.sh` script under the `DEF_PATHS_TO_CLEAN` array. See the script documentation and comments for further instructions on how to add custom paths. For more information, refer to the [CLEAN_SH_DOCS.md](docs/CLEAN_SH_DOCS.md).

## Uninstall
To uninstall 42Cleaner, run the following command:
```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/jandrana/42cleaner/main/uninstall.sh)"
```

This command will run the `uninstall.sh` script and delete any files/alias created by the `install.sh`.

<ul><details>

<summary><b>Manual Uninstall</b></summary>

If you prefer, you can do it manually by deleting the `$HOME/.42cleaner` folder.

If an alias for running the clean script was created during installation/usage of the script, you will also need to delete the following line from your `~/.zshrc` or `~/.bashrc` file.
```sh
alias clean='$HOME/.42cleaner/clean.sh'
```

NOTE: 'clean' is the default name for the alias, take into account that it may have change if you renamed the alias during/after the installation of the script.
</details></ul>

## Documentation

For detailed information about the scripts and configuration files used in this project, refer to the following documents:

- [CLEAN_SH_DOCS.md](docs/CLEAN_SH_DOCS.md): Detailed documentation for the `clean.sh` script.
- [CLEAN_CONF_DOCS.md](docs/CLEAN_CONF_DOCS.md): Detailed documentation for the `clean.conf` configuration file.
- [PROCESS_NAME_DOCS.md](docs/PROCESS_NAME_DOCS.md): Detailed documentation for the `process_name.sh` script.

## Future Features

- **GUI Interface**: Develop a graphical user interface to make the script more user-friendly.
- **Enhanced Safety Checks**: Improve safety checks to avoid accidental deletion of critical files.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with any improvements or bug fixes.


## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Acknowledgments

Special thanks to **Steamo** from 42 Malaga for checking out the scripts so thoroughly and the feedback given.
