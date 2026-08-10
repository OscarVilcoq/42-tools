#!/usr/bin/env bash
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

cat << 'EOF' > "$BIN_DIR/git-retry"
#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
    echo "Usage: git retry <url_repo> [nom_pour_rename]"
    exit 1
fi

REPO_URL="$1"

# Si un nom personnalisé est fourni, on l'utilise, sinon on extrait le nom depuis l'URL
if [ -n "$2" ]; then
    TARGET_NAME="$2"
else
    TARGET_NAME=$(basename "$REPO_URL" .git)
fi

TARGET_PATH="../$TARGET_NAME"

if [ -d "$TARGET_PATH" ]; then
    echo "Erreur : Le dossier destination '$TARGET_PATH' existe déjà."
    exit 1
fi

echo "Clonage de $REPO_URL dans $TARGET_PATH..."
git clone "$REPO_URL" "$TARGET_PATH"

echo "Copie avec préservation stricte de l'intégrité des données..."

if command -v rsync >/dev/null 2>&1; then
    # -a : archive (droits, timestamps, liens symboliques, proprio, groupes)
    # -H : préserve les liens physiques (hard links)
    # -A : préserve les ACLs
    # -X : préserve les attributs étendus
    rsync -aHAX --exclude='.git' ./ "$TARGET_PATH/"
else
    # Secours UNIX universel : le pipe tar garantit la préservation exacte des métadonnées
    tar --exclude='.git' -cf - . | (cd "$TARGET_PATH" && tar -xf -)
fi

echo "Opération terminée ! Les données et leurs métadonnées ont été copiées sans altération."
EOF

chmod +x "$BIN_DIR/git-retry"
git config --global alias.retry "!$BIN_DIR/git-retry"
echo "Alias 'git retry' configuré."