# Repository

This public repo stores portable user configuration and helps set up fresh Linux accounts.

`install.sh` links configuration and offers optional tool installation. `files/` holds the configuration sources; groups handled by the generic linker use `location.sh` to print their destination directories. The installer links Neovim separately.

`containers/ia/` holds a separate Docker workflow for coding agents. `doc/` holds reference notes. `tools/` holds downloaded tools and is ignored by Git.

Keep personal values out of tracked files. Use the local overrides sourced by the shell and Git configuration.
