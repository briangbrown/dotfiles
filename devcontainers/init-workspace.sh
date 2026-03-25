#!/bin/bash
set -e

# Usage: init-workspace <repo-url> <workspace-name>
REPO_URL=$1
WORKSPACE_NAME=$2

DEVELOPMENT_HUB="$HOME/Development"
TEMPLATES_DIR="$DEVELOPMENT_HUB/.devcontainers/templates"

# 1. Validation
if [[ -z "$REPO_URL" || -z "$WORKSPACE_NAME" ]]; then
  echo "Error: Missing arguments."
  echo "Usage: $0 <repo-url> <workspace-name>"
  exit 1
fi

if [[ ! -d "$TEMPLATES_DIR" ]]; then
    echo "Error: Templates directory not found at $TEMPLATES_DIR."
    exit 1
fi

TARGET_DIR="$DEVELOPMENT_HUB/$WORKSPACE_NAME"

# 2. Prevent Overwriting
if [[ -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' already exists."
    echo "To tear it down first, run: tw $WORKSPACE_NAME"
    exit 1
fi

echo "🚀 Spinning up isolated workspace: $WORKSPACE_NAME..."

# 3. Clone the repository
echo "📥 Cloning repository via GH CLI..."
# Using --clone-name lets us specify the final folder name
gh repo clone "$REPO_URL" "$TARGET_DIR"

cd "$TARGET_DIR"

# 4. Check for existing .devcontainer configuration
if [[ -d "$TARGET_DIR/.devcontainer" || -f "$TARGET_DIR/.devcontainer.json" ]]; then
    echo "✅ Repo already contains a .devcontainer configuration. Using it."
else
    echo "⚠️ Repo is missing a .devcontainer configuration."
    echo "📦 Applying default local fallback configuration..."
    # Copy the local templates into the cloned repo root
    cp -r "$TEMPLATES_DIR/.devcontainer" "$TARGET_DIR/"
    # Hide from git so the workspace stays clean
    echo ".devcontainer/" >> .git/info/exclude
fi

echo "✅ Workspace prepared."
echo "   To launch, run: code ."
echo "   When VS Code opens, accept the prompt to 'Reopen in Container'."

# 6. Automatically open it
code .
