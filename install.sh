#!/bin/bash
set -e

# Claude Code global settings
mkdir -p ~/.claude
cp .claude/settings.json ~/.claude/settings.json

# Starship prompt config
mkdir -p ~/.config
cp starship.toml ~/.config/starship.toml

# Shared aliases: copy managed file and source it from .aliases
cp .aliases.dotfiles ~/.aliases.dotfiles
if ! grep -q 'source ~/.aliases.dotfiles' ~/.aliases 2>/dev/null; then
  echo 'source ~/.aliases.dotfiles' >> ~/.aliases
fi

# Zsh config: copy managed file and source it from .zshrc
cp .zshrc.dotfiles ~/.zshrc.dotfiles
if ! grep -q 'source ~/.zshrc.dotfiles' ~/.zshrc 2>/dev/null; then
  echo 'source ~/.zshrc.dotfiles' >> ~/.zshrc
fi

# Bash config: copy managed file and source it from .bashrc
cp .bashrc.dotfiles ~/.bashrc.dotfiles
if ! grep -q 'source ~/.bashrc.dotfiles' ~/.bashrc 2>/dev/null; then
  echo 'source ~/.bashrc.dotfiles' >> ~/.bashrc
fi

# Install Starship if not already installed
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# Install eza if not already installed (Linux containers only — use brew on macOS)
if ! command -v eza &>/dev/null && [ "$(uname)" = "Linux" ]; then
  sudo apt-get update -qq && sudo apt-get install -y -qq eza 2>/dev/null || true
fi

# Install zsh plugins (Linux containers only — use brew on macOS)
if [ "$(uname)" = "Linux" ]; then
  sudo apt-get install -y -qq zsh-autosuggestions zsh-syntax-highlighting 2>/dev/null || true
fi

# Install ble.sh for bash autosuggestions and syntax highlighting
if [ ! -d ~/.local/share/blesh ]; then
  echo "Installing ble.sh (bash autosuggestions + syntax highlighting)..."
  if command -v make &>/dev/null && command -v gawk &>/dev/null; then
    # Build from source if build tools are available
    tmpdir=$(mktemp -d)
    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$tmpdir/ble.sh"
    make -C "$tmpdir/ble.sh" install PREFIX=~/.local
    rm -rf "$tmpdir"
  else
    # Fall back to nightly tarball (no build tools required)
    tmpdir=$(mktemp -d)
    curl -sL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJf - -C "$tmpdir"
    bash "$tmpdir"/ble-nightly/ble.sh --install ~/.local/share/blesh
    rm -rf "$tmpdir"
  fi
fi

echo "Dotfiles installed."
