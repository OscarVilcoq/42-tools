#!/usr/bin/env bash
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

cat << 'EOF' > "$BIN_DIR/git-acp"
#!/usr/bin/env bash

MSG="${1:-Update}"

git add -A
git commit -m "$MSG"
git push
EOF

chmod +x "$BIN_DIR/git-acp"
git config --global alias.acp "!$BIN_DIR/git-acp"
echo "Alias 'git acp' configuré."