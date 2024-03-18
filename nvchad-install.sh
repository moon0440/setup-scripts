#!/bin/bash

# Check for Ubuntu 20.04 OS
if [[ $(grep 'NAME=' /etc/os-release) != *"Ubuntu"* ]] || [[ $(grep 'VERSION_ID=' /etc/os-release) != *"20.04"* ]]; then
    echo "Unsupported OS. This script only supports Ubuntu 20.04."
    exit 1
fi

# Install Nix if not already installed
if ! command -v nix &> /dev/null; then
    echo "Nix is not installed. Installing Nix..."
    # Using sh to execute the Nix installation script
    sh <(curl -L https://nixos.org/nix/install) --daemon
    # Source nix script to ensure nix commands work in the current session
    . /etc/profile.d/nix.sh
else
    echo "Nix is already installed."
fi

# Define packages to install via Nix
packages=("neovim" "ripgrep" "gcc" "make" "nodejs")

# Update Nix packages list
echo "Updating Nix package database..."
nix-channel --update

# Install packages
echo "Installing packages with Nix..."
nix-env -iA nixpkgs.${packages[@]}

# Setting alias for nvim as nv if it doesn't already exist in ~/.bashrc
if ! grep -q "alias nv='nvim'" ~/.bashrc; then
    echo "Adding alias for nvim as nv in ~/.bashrc..."
    echo "alias nv='nvim'" >> ~/.bashrc
    # Informing the user about the new alias
    echo "Alias added. You might need to restart your terminal or source ~/.bashrc to use the alias."
fi

# Installing NvChad
if [ -d "$HOME/.config/nvim" ]; then
    read -p "NvChad is already installed. Do you want to reinstall it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing existing NvChad installation..."
        rm -rf "$HOME/.config/nvim"
        rm -rf "$HOME/.local/share/nvim"
        echo "Reinstalling NvChad..."
        git clone https://github.com/NvChad/NvChad ~/.config/nvim && nvim --headless +PackerSync +qa
    else
        echo "Skipping NvChad installation."
    fi
else
    echo "Installing NvChad..."
    git clone https://github.com/NvChad/NvChad ~/.config/nvim && nvim --headless +PackerSync +qa
fi
