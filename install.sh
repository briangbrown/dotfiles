#!/bin/bash
set -e

# Claude Code global settings
mkdir -p ~/.claude
cp .claude/settings.json ~/.claude/settings.json

# Starship prompt config
mkdir -p ~/.config
cp starship.toml ~/.config/starship.toml

# Append Starship init to .zshrc if not already present
if ! grep -q 'starship init zsh' ~/.zshrc 2>/dev/null; then
  cat .zshrc >> ~/.zshrc
fi

# Install Starship if not already installed (works in Codespaces/devcontainers)
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

echo "Dotfiles installed."
