# dotfiles

Personal configuration for shell, prompt, and dev tools. Works across macOS, GitHub Codespaces, and local devcontainers.

## What's included

| File | Purpose |
|---|---|
| `.zshrc` | Shell config: eza aliases, zsh plugins, Starship init |
| `starship.toml` | Starship prompt (git, node, python, docker, command duration, time) |
| `.claude/settings.json` | Claude Code global settings |
| `install.sh` | Copies configs into place and installs tools if needed |

### Tools configured

- **[Starship](https://starship.rs/)** — cross-shell prompt with git status, language versions, command duration, and timestamps
- **[eza](https://eza.rocks/)** — modern `ls` replacement with color-coded file types, icons, and git status
- **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** — ghost-text suggestions from command history
- **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** — colors commands as you type (green = valid, red = not found)

## Setup

### macOS (first time)

1. Install tools via Homebrew:

   ```sh
   brew install starship eza zsh-autosuggestions zsh-syntax-highlighting
   ```

2. Clone this repo and run the install script:

   ```sh
   git clone https://github.com/briangbrown/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ./install.sh
   ```

3. Restart your terminal (or `source ~/.zshrc`).

### GitHub Codespaces

Codespaces automatically clones your dotfiles repo and runs `install.sh` when a new codespace is created — no manual steps needed.

To enable this (one-time):

1. Go to [github.com/settings/codespaces](https://github.com/settings/codespaces)
2. Under **Dotfiles**, select `briangbrown/dotfiles`
3. Check **Automatically install dotfiles**

Every new codespace will run `install.sh`, which installs Starship and copies all configs.

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
source ~/.zshrc
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
