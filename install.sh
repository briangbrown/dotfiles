#!/bin/bash
set -e

# Install Homebrew on macOS if not already installed (required for all
# macOS tool installs below)
if [ "$(uname)" = "Darwin" ] && ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Claude Code global settings and hooks
mkdir -p ~/.claude/scripts
cp .claude/settings.json ~/.claude/settings.json
cp claude/scripts/approve-compound-bash.sh ~/.claude/scripts/approve-compound-bash.sh
chmod +x ~/.claude/scripts/approve-compound-bash.sh

# Starship prompt config
mkdir -p ~/.config
cp starship.toml ~/.config/starship.toml

# Shared exports: copy managed file and source it from .exports
cp .exports.dotfiles ~/.exports.dotfiles
if ! grep -q 'source ~/.exports.dotfiles' ~/.exports 2>/dev/null; then
  echo 'source ~/.exports.dotfiles' >> ~/.exports
fi

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

# Install eza and zsh plugins
if [ "$(uname)" = "Darwin" ]; then
  # macOS — install via Homebrew
  brew install eza zsh-autosuggestions zsh-syntax-highlighting shfmt jq 2>/dev/null || true
else
  # Linux containers — install via apt
  if ! command -v eza &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y -qq eza 2>/dev/null || true
  fi
  sudo apt-get install -y -qq zsh-autosuggestions zsh-syntax-highlighting jq 2>/dev/null || true
  # Install shfmt (required by claude-code-auto-approve hook)
  if ! command -v shfmt &>/dev/null; then
    curl -sS https://webinstall.dev/shfmt | bash 2>/dev/null || true
  fi
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

# --- macOS-only tools ---
# These are skipped in containers where Node and Claude Code are managed
# by the devcontainer image / feature configuration.
if [ "$(uname)" = "Darwin" ]; then
  # fnm (Fast Node Manager) — manages Node.js versions on macOS
  if ! command -v fnm &>/dev/null; then
    brew install fnm
  fi

  # Activate fnm and install LTS Node if no version is installed yet.
  # This must happen before Claude Code install so npm is on the PATH.
  eval "$(fnm env)"
  if ! fnm list | grep -q "v"; then
    fnm install --lts
  fi

  # Claude Code CLI — installed globally on macOS so it's available in
  # any local VS Code terminal (containers install it separately)
  if ! command -v claude &>/dev/null; then
    npm install -g @anthropic-ai/claude-code
  fi
fi

echo "Dotfiles installed."
