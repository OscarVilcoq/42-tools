#!/usr/bin/env bash
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# 1. Création du binaire 'ccc'
cat << 'EOF' > "$BIN_DIR/ccc"
#!/usr/bin/env bash

# Utilisation de nullglob pour éviter d'obtenir "*.c" littéral si aucun fichier n'existe
shopt -s nullglob
c_files=(*.c)

if [ ${#c_files[@]} -eq 0 ]; then
    echo "Erreur : Aucun fichier .c trouvé dans le dossier actuel."
    exit 1
fi

COMPILER="${CC:-cc}"
FLAGS=(-Wall -Wextra -Werror)

echo "==> Compilation de ${#c_files[@]} fichier(s) .c..."
echo "$COMPILER ${FLAGS[*]} ${c_files[*]} $@"

"$COMPILER" "${FLAGS[@]}" "${c_files[@]}" "$@"

if [ $? -eq 0 ]; then
    echo -e "\033[0;32m==> Compilation réussie !\033[0m"
else
    echo -e "\033[0;31m==> Erreur lors de la compilation.\033[0m"
    exit 1
fi
EOF

chmod +x "$BIN_DIR/ccc"

# 2. Ajout de l'alias 'c' dans le fichier shell RC
SHELL_RC="${SHELL_RC:-$HOME/.bashrc}"

# Détection automatique de zsh si présent
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

if ! grep -q "alias c=" "$SHELL_RC" 2>/dev/null; then
    echo "alias c=\"$BIN_DIR/ccc\"" >> "$SHELL_RC"
fi

echo "Commande 'ccc' et alias 'c' installés."