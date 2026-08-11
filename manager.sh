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

# Liste complète des outils disponibles
ALL_ITEMS=("git_c" "git_acp" "git_retry" "review" "ccc")

get_item_label() {
    case "$1" in
        "git_c") echo "git c (Clone + .gitignore .c)" ;;
        "git_acp") echo "git acp (Add + Commit + Push)" ;;
        "git_retry") echo "git retry (Clone + Copy data)" ;;
        "review") echo "review / r (Clean + Clone + Flags)" ;;
        "ccc") echo "ccc / c (Compile tous les .c)" ;;
        *) echo "$1" ;;
    esac
}

detect_shell_rc() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "$HOME/.zshrc"
    else
        echo "$HOME/.bashrc"
    fi
}

SHELL_RC=$(detect_shell_rc)
BIN_DIR="$HOME/.local/bin"

# Détection précise de l'installation basée sur les scripts d'install
is_installed() {
    local item="$1"

    case "$item" in
        "git_c")
            [ -f "$BIN_DIR/git-c" ] || git config --global --get alias.c &>/dev/null
            ;;
        "git_acp")
            [ -f "$BIN_DIR/git-acp" ] || git config --global --get alias.acp &>/dev/null
            ;;
        "git_retry")
            [ -f "$BIN_DIR/git-retry" ] || git config --global --get alias.retry &>/dev/null
            ;;
        "review")
            [ -f "$BIN_DIR/review" ] || ( [ -f "$SHELL_RC" ] && grep -q "alias r=" "$SHELL_RC" 2>/dev/null )
            ;;
        "ccc")
            [ -f "$BIN_DIR/ccc" ] || ( [ -f "$SHELL_RC" ] && grep -q "alias c=" "$SHELL_RC" 2>/dev/null )
            ;;
        *)
            return 1
            ;;
    esac
}

# Navigateur de dossiers interactif
browse_directory() {
    local current_dir="${1:-$HOME}"
    [ -d "$current_dir" ] || current_dir="$HOME"
    current_dir=$(cd "$current_dir" && pwd)

    while true; do
        clear >&2
        echo -e "${BLUE}=== Sélection du dossier de review ===${NC}" >&2
        echo -e "Dossier actuel : ${YELLOW}${current_dir}${NC}\n" >&2

        local subdirs=()
        while IFS= read -r -d '' dir; do
            subdirs+=("$dir")
        done < <(find "$current_dir" -maxdepth 1 -mindepth 1 -type d ! -name ".*" -print0 2>/dev/null | sort -z)

        echo "0) [VALIDER CE DOSSIER]" >&2
        echo ".. ) [Dossier parent]" >&2
        echo -e "\n--- Sous-dossiers ---" >&2

        local i=1
        for d in "${subdirs[@]}"; do
            echo "$i) $(basename "$d")/" >&2
            ((i++))
        done

        echo "" >&2
        read -r -p "Choix (0 pour valider, .. pour remonter, N° pour entrer) : " choice

        if [[ "$choice" == "0" ]]; then
            echo "$current_dir"
            return 0
        elif [[ "$choice" == ".." ]]; then
            current_dir=$(dirname "$current_dir")
        elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#subdirs[@]}" ]; then
            current_dir="${subdirs[$((choice-1))]}"
        else
            echo -e "${RED}Choix invalide.${NC}" >&2
            sleep 1
        fi
    done
}

set_reviews_env_var() {
    local start_dir="${!VAR_NAME:-$HOME}"
    local new_path
    new_path=$(browse_directory "$start_dir")

    if [ -n "$new_path" ] && [ -d "$new_path" ]; then
        if grep -q "$VAR_NAME=" "$SHELL_RC" 2>/dev/null; then
            local tmp_rc
            tmp_rc=$(mktemp)
            grep -v "$VAR_NAME=" "$SHELL_RC" > "$tmp_rc"
            mv "$tmp_rc" "$SHELL_RC"
        fi

        echo "export $VAR_NAME=\"$new_path\"" >> "$SHELL_RC"
        export "$VAR_NAME"="$new_path"

        clear
        echo -e "${GREEN}[OK] Dossier de review défini sur : $new_path${NC}"
        echo -e "${GREEN}Mise à jour effectuée dans $SHELL_RC${NC}"
        sleep 1.5
    fi
}

