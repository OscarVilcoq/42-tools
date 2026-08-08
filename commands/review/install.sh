cat << 'EOF' >> ~/.bashrc

# Variable d'environnement pour le dossier de review
export OV_42_TOOLS_REVIEWS_PATH="${OV_42_TOOLS_REVIEWS_PATH:-$HOME/review}"

review() {
    local run_norminette=false
    local run_tree=false
    local OPTIND opt

    # 1. Parsing des options -n et -t
    while getopts "nt" opt; do
        case "$opt" in
            n) run_norminette=true ;;
            t) run_tree=true ;;
            *) echo "Usage: r [-n] [-t] <git_url>"; return 1 ;;
        esac
    done
    shift $((OPTIND-1))

    local url="$1"
    local review_dir="${OV_42_TOOLS_REVIEWS_PATH:-$HOME/review}"

    if [ -z "$url" ]; then
        echo "Erreur : L'URL du dépôt Git est manquante."
        echo "Usage: r [-n] [-t] <git_url>"
        return 1
    fi

    # 2. Préparation du dossier (création + nettoyage total du contenu)
    mkdir -p "$review_dir"
    cd "$review_dir" || return
    find . -mindepth 1 -delete

    # 3. Clonage et exécution conditionnelle
    if git clone "$url"; then
        cd "$(basename "$url" .git)" || return

        if [ "$run_norminette" = true ]; then
            echo -e "\n=== 🛠️ RUNNING NORMINETTE ==="
            norminette
        fi

        if [ "$run_tree" = true ]; then
            echo -e "\n=== 📂 REPOSITORY TREE ==="
            tree
        fi

        code .
    else
        echo "Erreur : Le clonage du dépôt a échoué."
        return 1
    fi
}

alias r='review'

EOF

source ~/.bashrc