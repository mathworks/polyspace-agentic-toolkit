#!/usr/bin/env bash
# install-global-skills.sh — Create symlinks for Polyspace skills in ~/.agents/skills/
# Usage: ./scripts/install-global-skills.sh
# This script creates symlinks from ~/.agents/skills/ to the skills-catalog in this repo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_CATALOG="$REPO_ROOT/skills-catalog"

if [ ! -d "$SKILLS_CATALOG" ]; then
    echo "Error: skills-catalog not found at $SKILLS_CATALOG"
    exit 1
fi

# Try ~/.agents/skills/ first, fall back to ~/.copilot/skills/
SKILLS_DIR="$HOME/.agents/skills"
if ! mkdir -p "$SKILLS_DIR" 2>/dev/null; then
    SKILLS_DIR="$HOME/.copilot/skills"
    mkdir -p "$SKILLS_DIR"
fi

echo "Installing Polyspace skills to $SKILLS_DIR"

# Create symlinks for each skill group
for group_dir in "$SKILLS_CATALOG"/*/; do
    group_name=$(basename "$group_dir")
    link_name="polyspace-$group_name"
    link_path="$SKILLS_DIR/$link_name"

    if [ -L "$link_path" ]; then
        rm "$link_path"
    fi

    ln -s "$group_dir" "$link_path"
    echo "  Linked: $link_name -> $group_dir"
done

echo "Done. Skills installed to $SKILLS_DIR"
