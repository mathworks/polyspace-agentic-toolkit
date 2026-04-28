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

# Create flat per-skill symlinks so that each SKILL.md is at depth */SKILL.md
# (Gemini CLI discovers skills with a one-level-deep glob only).
for group_dir in "$SKILLS_CATALOG"/*/; do
    [ -d "$group_dir" ] || continue

    # If the group itself has a SKILL.md, link it directly
    if [ -f "$group_dir/SKILL.md" ]; then
        link_name=$(basename "$group_dir")
        link_path="$SKILLS_DIR/$link_name"
        [ -L "$link_path" ] && rm "$link_path"
        ln -s "$group_dir" "$link_path"
        echo "  Linked: $link_name -> $group_dir"
    fi

    # Link each sub-skill individually
    for skill_dir in "$group_dir"/*/; do
        [ -d "$skill_dir" ] || continue
        [ -f "$skill_dir/SKILL.md" ] || continue
        link_name=$(basename "$skill_dir")
        link_path="$SKILLS_DIR/$link_name"
        [ -L "$link_path" ] && rm "$link_path"
        ln -s "$skill_dir" "$link_path"
        echo "  Linked: $link_name -> $skill_dir"
    done
done

echo "Done. Skills installed to $SKILLS_DIR"
