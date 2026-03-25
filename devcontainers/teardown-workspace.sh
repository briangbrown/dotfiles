#!/bin/bash
set -e

# Usage: teardown-workspace <workspace-name>
WORKSPACE_NAME=$1
DEVELOPMENT_HUB="$HOME/Development"
TARGET_DIR="$DEVELOPMENT_HUB/$WORKSPACE_NAME"

# ANSI Colors for UI
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 1. Basic Validation
if [[ -z "$WORKSPACE_NAME" ]]; then
  echo -e "${RED}Error: Missing workspace name.${NC}"
  echo "Usage: $0 <workspace-name>"
  exit 1
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  echo -e "${RED}Error: Workspace '$WORKSPACE_NAME' does not exist in $DEVELOPMENT_HUB.${NC}"
  exit 1
fi

echo -e "🔍 Analyzing workspace: ${YELLOW}$WORKSPACE_NAME${NC}..."

# 2. Introspect Git Status
cd "$TARGET_DIR"
DIRTY=false
UNPUSHED=false

if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    if [[ -n $(git status --porcelain) ]]; then
        DIRTY=true
    fi

    if git log @{u}.. > /dev/null 2>&1; then
        if [[ -n $(git log @{u}.. --oneline) ]]; then
            UNPUSHED=true
        fi
    else
        UNPUSHED=true
    fi
else
    echo -e "${YELLOW}Notice: This directory is not a Git repository.${NC}"
fi

# 3. The Safety Gates
if [[ "$DIRTY" == true || "$UNPUSHED" == true ]]; then
    echo -e "\n${RED}====================================================${NC}"
    echo -e "${RED}⚠️  DANGER: UNCOMMITTED OR UNPUSHED WORK DETECTED ⚠️${NC}"
    echo -e "${RED}====================================================${NC}"

    if [[ "$DIRTY" == true ]]; then
        echo -e " • You have ${YELLOW}uncommitted changes${NC} (Claude might have left files behind)."
    fi
    if [[ "$UNPUSHED" == true ]]; then
        echo -e " • You have ${YELLOW}unpushed commits${NC} that only exist on this Mac."
    fi

    echo -e "\nIf you delete this workspace now, that work is gone forever."
    echo -n -e "To force deletion anyway, type '${RED}DELETE${NC}' and press Enter: "
    read -r CONFIRM

    if [[ "$CONFIRM" != "DELETE" ]]; then
        echo -e "${GREEN}Safe choice. Teardown aborted.${NC}"
        exit 0
    fi
else
    echo -e "${GREEN}Git tree is clean and fully pushed to remote.${NC}"
    echo -n -e "Are you sure you want to delete ${YELLOW}$WORKSPACE_NAME${NC}? [y/N]: "
    read -r CONFIRM

    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Teardown aborted."
        exit 0
    fi
fi

# 4. Docker Cleanup Phase
echo "🐳 Hunting for associated Docker container..."

# VS Code explicitly labels Dev Containers with their host machine folder path.
# We use this exact label to ensure we never delete the wrong container.
CONTAINER_IDS=$(docker ps -a -q --filter "label=devcontainer.local_folder=$TARGET_DIR")

if [[ -n "$CONTAINER_IDS" ]]; then
    echo "   Found attached container. Stopping and destroying..."
    # The -f flag forces the container to stop if it is currently running
    docker rm -f $CONTAINER_IDS
else
    echo "   No container found (it may have already been deleted)."
fi

# 5. File System Cleanup
# Step out of the directory so the terminal doesn't lock it
cd "$DEVELOPMENT_HUB"

echo "📁 Removing workspace files..."
rm -rf "$TARGET_DIR"

echo -e "${GREEN}✅ Workspace '$WORKSPACE_NAME' and its Docker container have been successfully destroyed.${NC}"
