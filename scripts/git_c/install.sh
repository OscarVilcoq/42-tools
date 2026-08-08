#!/usr/bin/env bash
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

cat << 'EOF' > "$BIN_DIR/git-c"
#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Usage: git c <repo_url> [dossier_cible]"
    exit 1
fi

URL="$1"
TARGET="${2:-}"

if [ -n "$TARGET" ]; then
    git clone "$URL" "$TARGET"
    cd "$TARGET" || exit 1
else
    git clone "$URL"
    REPO_NAME=$(basename "$URL" .git)
    cd "$REPO_NAME" || exit 1
fi

# Création du .gitignore : ignore tout sauf les répertoires et les fichiers .c
cat << 'GITIGNORE' > .gitignore
# Ignorer tout par défaut
*

# Autoriser la traversée des dossiers
!*/

# Conserver uniquement les fichiers .c
!*.c
!**/*.c
GITIGNORE

echo "[OK] Projet cloné. .gitignore configuré (seuls les fichiers .c sont conservés)."
EOF

chmod +x "$BIN_DIR/git-c"
git config --global alias.c "!$BIN_DIR/git-c"
echo "Alias 'git c' configuré."