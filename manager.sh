#!/usr/bin/env bash

# Arrête le script si une commande échoue brutalement
set -e

# Couleurs pour le terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# CONFIGURATION GITHUB
GITHUB_USER="OscarVilcoq"
GITHUB_REPO="42-tools"
GITHUB_BRANCH="main"
RAW_BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

VAR_NAME="OV_42_TOOLS_REVIEWS_PATH"

# Détection du fichier de configuration du Shell utilisateur
detect_shell_rc() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "$HOME/.zshrc"
    else
        echo "$HOME/.bashrc"
    fi
}

SHELL_RC=$(detect_shell_rc)

# 1. Gestion de la variable d'environnement OV_42_TOOLS_REVIEWS_PATH
setup_reviews_env_var() {
    # Vérifie si la variable est déjà définie dans l'environnement actuel
    if [ -n "${!VAR_NAME}" ]; then
        REVIEWS_PATH="${!VAR_NAME}"
    else
        echo -e "${BLUE}=== Configuration Initiale ===${NC}"
        read -r -p "Entrez l'emplacement du dossier de reviews : " input_dir
        # Remplacement du ~ par $HOME
        REVIEWS_PATH="${input_dir/#\~/$HOME}"
        
        # Ajout de la variable dans le fichier rc s'il n'y est pas déjà
        if ! grep -q "$VAR_NAME=" "$SHELL_RC" 2>/dev/null; then
            echo -e "\n# Variable d'environnement pour Reviews Tools" >> "$SHELL_RC"
            echo "export $VAR_NAME=\"$REVIEWS_PATH\"" >> "$SHELL_RC"
            echo -e "${GREEN}Variable $VAR_NAME ajoutée à $SHELL_RC${NC}"
        fi
        
        # Export pour la session courante du script
        export "$VAR_NAME"="$REVIEWS_PATH"
    fi
}

# 2. Fonction générique de téléchargement et d'exécution depuis GitHub
execute_remote_script() {
    local action="$1" # install ou uninstall
    local item="$2"   # folder, git_c, git_acp, review
    local script_url="${RAW_BASE_URL}/commands/${item}/${action}.sh"

    echo -e "${BLUE}==> Récupération de $script_url ...${NC}"

    # Vérification que le fichier existe bien sur GitHub (code HTTP 200)
    if curl --output /dev/null --silent --head --fail "$script_url"; then
        # Télécharge et exécute le script distant en passant les variables d'environnement utiles
        curl -sSL "$script_url" | env "$VAR_NAME=${!VAR_NAME}" bash
        echo -e "${GREEN}[OK] Opération '$action' terminée pour '$item'.${NC}"
    else
        echo -e "${RED}[Erreur] Impossible de trouver le script distant : $script_url${NC}"
    fi
}

# 3. Sous-menu (Installer / Désinstaller / Retour)
show_submenu() {
    local name="$1"
    local id="$2"

    while true; do
        echo -e "\n${BLUE}--- [ Option : $name ] ---${NC}"
        echo "1) Installer"
        echo "2) Désinstaller"
        echo "3) Retour"
        read -r -p "Choisissez une action (1-3) : " sub_choice

        case $sub_choice in
            1)
                execute_remote_script "install" "$id"
                ;;
            2)
                execute_remote_script "uninstall" "$id"
                ;;
            3)
                break
                ;;
            *)
                echo -e "${RED}Option invalide.${NC}"
                ;;
        esac
    done
}

# --- Démarrage du Script ---
setup_reviews_env_var

while true; do
    echo -e "\n${BLUE}=== MENU PRINCIPAL ===${NC}"
    echo -e "Variable $VAR_NAME = ${YELLOW}${!VAR_NAME}${NC}"
    echo "1) Dossier de reviews"
    echo "2) Commande git c"
    echo "3) Commande git acp"
    echo "4) Commande review"
    echo "5) Exit"
    read -r -p "Sélectionnez une option (1-5) : " main_choice

    case $main_choice in
        1)
            show_submenu "Dossier de reviews" "folder"
            ;;
        2)
            show_submenu "Commande git c" "git_c"
            ;;
        3)
            show_submenu "Commande git acp" "git_acp"
            ;;
        4)
            show_submenu "Commande review" "review"
            ;;
        5)
            echo -e "${GREEN}Au revoir !${NC}"
            echo -e "${YELLOW}Note : Rechargez votre terminal ou lancez 'source $SHELL_RC' pour appliquer la variable d'environnement sur le terminal principal.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Choix invalide. Veuillez réessayer.${NC}"
            ;;
    esac
done