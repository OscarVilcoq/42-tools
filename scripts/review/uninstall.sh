#!/usr/bin/env bash
BIN_DIR="$HOME/.local/bin"
SHELL_RC="${SHELL_RC:-$HOME/.bashrc}"

rm -f "$BIN_DIR/review"
sed -i '/alias r=/d' "$SHELL_RC" 2>/dev/null || true

echo "Commande 'review' et alias 'r' supprimés."