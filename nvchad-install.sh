#!/usr/bin/env bash

# Check for Supported os: currently only Ubuntu 20.04
if [[ $(grep 'NAME=' /etc/os-release) != *"Ubuntu"* ]] || [[ $(grep 'VERSION_ID=' /etc/os-release) != *"20.04"* ]]; then
	echo "Unsupported OS. This script only supports Ubuntu 20.04."
	exit 1
fi

packages=("nvim" "ripgrep" "gcc" "make", "npm")
packages_to_install=()

for pkg in "${packages[@]}"; do
	if ! command -v $pkg &>/dev/null; then
		echo "$pkg is not installed. Marking for installation."
		packages_to_install+=($pkg)
	else
		echo "$pkg is already installed."
	fi
done

if [ ${#packages_to_install[@]} -ne 0 ]; then
	echo "Installing missing packages..."
	sudo apt update
	for pkg in "${packages_to_install[@]}"; do
		case $pkg in
		nvim)
			sudo apt install -y neovim
			;;
		*)
			sudo apt install -y $pkg
			;;
		esac
	done
else
	echo "All packages are already installed."
fi

# Setting alias for nvim as nv if it doesn't already exist in ~/.bashrc
if grep -q "alias nv='nvim'" ~/.bashrc; then
	echo "Alias for nvim already exists in ~/.bashrc."
else
	echo "Adding alias for nvim as nv in ~/.bashrc..."
	echo "alias nv='nvim'" >>~/.bashrc
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
		echo "Installing NvChad..."
		git clone https://github.com/NvChad/starter ~/.config/nvim
	else
		echo "Skipping NvChad installation."
	fi
else
	echo "Installing NvChad..."
	git clone https://github.com/NvChad/starter ~/.config/nvim
fi
