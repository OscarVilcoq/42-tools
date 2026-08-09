#!/usr/bin/env bash
BIN_DIR="$HOME/.local/bin"

echo "==> Désinstallation de 'ccc'..."

# 1. Suppression du binaire
if [ -f "$BIN_DIR/ccc" ]; then
    rm -f "$BIN_DIR/ccc"
    echo "✔ Binaire '$BIN_DIR/ccc' supprimé."
else
    echo "ℹ Binaire '$BIN_DIR/ccc' non trouvé."
fi

# 2. Détection du fichier Shell RC (.zshrc ou .bashrc)
SHELL_RC="${SHELL_RC:-$HOME/.bashrc}"
if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
fi

# 3. Suppression de l'alias dans le fichier RC
if [ -f "$SHELL_RC" ] && grep -q "alias c=" "$SHELL_RC" 2>/dev/null; then
    # Filtre la ligne contenant l'alias et met à jour le fichier
    grep -v "alias c=\"$BIN_DIR/ccc\"" "$SHELL_RC" > "$SHELL_RC.tmp" && mv "$SHELL_RC.tmp" "$SHELL_RC"
    echo "✔ Alias 'c' retiré de $SHELL_RC."
else
    echo "ℹ Aucun alias 'c' trouvé dans $SHELL_RC."
fi

echo -e "\n\033[0;32mDésinstallation terminée avec succès !\033[0m"