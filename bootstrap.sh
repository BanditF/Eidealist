#!/usr/bin/env bash
set -euo pipefail

# Source utility functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UTILS_SCRIPT_PATH="$SCRIPT_DIR/lib/utils.sh"
if [ -f "$UTILS_SCRIPT_PATH" ]; then
    # shellcheck source=lib/utils.sh
    source "$UTILS_SCRIPT_PATH"
else
    echo "Error: Utilities script not found at $UTILS_SCRIPT_PATH"
    exit 1
fi

# --- Early Operations ---
detect_os # Detect OS early. This function is now sourced from utils.sh

# --- Advanced Environment Detection (Future Enhancement) ---
# DETECTED_SHELL="" # e.g., bash, zsh
# DETECTED_DE=""    # e.g., kde, gnome, hyprland
# DETECTED_HOSTNAME="$(hostname)"

# Placeholder for logic to detect shell
# if [ -n "$SHELL" ]; then DETECTED_SHELL=$(basename "$SHELL"); fi
# echo "Detected Shell: $DETECTED_SHELL (to be implemented)"

# Placeholder for logic to detect DE (more complex)
# echo "Detected DE: $DETECTED_DE (to be implemented)"

# echo "Detected Hostname: $DETECTED_HOSTNAME"

# Package installation helper
install_pkg() {
  local pkg="$1"
  if command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm "$pkg"
  elif command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y "$pkg"
  elif command -v dnf &> /dev/null; then
    sudo dnf install -y "$pkg"
  elif command -v yum &> /dev/null; then
    sudo yum install -y "$pkg"
  elif command -v zypper &> /dev/null; then
    sudo zypper install -y "$pkg"
  else
    echo "Error: no supported package manager (pacman, apt, dnf, yum, zypper) found."
    return 1
  fi
}

# Package installation helper
install_pkg() {
  local pkg="$1"
  if command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm "$pkg"
  elif command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y "$pkg"
  elif command -v dnf &> /dev/null; then
    sudo dnf install -y "$pkg"
  elif command -v yum &> /dev/null; then
    sudo yum install -y "$pkg"
  elif command -v zypper &> /dev/null; then
    sudo zypper install -y "$pkg"
  else
    echo "Error: no supported package manager (pacman, apt, dnf, yum, zypper) found."
    return 1
  fi
}

# Check and install git if not present
if ! command -v git &> /dev/null; then
  echo "git not found. Attempting to install git..."

  if install_pkg git; then
    echo "git installed successfully."
  else
    echo "Error: git installation failed. Please install git manually and re-run."


    exit 1
  fi
  # Verify after attempting install
  if ! command -v git &> /dev/null; then
    echo "Error: git still not found after attempting installation. Please check for errors above and install git manually."

    exit 1
  fi
  echo "git should now be installed."
else
  echo "git is already installed."
fi

# Check and install chezmoi if not present
if ! command -v chezmoi &> /dev/null; then
  echo "chezmoi not found. Attempting to install chezmoi..."

  if install_pkg chezmoi; then
    echo "chezmoi installed successfully."
  else
    echo "Error: chezmoi installation failed. Please install chezmoi manually and re-run."

    exit 1
  fi
  # Verify after attempting install
  if ! command -v chezmoi &> /dev/null; then
    echo "Error: chezmoi still not found after attempting installation. Please check for errors above and install chezmoi manually."
    exit 1
  fi
  echo "chezmoi should now be installed."
else
  echo "chezmoi is already installed."
fi

# Attempt to install yq for enhanced profile dependency processing
echo "Attempting to install yq for enhanced profile dependency processing..."
if ! install_package yq; then
  echo "Warning: yq installation failed or was skipped (OS: $OS_FAMILY)."
  echo "Automatic dependency checking by the 'shadow' script might be skipped if yq is not found."
  echo "You can try installing yq manually later (e.g., 'sudo pacman -S yq', 'sudo apt-get install yq', 'brew install yq')."
  # Do not exit here, yq is an enhancement
else
  if command -v yq &> /dev/null; then
    echo "yq installed successfully or was already present."
  else
    echo "Warning: yq installation was reported as successful by package manager, but 'yq' command is still not found."
    echo "Automatic dependency checking by the 'shadow' script may be affected."
  fi
