#!/usr/bin/env bash

set -e

# Couleurs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Dépôt GitHub
GITHUB_USER="OscarVilcoq"
GITHUB_REPO="42-tools"
GITHUB_BRANCH="main"
RAW_BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

VAR_NAME="OV_42_TOOLS_REVIEWS_PATH"

detect_shell_rc() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "$HOME/.zshrc"
    else
        echo "$HOME/.bashrc"
    fi
}

SHELL_RC=$(detect_shell_rc)

# Configuration de la variable d'environnement utilisateur
setup_reviews_env_var() {
    if [ -n "${!VAR_NAME}" ]; then
        REVIEWS_PATH="${!VAR_NAME}"
    else
        clear
        echo -e "${BLUE}=== Configuration Initiale ===${NC}"
        read -r -p "Entrez l'emplacement absolu du dossier de reviews : " input_dir
        REVIEWS_PATH="${input_dir/#\~/$HOME}"
        
        if ! grep -q "$VAR_NAME=" "$SHELL_RC" 2>/dev/null; then
            echo -e "\n# 42-tools configuration" >> "$SHELL_RC"
            echo "export $VAR_NAME=\"$REVIEWS_PATH\"" >> "$SHELL_RC"
            echo -e "${GREEN}Variable $VAR_NAME ajoutée à $SHELL_RC${NC}"
        fi
        
        export "$VAR_NAME"="$REVIEWS_PATH"
    fi
}

# Exécution des scripts sur GitHub
execute_remote_script() {
    local action="$1" # install / uninstall
    local item="$2"   # folder, git_c, git_acp, review
    local script_url="${RAW_BASE_URL}/scripts/${item}/${action}.sh"

    clear
    echo -e "${BLUE}==> Exécution de $action pour $item ...${NC}"

    if curl --output /dev/null --silent --head --fail "$script_url"; then
        curl -sSL "$script_url" | env "$VAR_NAME=${!VAR_NAME}" SHELL_RC="$SHELL_RC" bash
        echo -e "\n${GREEN}[OK] Opération '$action' terminée.${NC}"
    else
        echo -e "\n${RED}[Erreur] Impossible de trouver le script : $script_url${NC}"
    fi

    echo ""
    read -r -p "Appuyez sur Entrée pour continuer..."
}

show_submenu() {
    local name="$1"
    local id="$2"

    while true; do
        clear
        echo -e "${BLUE}--- [ Option : $name ] ---${NC}"
        echo "1) Installer"
        echo "2) Désinstaller"
        echo "3) Retour"
        read -r -p "Choix (1-3) : " sub_choice

        case $sub_choice in
            1) execute_remote_script "install" "$id" ;;
            2) execute_remote_script "uninstall" "$id" ;;
            3) break ;;
            *) 
                echo -e "${RED}Option invalide.${NC}"
                sleep 1
                ;;
        esac
    done
}

# Démarrage
setup_reviews_env_var

while true; do
    clear
    echo -e "${BLUE}=== 42-TOOLS MANAGER ===${NC}"
    echo -e "Variable $VAR_NAME = ${YELLOW}${!VAR_NAME}${NC}\n"
    echo "1) Commande git c (Clone + .gitignore .c)"
    echo "2) Commande git acp (Add + Commit + Push)"
    echo "3) Commande review / r (Clean + Clone + Flags)"
    echo "4) Exit"
    read -r -p "Sélectionnez une option (1-4) : " main_choice

    case $main_choice in
        1) show_submenu "Commande git c" "git_c" ;;
        2) show_submenu "Commande git acp" "git_acp" ;;
        3) show_submenu "Commande review (r)" "review" ;;
        4)
            clear
            echo -e "${GREEN}Au revoir ! Pensez à exécuter 'source $SHELL_RC' dans votre terminal.${NC}"
            exit 0
            ;;
        *) 
            echo -e "${RED}Choix invalide.${NC}"
            sleep 1
            ;;
    esac
done