#!/usr/bin/env bash
set -euo pipefail

# --- 1) Install packages with apt (Debian/Ubuntu) ---
echo "==> Updating apt package list..."
sudo apt-get update

echo "==> Installing Zsh, git (for versions), kitty..."
# If 'zsh-syntax-highlighting' isn't in your repo, we’ll clone it manually, but let's try:
sudo apt-get install -y zsh git kitty zsh-syntax-highlighting zsh-autosuggestions

# Directory variables (feel free to tweak if desired)
ZSH_DIR="$HOME/.zsh/pure"
KITTY_DIR="$HOME/.config/kitty"
ICON_DIR_SYSTEM="/usr/share/icons/hicolor/256x256/apps" 
# or for user-level only:
# ICON_DIR_USER="$HOME/.local/share/icons/hicolor/256x256/apps"

# We'll assume the script lives in the same directory as the config files:
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "==> Creating directories if they don't exist..."
mkdir -p "$ZSH_DIR"
mkdir -p "$KITTY_DIR"
sudo mkdir -p "$ICON_DIR_SYSTEM"  # system-wide icon directory; needs sudo

echo "==> Copying .zshrc..."
cp -v "$SCRIPT_DIR/zshrc" "$HOME/.zshrc"

echo "==> Copying Pure prompt scripts..."
cp -v "$SCRIPT_DIR/async.zsh" "$ZSH_DIR/async.zsh"
cp -v "$SCRIPT_DIR/pure.zsh"  "$ZSH_DIR/pure.zsh"

echo "==> Copying kitty.conf..."
cp -v "$SCRIPT_DIR/kitty.conf" "$KITTY_DIR/kitty.conf"

echo "==> Installing custom icon..."
# For a system-wide icon install
sudo cp -v "$SCRIPT_DIR/icon.png" "$ICON_DIR_SYSTEM/kitty.png"
# Optionally update the icon cache:
sudo gtk-update-icon-cache /usr/share/icons/hicolor || true

echo "==> Changing default shell to zsh for user: $USER"
 chsh -s "$(command -v zsh)" "$USER"

echo "Installation complete. Please restart now."
