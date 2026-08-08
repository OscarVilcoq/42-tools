# 🛠️ 42 Tools

Ce guide explique comment installer et utiliser 3 raccourcis puissants pour cloner, configurer, sauvegarder et réviser vos projets de code (optimisés pour l'école 42).

## 🚀 Installation Rapide

Copiez et collez ces trois commandes dans votre terminal pour installer les outils :

```bash
# 1. Raccourci de création de projet
git config --global alias.c '!f() { git clone "\(1" && cd "\)(basename "\$1" .git)" && echo -e "*\n!*/\n!*/*.c" > .gitignore && for i in \$(seq 0 "2"); do mkdir -p "exi"; done && tree && code .; }; f'

# 2. Raccourci de sauvegarde rapide
git config --global alias.cmp '!f() { git add -A && git commit -m "\$1" && git push; }; f'

# 3. Outil de revue et correction
cat << 'EOF' >> ~/.bashrc
r() {
    rm -rf ~/review/* && cd ~/review || return
    if git clone "\$1"; then
        cd "\$(basename "\$1" .git)" || return
        echo -e "\n=== 🛠️ RUNNING NORMINETTE ==="
        norminette
        echo -e "\n=== 📂 REPOSITORY TREE ==="
        tree
        code .
    else
        echo "Erreur : Le clonage du dépôt a échoué."
    fi
}
EOF
source ~/.bashrc
```

---

## 📖 Utilisation des Commandes

### 1. `git c` (Clone & Setup)
Permet d'initialiser instantanément un nouveau projet de code.
* **Ce qu'elle fait :**
  * Clone le dépôt Git.
  * Entre dans le dossier.
  * Crée un `.gitignore` qui n'autorise que les fichiers `.c`.
  * Génère automatiquement les dossiers d'exercices (ex00, ex01, etc.).
  * Affiche l'arborescence et ouvre VS Code.
* **Syntaxe :** `git c <lien_du_depot> <nombre_d_exercices>`
* **Exemple :** `git c git@github.com:user/piscine.git 5` *(crée de ex00 à ex05)*

### 2. `git cmp` (Commit & Push)
Permet de sauvegarder tout votre travail sur GitHub/GitLab en une seule ligne.
* **Ce qu'elle fait :**
  * Ajoute tous les fichiers modifiés ou nouveaux (`git add -A`).
  * Crée un commit avec votre message personnalisé (`git commit -m`).
  * Envoie le tout sur le dépôt distant (`git push`).
* **Syntaxe :** `git cmp "<votre_message>"`
* **Exemple :** `git cmp "ft_putchar fonctionne"`

### 3. `r` (Review & Correction)
Permet de tester et corriger proprement le code d'un camarade dans un dossier temporaire dédié.
* **Ce qu'elle fait :**
  * Vide complètement votre dossier `~/review/` pour repartir à neuf.
  * Clone le dépôt de la personne à corriger.
  * Lance automatiquement la **Norminette** pour vérifier le style.
  * Affiche l'arborescence des fichiers reçus.
  * Ouvre le projet dans VS Code pour votre analyse.
* **Syntaxe :** `r <lien_du_depot_a_corriger>`
* **Exemple :** `r git@github.com:camarade/projet.git`
