# dotfiles

Personal configuration for shell, prompt, and dev tools. Works across macOS, GitHub Codespaces, and local devcontainers. Supports both **zsh** and **bash**.

## What's included

| File | Purpose |
|---|---|
| `.exports.dotfiles` | Shared environment variables (TERM, fnm) — sourced from `~/.exports` via `install.sh` |
| `.aliases.dotfiles` | Managed aliases (eza) — sourced from `~/.aliases` via `install.sh` |
| `.zshrc.dotfiles` | Zsh config: zsh plugins, Starship init (sourced from `~/.zshrc`) |
| `.bashrc.dotfiles` | Bash config: ble.sh, Starship init (sourced from `~/.bashrc`) |
| `starship.toml` | Starship prompt (git, node, python, docker, command duration, time) |
| `.claude/settings.json` | Claude Code global settings (hooks, permissions) |
| `claude/scripts/approve-compound-bash.sh` | Auto-approves compound Bash commands in Claude Code ([source](https://github.com/oryband/claude-code-auto-approve)) |
| `devcontainers/` | Workspace bootstrapping: init/teardown scripts and fallback devcontainer template (macOS only) |
| `install.sh` | Copies configs into place and installs tools if needed |

### Tools configured

- **[Starship](https://starship.rs/)** — cross-shell prompt with git status, language versions, command duration, and timestamps
- **[eza](https://eza.rocks/)** — modern `ls` replacement with color-coded file types, icons, and git status
- **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** — ghost-text suggestions from command history (zsh)
- **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** — colors commands as you type (zsh)
- **[ble.sh](https://github.com/akinomyoga/ble.sh)** — autosuggestions and syntax highlighting for bash (bash equivalent of both zsh plugins above)
- **[fnm](https://github.com/Schniz/fnm)** — fast Node.js version manager (macOS only — containers use their own Node)
- **[Claude Code](https://claude.com/claude-code)** — Anthropic's CLI for Claude (macOS only — containers install it separately)
- **[claude-code-auto-approve](https://github.com/oryband/claude-code-auto-approve)** — PreToolUse hook that auto-approves compound Bash commands (e.g. `ls | grep foo`) when every sub-command is in your allow list. Deny list blocks catastrophic operations like `git push --force`, `rm -rf /`, and `gh repo delete`

## Setup

### macOS (first time)

1. Clone this repo and run the install script:

   ```sh
   git clone https://github.com/briangbrown/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./install.sh
   ```

   The install script handles everything: Homebrew (if not installed), Starship, eza, zsh plugins, fnm, Node.js LTS, and Claude Code.

2. Install the Nerd Font (for terminal icons):

   ```sh
   brew install font-jetbrains-mono-nerd-font
   ```

3. Set the Nerd Font in your VS Code user settings:

   ```json
   "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font', 'JetBrains Mono', monospace",
   "editor.fontFamily": "'JetBrainsMono Nerd Font', 'JetBrains Mono', monospace"
   ```

   For iTerm2 or other local terminals, set the font to "JetBrainsMono Nerd Font" in the terminal's preferences.

4. Restart your terminal (or `source ~/.zshrc` / `source ~/.bashrc`).

### GitHub Codespaces

Codespaces automatically clones your dotfiles repo and runs `install.sh` when a new codespace is created — no manual steps needed.

To enable this (one-time):

1. Go to [github.com/settings/codespaces](https://github.com/settings/codespaces)
2. Under **Dotfiles**, select `briangbrown/dotfiles`
3. Check **Automatically install dotfiles**

Every new codespace will run `install.sh`, which installs Starship, ble.sh, and copies all configs.

### Local devcontainers

VS Code local devcontainers also support dotfiles. To enable:

1. Open VS Code Settings (`Cmd+Shift+P` > **Preferences: Open User Settings (JSON)**)
2. Add:

   ```json
   "dotfiles.repository": "briangbrown/dotfiles",
   "dotfiles.installCommand": "install.sh"
   ```

When VS Code creates a new devcontainer, it clones this repo into the container and runs `install.sh`.

## Updating configs

When you change files in this repo (e.g., edit `starship.toml` or `.claude/settings.json`):

### macOS

Pull the latest changes and re-run the install script:

```sh
cd ~/dotfiles
git pull
./install.sh
source ~/.zshrc  # or source ~/.bashrc
```

### Codespaces

New codespaces automatically get the latest version from `main`. For an **existing** codespace, open the Command Palette (`Cmd+Shift+P`) and run **Codespaces: Dotfiles: Install Dotfiles**. This re-clones the repo and runs `install.sh`.

### Local devcontainers

Dotfiles are installed when a container is **created**, not on every open. To pick up changes in an existing container:

- **Rebuild the container** — Command Palette > **Dev Containers: Rebuild Container**
- Or manually run inside the container: `cd ~/dotfiles && git pull && ./install.sh && source ~/.zshrc`

## Adding new configs

1. Add the config file to this repo
2. Update `install.sh` to copy/symlink it into the right location
3. Commit and push to `main`
4. Follow the update steps above for each environment
