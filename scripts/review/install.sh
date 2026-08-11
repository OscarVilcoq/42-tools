#!/usr/bin/env bash
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# 1. Création du binaire 'review'
cat << 'EOF' > "$BIN_DIR/review"
#!/usr/bin/env bash

if [ -z "$OV_42_TOOLS_REVIEWS_PATH" ]; then
    echo "Erreur : La variable OV_42_TOOLS_REVIEWS_PATH n'est pas définie."
    exit 1
fi

mkdir -p "$OV_42_TOOLS_REVIEWS_PATH"
cd "$OV_42_TOOLS_REVIEWS_PATH" || exit 1

echo "==> Nettoyage du dossier de reviews..."
rm -rf -- ..?* .[!.]* * 2>/dev/null || true

NORM=false
TREE=false
REPO_URL=""

# Analyse des arguments
for arg in "$@"; do
    case $arg in
        -n) NORM=true ;;
        -t) TREE=true ;;
        *)
            if [[ "$arg" =~ ^https?://|^git@ ]]; then
                REPO_URL="$arg"
            fi
            ;;
    esac
done

if [ -n "$REPO_URL" ]; then
    echo "==> Clonage de $REPO_URL..."
    git clone "$REPO_URL" target_review && \
    cd target_review && \
    code . || { echo "Erreur lors du clonage ou de l'ouverture de VS Code"; exit 1; }
fi

if [ "$NORM" = true ]; then
    echo -e "\n--- NORMINETTE ---"
    if command -v norminette &> /dev/null; then
        norminette
    else
        echo "Norminette n'est pas installée."
    fi
fi

if [ "$TREE" = true ]; then
    echo -e "\n--- TREE ---"
    if command -v tree &> /dev/null; then
        tree
    else
        find . -maxdepth 3 -not -path '*/.*'
    fi
fi

echo -e "\nEmplacement actuel : $(pwd)"

exec $SHELL
EOF

chmod +x "$BIN_DIR/review"

# Lien symbolique pour que 'r' fonctionne partout directement
ln -sf "$BIN_DIR/review" "$BIN_DIR/r"

# 2. Détection du Shell RC (.zshrc ou .bashrc)
if [ -n "$ZSH_VERSION" ] || [[ "$SHELL" == *"zsh"* ]] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
fi

# Export du PATH dans le Shell RC si non présent
if ! grep -q "$BIN_DIR" "$SHELL_RC" 2>/dev/null; then
    echo -e "\nexport PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
fi

# Ajout de l'alias
if ! grep -q "alias r=" "$SHELL_RC" 2>/dev/null; then
    echo "alias r=\"$BIN_DIR/review\"" >> "$SHELL_RC"
fi

echo "==> Commande 'review' et alias/lien 'r' installés dans $SHELL_RC."
echo "==> Pour utiliser 'r' immédiatement, lance : source $SHELL_RC"