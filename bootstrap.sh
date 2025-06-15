#!/bin/bash

# Check and install git if not present
if ! command -v git &> /dev/null; then
  echo "git not found. Attempting to install git..."
  if command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm git
    if ! command -v git &> /dev/null; then
      echo "Error: git installation failed via pacman. Please install git manually and re-run."
      exit 1
    fi
    echo "git installed successfully via pacman."
  else
    echo "Error: pacman not found. Cannot install git. Please install git manually and re-run."
    exit 1
  fi
else
  echo "git is already installed."
fi

# Check and install chezmoi if not present
if ! command -v chezmoi &> /dev/null; then
  echo "chezmoi not found. Attempting to install chezmoi..."
  if command -v pacman &> /dev/null; then
    sudo pacman -S --noconfirm chezmoi
    if ! command -v chezmoi &> /dev/null; then
      echo "Error: chezmoi installation failed via pacman. Please install chezmoi manually and re-run."
      exit 1
    fi
    echo "chezmoi installed successfully via pacman."
  else
    echo "Error: pacman not found. Cannot install chezmoi. Please install chezmoi manually and re-run."
    exit 1
  fi
else
  echo "chezmoi is already installed."
fi

# --- Configuration ---
DEFAULT_PROFILE="base"
PREDEFINED_REPO_URL="https://github.com/user/repo.git" # Placeholder

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
  echo "Not running inside a git repository. Cloning predefined repository."
  # For now, just set the path, actual cloning will be part of chezmoi init
  DOTFILES_DIR="$HOME/.local/share/chezmoi" # Default chezmoi source path
  echo "Simulating git clone $PREDEFINED_REPO_URL to $DOTFILES_DIR"
  # In a real scenario, you'd clone here if not using chezmoi's init --apply
fi
echo "Dotfiles directory set to: $DOTFILES_DIR"


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
"$SHADOW_CMD" walk "$PROFILE_NAME"

if [ $? -eq 0 ]; then
  echo "Bootstrap process completed for profile: $PROFILE_NAME"
else
  echo "Bootstrap process failed for profile: $PROFILE_NAME"
  exit 1
fi

exit 0
