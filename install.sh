#!/bin/bash
set -e

# Claude Code global settings
mkdir -p ~/.claude
cp .claude/settings.json ~/.claude/settings.json

# Starship prompt config
mkdir -p ~/.config
cp starship.toml ~/.config/starship.toml

# Shell config: copy managed file and source it from .zshrc
cp .zshrc.dotfiles ~/.zshrc.dotfiles
if ! grep -q 'source ~/.zshrc.dotfiles' ~/.zshrc 2>/dev/null; then
  echo 'source ~/.zshrc.dotfiles' >> ~/.zshrc
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

echo "Dotfiles installed."
