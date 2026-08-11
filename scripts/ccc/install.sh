#!/usr/bin/env bash
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# 1. Création du binaire 'ccc'
cat << 'EOF' > "$BIN_DIR/ccc"
#!/usr/bin/env bash

shopt -s nullglob
c_files=(*.c)

if [ ${#c_files[@]} -eq 0 ]; then
    echo -e "\033[0;31mErreur : Aucun fichier .c trouvé dans le dossier actuel.\033[0m"
    exit 1
fi

COMPILER="${CC:-cc}"
FLAGS=(-Wall -Wextra -Werror)

# Analyse des arguments : extraction de -x et détection du binaire de sortie (-o <nom>)
EXEC_FLAG=false
EXEC_NAME="a.out"
COMPILER_ARGS=()
skip_next=false

for arg in "$@"; do
    if [ "$skip_next" = true ]; then
        EXEC_NAME="$arg"
        COMPILER_ARGS+=("$arg")
        skip_next=false
        continue
    fi

    case "$arg" in
        -x)
            EXEC_FLAG=true
            ;;
        -o)
            COMPILER_ARGS+=("$arg")
            skip_next=true
            ;;
        -o*)
            EXEC_NAME="${arg#-o}"
            COMPILER_ARGS+=("$arg")
            ;;
        *)
            COMPILER_ARGS+=("$arg")
            ;;
    esac
done

echo "==> Compilation de ${#c_files[@]} fichier(s) .c..."
echo "$COMPILER ${FLAGS[*]} ${c_files[*]} ${COMPILER_ARGS[*]}"

if "$COMPILER" "${FLAGS[@]}" "${c_files[@]}" "${COMPILER_ARGS[@]}"; then
    echo -e "\033[0;32m==> Compilation réussie !\033[0m"
    
    # Exécution de la norminette
    echo -e "\n--- NORMINETTE ---"
    if command -v norminette &> /dev/null; then
        norminette
    else
        echo -e "\033[0;33mNorminette n'est pas installée.\033[0m"
    fi

    # Exécution automatique si -x est présent
    if [ "$EXEC_FLAG" = true ]; then
        if [ -x "./$EXEC_NAME" ]; then
            echo -e "\n\033[0;34m==> EXÉCUTION (./$EXEC_NAME) ---\033[0m"
            "./$EXEC_NAME"
            echo -e "\033[0;34m-----------------------------\033[0m"
        else
            echo -e "\n\033[0;31mErreur : Le binaire ./$EXEC_NAME est introuvable ou non exécutable.\033[0m"
        fi
    fi
else
    echo -e "\033[0;31m==> Erreur lors de la compilation.\033[0m"
    exit 1
fi
EOF

chmod +x "$BIN_DIR/ccc"

# Lien symbolique pour que 'c' fonctionne immédiatement
ln -sf "$BIN_DIR/ccc" "$BIN_DIR/c"

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
if ! grep -q "alias c=" "$SHELL_RC" 2>/dev/null; then
    echo "alias c=\"$BIN_DIR/ccc\"" >> "$SHELL_RC"
fi

echo "==> Commande 'ccc' mise à jour avec l'option -x."