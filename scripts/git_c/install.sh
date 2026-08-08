#!/usr/bin/env bash
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
 
cat << 'EOF' > "$BIN_DIR/git-c"
#!/usr/bin/env bash
 
NUM_EX=0
URL=""
TARGET=""
 
# Analyse des arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -n)
            NUM_EX="$2"
            shift 2
            ;;
        -[0-9]*)
            # Option du type -5
            NUM_EX="${1#-}"
            shift
            ;;
        *)
            # Si c'est un nombre pur (ex: 5)
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                NUM_EX="$1"
            elif [ -z "$URL" ]; then
                URL="$1"
            elif [ -z "$TARGET" ]; then
                TARGET="$1"
            fi
            shift
            ;;
    esac
done
 
if [ -z "$URL" ]; then
    echo "Usage: git c <repo_url> [dossier_cible] [-n N | -N | N]"
    exit 1
fi
 
if [ -n "$TARGET" ]; then
    git clone "$URL" "$TARGET" || exit 1
    cd "$TARGET" || exit 1
else
    git clone "$URL" || exit 1
    REPO_NAME=$(basename "$URL" .git)
    cd "$REPO_NAME" || exit 1
fi
 
# Création des dossiers ex0 à ex(N-1) si un nombre valide est fourni
if [ "$NUM_EX" -gt 0 ] 2>/dev/null; then
    for (( i=0; i<NUM_EX; i++ )); do
        mkdir -p "ex$i"
    done
    echo "[OK] $NUM_EX dossier(s) créé(s) : ex0 à ex$((NUM_EX-1))."
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