setup_reviews_env_var() {
    if [ -z "${!VAR_NAME}" ] || [ ! -d "${!VAR_NAME}" ]; then
        clear
        echo -e "${BLUE}=== Configuration Initiale ===${NC}"
        echo "Aucun dossier de review valide n'a été détecté."
        read -r -p "Appuyez sur Entrée pour choisir le dossier..."
        set_reviews_env_var
    fi
}

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

execute_remote_script() {
    local action="$1" # install / uninstall
    local item="$2"
    local script_url="${RAW_BASE_URL}/scripts/${item}/${action}.sh"

    clear
    echo -e "${BLUE}==> Exécution de $action pour $item ...${NC}"

    if curl --output /dev/null --silent --head --fail "$script_url"; then
        curl -sSL "$script_url" | env "$VAR_NAME=${!VAR_NAME}" SHELL_RC="$SHELL_RC" bash
        echo -e "\n${GREEN}[OK] Opération '$action' terminée pour $item.${NC}"
    else
        echo -e "\n${RED}[Erreur] Impossible de trouver le script : $script_url${NC}"
    fi

    echo ""
    read -r -p "Appuyez sur Entrée pour continuer..."
}

execute_multiple_scripts() {
    local action="$1"
    shift
    local items=("$@")

    clear
    echo -e "${BLUE}==> Lancement de l'opération '$action' ...${NC}\n"

    for item in "${items[@]}"; do
        local script_url="${RAW_BASE_URL}/scripts/${item}/${action}.sh"
        echo -e "${BLUE}---> [$action] $item...${NC}"

        if curl --output /dev/null --silent --head --fail "$script_url"; then
            curl -sSL "$script_url" | env "$VAR_NAME=${!VAR_NAME}" SHELL_RC="$SHELL_RC" bash
            echo -e "${GREEN}[OK] $item ($action)${NC}\n"
        else
            echo -e "${RED}[Erreur] Impossible de trouver le script : $script_url${NC}\n"
        fi
    done

    echo -e "${GREEN}Opérations terminées !${NC}"
    echo ""
    read -r -p "Appuyez sur Entrée pour continuer..."
}

# --- MENU INSTALLATION ---
show_install_menu() {
    while true; do
        clear
        echo -e "${BLUE}--- [ Menu Installation ] ---${NC}"
        
        local idx=1
        for item in "${ALL_ITEMS[@]}"; do
            echo "$idx) $(get_item_label "$item")"
            ((idx++))
        done
        
        echo "$idx) Tout installer"
        local opt_all=$idx
        ((idx++))
        echo "$idx) Retour"
        local opt_back=$idx

        echo ""
        read -r -p "Choix (1-$opt_back) : " choice

        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -ge 1 ] && [ "$choice" -le "${#ALL_ITEMS[@]}" ]; then
                local selected_item="${ALL_ITEMS[$((choice-1))]}"
                execute_remote_script "install" "$selected_item"
            elif [ "$choice" -eq "$opt_all" ]; then
                execute_multiple_scripts "install" "${ALL_ITEMS[@]}"
            elif [ "$choice" -eq "$opt_back" ]; then
                break
            else
                echo -e "${RED}Choix invalide.${NC}"
                sleep 1
            fi
        else
            echo -e "${RED}Choix invalide.${NC}"
            sleep 1
        fi
    done
}

