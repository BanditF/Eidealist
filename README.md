# Multi-Profile Dotfile + Arch Bootstrap System (Shadow Walker)

This project provides a modular and portable system for managing dotfiles and environment configurations, with a focus on Arch Linux. It allows users to define multiple configuration "profiles" for different roles, desktop environments, and use cases.

## Core Concepts

*   **Profiles**: Located in the `profiles/` directory, each subdirectory (e.g., `base`, `kde`, `hyprland`) represents a configuration profile. Profiles can contain dotfiles, package lists (`packages.txt`), and metadata (`profile.yml`).
*   **`shadow` CLI**: The primary tool for managing profiles.
    *   `./shadow walk <profile_name>`: Applies the specified profile.
        *   `--add`: Layers the new profile onto the existing configuration.
        *   `--dry-run`: Shows what changes would be made without applying them.
        *   `--force`: Overwrites existing configurations without prompting.
        *   `--no-deps`: Skip automatic checking and installation of package dependencies defined in `profile.yml`.
*   **`bootstrap.sh`**: A script to set up the system on a new machine. It can install essential packages, clone this repository, and apply an initial profile.
    *   `./bootstrap.sh --profile <profile_name>`: Bootstraps the system and applies the given profile.

## Getting Started

1.  **Clone the repository (if not done by bootstrap):**
    ```bash
    git clone <repository_url>
    cd <repository_name>
    ```
2.  **Run the bootstrap script (optional, for new systems):**
    ```bash
    ./bootstrap.sh --profile <initial_profile_name>
    ```
3.  **Apply profiles using the `shadow` tool:**
    ```bash
    ./shadow walk base
    ./shadow walk hyprland --add
    ```

## Profiles

Each profile in `profiles/` can contain:
*   Dotfiles (e.g., `.bashrc`, `.config/nvim/init.lua`) that will be symlinked to your home directory by `chezmoi`.
*   `packages.txt`: A list of packages to be installed for that profile. (Note: This is a legacy way of listing packages. For automatic installation via `shadow walk`, use `profile.yml` as described below).
*   `profile.yml`: Metadata about the profile, like its name, description, and package dependencies.
    *   **Dependency Management**: The `shadow walk` command can automatically check and install package dependencies if they are specified in `profile.yml` and `yq` (a YAML parser) is installed. The `bootstrap.sh` script now attempts to install `yq` for this purpose.
    *   Dependencies are listed under the `dependencies.packages` key.
    *   Example `profile.yml` with dependencies:
        ```yaml
        name: My Zsh Profile
        description: Sets up Zsh and essential tools.
        dependencies:
          packages:
            - zsh
            - git
            - curl
            - exa # A modern replacement for ls
        ```

## Underlying Tooling

This system uses `chezmoi` under the hood for robust dotfile management.
