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

# Navigateur de dossiers interactif
browse_directory() {
    local current_dir="${1:-$HOME}"
    [ -d "$current_dir" ] || current_dir="$HOME"
    current_dir=$(cd "$current_dir" && pwd)

    while true; do
        clear
        echo -e "${BLUE}=== Sélection du dossier de review ===${NC}"
        echo -e "Dossier actuel : ${YELLOW}${current_dir}${NC}\n"

        # Liste des sous-dossiers non cachés
        local subdirs=()
        while IFS= read -r -d '' dir; do
            subdirs+=("$dir")
        done < <(find "$current_dir" -maxdepth 1 -mindepth 1 -type d ! -name ".*" -print0 2>/dev/null | sort -z)

        echo "0) [VALIDER CE DOSSIER]"
        echo ".. ) [Dossier parent]"
        echo -e "\n--- Sous-dossiers ---"

        local i=1
        for d in "${subdirs[@]}"; do
            echo "$i) $(basename "$d")/"
            ((i++))
        done

        echo ""
        read -r -p "Choix (0 pour valider, .. pour remonter, N° pour entrer) : " choice

        if [[ "$choice" == "0" ]]; then
            echo "$current_dir"
            return 0
        elif [[ "$choice" == ".." ]]; then
            current_dir=$(dirname "$current_dir")
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#subdirs[@]}" ]; then
            current_dir="${subdirs[$((choice-1))]}"
        else
            echo -e "${RED}Choix invalide.${NC}"
            sleep 1
        fi
    done
}

# Mise à jour de la variable de dossier dans le SHELL_RC et dans l'environnement
set_reviews_env_var() {
    local start_dir="${!VAR_NAME:-$HOME}"
    local new_path
    new_path=$(browse_directory "$start_dir")

    if [ -n "$new_path" ] && [ -d "$new_path" ]; then
        # Nettoyage de l'ancienne entrée dans SHELL_RC si elle existe
        if grep -q "$VAR_NAME=" "$SHELL_RC" 2>/dev/null; then
            local tmp_rc
            tmp_rc=$(mktemp)
            grep -v "$VAR_NAME=" "$SHELL_RC" > "$tmp_rc"
            mv "$tmp_rc" "$SHELL_RC"
        fi

        # Ajout de la nouvelle configuration
        echo "export $VAR_NAME=\"$new_path\"" >> "$SHELL_RC"
        export "$VAR_NAME"="$new_path"

        clear
        echo -e "${GREEN}[OK] Dossier de review défini sur : $new_path${NC}"
        echo -e "${GREEN}Mise à jour effectuée dans $SHELL_RC${NC}"
        sleep 1.5
    fi
}

# Configuration initiale au lancement
setup_reviews_env_var() {
    if [ -z "${!VAR_NAME}" ] || [ ! -d "${!VAR_NAME}" ]; then
        clear
        echo -e "${BLUE}=== Configuration Initiale ===${NC}"
        echo "Aucun dossier de review valide n'a été détecté."
        read -r -p "Appuyez sur Entrée pour choisir le dossier..."
        set_reviews_env_var
    fi
}

# Mise à jour du script manager.sh lui-même
update_manager() {
    local manager_url="${RAW_BASE_URL}/manager.sh"
    local script_path
    script_path="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0")"

    clear
    echo -e "${BLUE}==> Recherche de mise à jour pour manager.sh ...${NC}"

    if curl --output /dev/null --silent --head --fail "$manager_url"; then
        local tmp_file
        tmp_file=$(mktemp)
        if curl -sSL "$manager_url" -o "$tmp_file" && [ -s "$tmp_file" ]; then
            chmod +x "$tmp_file"
            mv "$tmp_file" "$script_path"
            echo -e "\n${GREEN}[OK] manager.sh a été mis à jour avec succès !${NC}"
            echo -e "${YELLOW}Redémarrage du script...${NC}"
            sleep 2
            exec "$script_path" "$@"
        else
            echo -e "\n${RED}[Erreur] Échec du téléchargement de la mise à jour.${NC}"
            rm -f "$tmp_file"
        fi
    else
        echo -e "\n${RED}[Erreur] Impossible de trouver manager.sh à l'URL : $manager_url${NC}"
    fi

    echo ""
    read -r -p "Appuyez sur Entrée pour continuer..."
}

# Exécution des scripts sur GitHub
execute_remote_script() {
    local action="$1" # install / uninstall
    local item="$2"   # folder, git_c, git_acp, review, git_retry
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
    echo "3) Commande git retry (Clone + Copy data)"
    echo "4) Commande review / r (Clean + Clone + Flags)"
    echo "5) Commande ccc / c (Compile ensemble tout les .c courant)"
    echo "6) Changer le dossier de review"
    echo "7) Mettre à jour manager.sh"
    echo "8) Exit"
    read -r -p "Sélectionnez une option (1-8) : " main_choice

    case $main_choice in
        1) show_submenu "Commande git c" "git_c" ;;
        2) show_submenu "Commande git acp" "git_acp" ;;
        3) show_submenu "Commande git retry" "git_retry" ;;
        4) show_submenu "Commande review (r)" "review" ;;
        5) show_submenu "Commande ccc (c)" "ccc" ;;
        6) set_reviews_env_var ;;
        7) update_manager ;;
        8)
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