# --- MENU MISE À JOUR (Filtre dynamique des éléments installés) ---
show_update_menu() {
    while true; do
        clear
        echo -e "${BLUE}--- [ Menu Mise à Jour ] ---${NC}"

        local installed_items=()
        for item in "${ALL_ITEMS[@]}"; do
            if is_installed "$item"; then
                installed_items+=("$item")
            fi
        done

        if [ "${#installed_items[@]}" -eq 0 ]; then
            echo -e "${YELLOW}Aucune commande installée n'a été détectée à mettre à jour.${NC}\n"
            read -r -p "Appuyez sur Entrée pour retourner au menu..." dummy
            break
        fi

        local idx=1
        for item in "${installed_items[@]}"; do
            echo "$idx) $(get_item_label "$item")"
            ((idx++))
        done

        echo "$idx) Tout mettre à jour"
        local opt_all=$idx
        ((idx++))
        echo "$idx) Retour"
        local opt_back=$idx

        echo ""
        read -r -p "Choix (1-$opt_back) : " choice

        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -ge 1 ] && [ "$choice" -le "${#installed_items[@]}" ]; then
                local selected_item="${installed_items[$((choice-1))]}"
                execute_remote_script "install" "$selected_item"
            elif [ "$choice" -eq "$opt_all" ]; then
                execute_multiple_scripts "install" "${installed_items[@]}"
            elif [ "$choice" -eq "$opt_back" ]; then
                break
            else
                echo -e "${RED}Choix invalide.${NC}"
                sleep 1
            fi
        else
            echo -e "${RED}Choix invalide.${NC}"
            sleep 1
        fi
    done
}

# --- MENU DÉSINSTALLATION (Filtre dynamique des éléments installés) ---
show_uninstall_menu() {
    while true; do
        clear
        echo -e "${BLUE}--- [ Menu Désinstallation ] ---${NC}"

        local installed_items=()
        for item in "${ALL_ITEMS[@]}"; do
            if is_installed "$item"; then
                installed_items+=("$item")
            fi
        done

        if [ "${#installed_items[@]}" -eq 0 ]; then
            echo -e "${YELLOW}Aucune commande installée n'a été détectée.${NC}\n"
            read -r -p "Appuyez sur Entrée pour retourner au menu..." dummy
            break
        fi

        local idx=1
        for item in "${installed_items[@]}"; do
            echo "$idx) $(get_item_label "$item")"
            ((idx++))
        done

        echo "$idx) Tout désinstaller"
        local opt_all=$idx
        ((idx++))
        echo "$idx) Retour"
        local opt_back=$idx

        echo ""
        read -r -p "Choix (1-$opt_back) : " choice

        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -ge 1 ] && [ "$choice" -le "${#installed_items[@]}" ]; then
                local selected_item="${installed_items[$((choice-1))]}"
                execute_remote_script "uninstall" "$selected_item"
            elif [ "$choice" -eq "$opt_all" ]; then
                execute_multiple_scripts "uninstall" "${installed_items[@]}"
            elif [ "$choice" -eq "$opt_back" ]; then
                break
            else
                echo -e "${RED}Choix invalide.${NC}"
                sleep 1
            fi
        else
            echo -e "${RED}Choix invalide.${NC}"
            sleep 1
        fi
    done
}

# Démarrage
setup_reviews_env_var

while true; do
    clear
    echo -e "${BLUE}=== 42-TOOLS MANAGER ===${NC}"
    echo -e "Variable $VAR_NAME = ${YELLOW}${!VAR_NAME}${NC}\n"
    echo "1) Installer une commande"
    echo "2) Mettre à jour des commandes"
    echo "3) Désinstaller une commande"
    echo "4) Changer le dossier de review"
    echo "5) Mettre à jour manager.sh"
    echo "6) Exit"
    read -r -p "Sélectionnez une option (1-6) : " main_choice

    case $main_choice in
        1) show_install_menu ;;
        2) show_update_menu ;;
        3) show_uninstall_menu ;;
        4) set_reviews_env_var ;;
        5) update_manager ;;
        6)
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