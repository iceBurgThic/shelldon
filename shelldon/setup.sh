#!/usr/bin/env bash
set -euo pipefail

echo "==> Detecting package manager..."

if command -v dnf >/dev/null 2>&1; then
  PKG_INSTALL="sudo dnf install -y"
  PKG_UPDATE="sudo dnf -y makecache"
  PKG_LIST="zsh git kitty zsh-syntax-highlighting zsh-autosuggestions util-linux-user"
elif command -v apt-get >/dev/null 2>&1; then
  PKG_INSTALL="sudo apt-get install -y"
  PKG_UPDATE="sudo apt-get update"
  PKG_LIST="zsh git kitty zsh-syntax-highlighting zsh-autosuggestions"
else
  echo "Unsupported package manager. Install zsh, git, kitty manually."
  exit 1
fi

echo "==> Updating package lists..."
$PKG_UPDATE

echo "==> Installing packages..."
$PKG_INSTALL $PKG_LIST

# --- Directories ---
ZSH_DIR="$HOME/.zsh/pure"
PLUGIN_DIR="$HOME/.zsh/plugins"
KITTY_DIR="$HOME/.config/kitty"
ICON_DIR="/usr/share/icons/hicolor/256x256/apps"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "==> Creating directories..."
mkdir -p "$ZSH_DIR"
mkdir -p "$PLUGIN_DIR"
mkdir -p "$KITTY_DIR"
sudo mkdir -p "$ICON_DIR"

# --- Backup existing config ---
echo "==> Backing up existing configs (if present)..."
[ -f "$HOME/.zshrc" ] && mv -v "$HOME/.zshrc" "$HOME/.zshrc.bak"

# --- Copy configs ---
echo "==> Copying .zshrc..."
cp -vf "$SCRIPT_DIR/zshrc" "$HOME/.zshrc"

echo "==> Copying Pure prompt..."
cp -vf "$SCRIPT_DIR/async.zsh" "$ZSH_DIR/async.zsh"
cp -vf "$SCRIPT_DIR/pure.zsh"  "$ZSH_DIR/pure.zsh"

echo "==> Copying kitty.conf..."
cp -vf "$SCRIPT_DIR/kitty.conf" "$KITTY_DIR/kitty.conf"

# --- Plugin fallback (if distro packages missing) ---
echo "==> Ensuring plugins exist..."

if [ ! -d "/usr/share/zsh-syntax-highlighting" ] && [ ! -d "$PLUGIN_DIR/zsh-syntax-highlighting" ]; then
  echo "Installing zsh-syntax-highlighting via git..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGIN_DIR/zsh-syntax-highlighting"
fi

if [ ! -d "/usr/share/zsh-autosuggestions" ] && [ ! -d "$PLUGIN_DIR/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions via git..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR/zsh-autosuggestions"
fi

# --- Icon install ---
echo "==> Installing custom kitty icon..."
ICON_NAME="kitty"

sudo cp -vf "$SCRIPT_DIR/icon.png" "$ICON_DIR/${ICON_NAME}.png"
sudo gtk-update-icon-cache /usr/share/icons/hicolor || true

# --- Ensure zsh is valid shell ---
echo "==> Ensuring zsh is in /etc/shells..."
if ! grep -q "$(command -v zsh)" /etc/shells; then
  echo "$(command -v zsh)" | sudo tee -a /etc/shells
fi

# --- Set default shell ---
echo "==> Setting default shell to zsh for $USER..."
chsh -s "$(command -v zsh)" "$USER"

echo ""
echo "✅ Installation complete."
echo "➡️ Restart or log out/in to enter zsh."