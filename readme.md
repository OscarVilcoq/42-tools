# 🛠️ 42-Tools

Un ensemble d'outils en ligne de commande et de scripts d'automatisation conçus pour simplifier la gestion des projets et le workflow de correction/peer-learning à **42**.

---

## 🚀 Installation rapide

Lancez l'installateur interactif en une seule commande dans votre terminal apres l'installation du fichier manager.sh:

```bash
bash manager.sh
```

> **Note :** Une fois l'installation terminée, pensez à recharger votre configuration shell ou à ouvrir un nouveau terminal pour activer la variable d'environnement :
> ```bash
> source ~/.bashrc   # Ou ~/.zshrc selon votre shell
> ```

---

## ⚙️ Fonctionnalités & Commandes

L'interface interactive (`manager.sh`) vous permet de configurer et d'installer/désinstaller indépendamment les modules suivants :

### 1. 📁 Configuration du dossier de Reviews
Lors de la première utilisation, le script vous demande l'emplacement de votre dossier dédié aux corrections. Il enregistre ce chemin dans la variable d'environnement utilisateur :
```bash
OV_42_TOOLS_REVIEWS_PATH="/chemin/vers/votre/dossier"
```

---

### 2. 📑 Commande `git c` (Init avec `.gitignore` C)
Permet de cloner un dépôt et de générer automatiquement un fichier `.gitignore` restrictif adapté aux projets en C.

* **Fonctionnement :** Ignore l'intégralité des fichiers du projet **sauf** l'arborescence des dossiers et les fichiers d'extension `.c`.
* **Utilisation :**
  ```bash
  git c <repo_url> [nom_du_dossier]
  ```

---

### 3. 🚀 Commande `git acp` (Add, Commit & Push)
Une commande rapide pour stager, commiter et pusher vos modifications en une seule étape.

* **Utilisation avec message personnalisé :**
  ```bash
  git acp "Fix norminette et retours de correction"
  ```
* **Utilisation par défaut** *(message : `"Update"`)* :
  ```bash
  git acp
  ```

---

### 4. 🔍 Commande `review` (Alias `r`)
Un outil complet pour préparer votre environnement de correction en un instant.

* **Fonctionnement :**
  1. Se déplace dans le dossier configuré (`OV_42_TOOLS_REVIEWS_PATH`).
  2. **Nettoie entièrement** le contenu du dossier de correction.
  3. Clone le dépôt du corrigé *(si une URL est fournie)* et entre dans le répertoire.
  4. Exécute les options passées par drapeaux (flags).

* **Options / Flags :**
  * `-n` : Exécute `norminette` automatiquement.
  * `-t` : Affiche l'arborescence des fichiers avec `tree`.

* **Exemples d'utilisation :**
  ```bash
  # Nettoie le dossier, clone le projet et lance norminette + tree
  r https://github.com/votre-peer/projet.git -n -t

  # Se déplace juste dans le dossier de review et le nettoie
  r
  ```

---

## 📂 Structure du dépôt

```text
42-tools/
├── README.md
├── manager.sh              # Script principal du menu interactif
└── scripts/
    ├── folder/             # Gestion du dossier de review
    │   ├── install.sh
    │   └── uninstall.sh
    ├── git_c/              # Module 'git c'
    │   ├── install.sh
    │   └── uninstall.sh
    ├── git_acp/            # Module 'git acp'
    │   ├── install.sh
    │   └── uninstall.sh
    └── review/             # Module 'review / r'
        ├── install.sh
        └── uninstall.sh
```

---

## 🗑️ Désinstallation

Pour supprimer un module spécifique ou la variable d'environnement, relancez simplement l'installateur :

```bash
curl -sSL https://raw.githubusercontent.com/OscarVilcoq/42-tools/main/manager.sh | bash
```
Sélectionnez le composant souhaité dans le menu, puis choisissez l'option **Désinstaller**.
