#!/bin/bash

# --- Global Variables ---
OS_FAMILY="unknown"

# --- OS Detection Function ---
detect_os() {
  echo "Detecting operating system..."
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "arch" || "$ID_LIKE" == "arch" ]]; then
      OS_FAMILY="arch"
    elif [[ "$ID" == "debian" || "$ID_LIKE" == "debian" || "$ID" == "ubuntu" || "$ID_LIKE" == "ubuntu" ]]; then
      OS_FAMILY="debian"
    elif [[ "$ID" == "fedora" || "$ID_LIKE" == "fedora" ]]; then
      OS_FAMILY="fedora"
    else
      OS_FAMILY="unknown" # Fallback for other Linux with /etc/os-release
    fi
  elif [[ "$(uname)" == "Darwin" ]]; then
    OS_FAMILY="macos"
  else
    OS_FAMILY="unknown"
  fi
  echo "OS Family detected: $OS_FAMILY"
}

# --- Package Installation Function ---
install_package() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: install_package <package_name> [<package_name>...]"
    return 1
  fi

  local pkgs_to_install=("$@")
  echo "Attempting to install: ${pkgs_to_install[*]}"

  case "$OS_FAMILY" in
    "arch")
      sudo pacman -S --noconfirm "${pkgs_to_install[@]}"
      ;;
    "debian")
      sudo apt-get update && sudo apt-get install -y "${pkgs_to_install[@]}"
      ;;
    "fedora")
      sudo dnf install -y "${pkgs_to_install[@]}"
      ;;
    "macos")
      if ! command -v brew &> /dev/null; then
        echo "Error: Homebrew (brew) not found. Please install Homebrew first."
        echo "Visit https://brew.sh for installation instructions."
        return 1 # Indicate failure to install dependency
      fi
      brew install "${pkgs_to_install[@]}"
      ;;
    "unknown")
      echo "OS family is unknown or not supported by this script for automatic package installation."
      echo "Please install the following packages manually: ${pkgs_to_install[*]}"
      return 1 # Indicate failure due to unknown OS
      ;;
    *)
      echo "Internal error: Unknown OS_FAMILY '$OS_FAMILY'"
      return 1
      ;;
  esac

  if [ $? -ne 0 ]; then
    echo "Error: Package installation failed for: ${pkgs_to_install[*]}"
    return 1
  fi
  echo "Successfully initiated installation for: ${pkgs_to_install[*]}"
  return 0
}
