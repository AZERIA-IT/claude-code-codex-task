#!/usr/bin/env bash
set -euo pipefail

AGENTS_DIR="$HOME/.claude/agents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo '=== claude-code-codex-task installer ==='

# Check codex CLI
if ! which codex &>/dev/null; then
  echo '[WARN] codex CLI not found in PATH. Install it first: npm install -g @openai/codex'
fi

# Detect codex-companion.mjs
COMPANION=$(find ~/.claude/plugins -name 'codex-companion.mjs' -type f 2>/dev/null | head -1)
if [ -z "$COMPANION" ]; then
  echo '[ERROR] codex-companion.mjs not found under ~/.claude/plugins/'
  echo '        Make sure the openai-codex Claude Code plugin is installed.'
  exit 1
fi
echo "[OK] Found codex-companion.mjs at: $COMPANION"

# Create agents dir if needed
mkdir -p "$AGENTS_DIR"

# Copy and patch the agent file
DEST="$AGENTS_DIR/codex-task.md"
if [ -f "$DEST" ]; then
  echo "[INFO] $DEST already exists — backing up to $DEST.bak"
  cp "$DEST" "$DEST.bak"
fi

# Replace the find-based placeholder with the actual resolved path
sed "s|$(find ~/.claude/plugins -name 'codex-companion.mjs' -type f | head -1)|$COMPANION|g"   "$SCRIPT_DIR/agents/codex-task.md" > "$DEST"

echo "[OK] Agent installed to $DEST"
echo ''
echo 'Restart Claude Code (claude) to load the subagent.'
