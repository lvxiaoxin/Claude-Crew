#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
TEMPLATES_SRC="$SCRIPT_DIR/templates"
SKILLS_DST="$HOME/.claude/skills"
TEMPLATES_DST="$HOME/.claude/claude-crew-templates"

echo "Claude Crew Installer"
echo "====================="
echo "Skills source:    $SKILLS_SRC"
echo "Templates source: $TEMPLATES_SRC"
echo "Skills target:    $SKILLS_DST"
echo "Templates target: $TEMPLATES_DST"
echo ""

# Check source exists
if [ ! -d "$SKILLS_SRC/agents" ] || [ ! -d "$SKILLS_SRC/workflows" ] || [ ! -d "$SKILLS_SRC/crew" ]; then
  echo "ERROR: Source skills directory not found at $SKILLS_SRC"
  exit 1
fi

if [ ! -d "$TEMPLATES_SRC/project" ]; then
  echo "ERROR: Source templates directory not found at $TEMPLATES_SRC"
  exit 1
fi

# Check target base exists
if [ ! -d "$SKILLS_DST" ]; then
  echo "ERROR: Claude skills directory not found at $SKILLS_DST"
  echo "Is Claude Code installed?"
  exit 1
fi

# Collect all source files
declare -a SRC_FILES=()
for file in "$SKILLS_SRC"/agents/*.md; do
  SRC_FILES+=("agents/$(basename "$file")")
done
for file in "$SKILLS_SRC"/workflows/*.md; do
  SRC_FILES+=("workflows/$(basename "$file")")
done
SRC_FILES+=("crew/SKILL.md")

# Collect template files
declare -a TPL_FILES=()
for file in "$TEMPLATES_SRC"/project/*; do
  TPL_FILES+=("project/$(basename "$file")")
done

# Check for conflicts
CONFLICT=0
for relpath in "${SRC_FILES[@]}"; do
  target="$SKILLS_DST/$relpath"
  source="$SKILLS_SRC/$relpath"
  if [ -f "$target" ]; then
    if ! diff -q "$source" "$target" > /dev/null 2>&1; then
      echo "WARNING: $SKILLS_DST/$relpath exists and differs from source"
      CONFLICT=1
    fi
  fi
done

for relpath in "${TPL_FILES[@]}"; do
  target="$TEMPLATES_DST/$relpath"
  source="$TEMPLATES_SRC/$relpath"
  if [ -f "$target" ]; then
    if ! diff -q "$source" "$target" > /dev/null 2>&1; then
      echo "WARNING: $TEMPLATES_DST/$relpath exists and differs from source"
      CONFLICT=1
    fi
  fi
done

if [ "$CONFLICT" -eq 1 ]; then
  echo ""
  read -p "Overwrite conflicting files? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

# Install skills
mkdir -p "$SKILLS_DST/agents"
mkdir -p "$SKILLS_DST/workflows"
mkdir -p "$SKILLS_DST/crew"

INSTALLED=0
for relpath in "${SRC_FILES[@]}"; do
  cp "$SKILLS_SRC/$relpath" "$SKILLS_DST/$relpath"
  echo "  ✓ skills/$relpath"
  INSTALLED=$((INSTALLED + 1))
done

# Install templates
mkdir -p "$TEMPLATES_DST/project"

for relpath in "${TPL_FILES[@]}"; do
  cp "$TEMPLATES_SRC/$relpath" "$TEMPLATES_DST/$relpath"
  echo "  ✓ templates/$relpath"
  INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "Done. $INSTALLED files installed."