fi

# --- Configuration ---
DEFAULT_PROFILE="base"
# TODO: Replace this with your repository's URL or implement dynamic configuration.
PREDEFINED_REPO_URL="https://github.com/username/repository.git" # Placeholder

# --- Helper Functions ---
usage() {
  echo "Usage: $0 [--profile <profile_name>]"
  echo ""
  echo "Bootstraps the dotfiles configuration."
  echo ""
  echo "Options:"
  echo "  --profile <profile_name>  Specify the profile to apply (default: $DEFAULT_PROFILE)."
  exit 1
}

# --- Argument Parsing ---
PROFILE_NAME="$DEFAULT_PROFILE" # Default profile

if [ "$#" -gt 0 ]; then
  if [ "$1" == "--profile" ]; then
    if [ -n "$2" ]; then
      PROFILE_NAME="$2"
      shift 2
    else
      echo "Error: --profile option requires a profile name."
      usage
    fi
  else
    echo "Error: Unknown option $1"
    usage
  fi
fi

if [ "$#" -gt 0 ]; then
    echo "Error: Too many arguments."
    usage
fi


# --- Determine Dotfiles Directory ---
DOTFILES_DIR=""
if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "Running inside a git repository. Using current directory as dotfiles repository."
  DOTFILES_DIR="$(pwd)"
else
  echo "Not running inside a git repository. Initializing with chezmoi..."
  chezmoi init --apply "$PREDEFINED_REPO_URL"
  DOTFILES_DIR="$HOME/.local/share/chezmoi" # Default chezmoi source path after init
fi
echo "Dotfiles directory set to: $DOTFILES_DIR"

# --- Environment Detection ---
HOSTNAME="$(hostname)"
SHELL_NAME="$(basename "$SHELL")"
DESKTOP_ENV="${XDG_CURRENT_DESKTOP:-unknown}"
OS_NAME="unknown"
OS_ID="unknown"
if [ -f /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  OS_NAME="$NAME"
  OS_ID="$ID"
fi

echo "Detected hostname: $HOSTNAME"
echo "Detected shell: $SHELL_NAME"
echo "Detected desktop environment: $DESKTOP_ENV"
echo "Detected OS: $OS_NAME ($OS_ID)"

# Auto-select profile if user did not specify a different one
if [ "$PROFILE_NAME" = "$DEFAULT_PROFILE" ]; then
  if echo "$DESKTOP_ENV" | grep -qi 'kde'; then
    PROFILE_NAME="kde"
  elif echo "$DESKTOP_ENV" | grep -qi 'hyprland'; then
    PROFILE_NAME="hyprland"
  fi
fi


# --- Call shadow script ---
echo "Attempting to run shadow script..."
if [ ! -f "./shadow" ]; then
    echo "Error: shadow script not found in the current directory."
    echo "Please ensure bootstrap.sh is run from the root of the dotfiles repository where 'shadow' is located,"
    echo "or that 'shadow' is in your PATH if running from elsewhere."
    # As a fallback for the "not in git repo" case, we might need to adjust how shadow is called
    # For now, we assume if not in a git repo, shadow might be placed alongside bootstrap.sh or in PATH
    # This part might need refinement based on actual deployment strategy.
    if [ -f "$DOTFILES_DIR/shadow" ]; then
        echo "Found shadow script in guessed dotfiles directory: $DOTFILES_DIR"
        SHADOW_CMD="$DOTFILES_DIR/shadow"
    else
        echo "Could not locate shadow script. Exiting."
        exit 1
    fi
else
    SHADOW_CMD="./shadow"
fi

echo "Executing: $SHADOW_CMD walk $PROFILE_NAME"

# Call the shadow script to apply the profile
# The shadow script itself will handle chezmoi logic

if "$SHADOW_CMD" walk "$PROFILE_NAME"; then
  echo "Bootstrap process completed for profile: $PROFILE_NAME"
else
  echo "Bootstrap process failed for profile: $PROFILE_NAME"
  exit 1
fi

exit 0
