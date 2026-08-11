# 🛠️ Shell & Git Productivity Tools

Une suite d'outils CLI légers et d'outils d'extension Git conçus pour accélérer le workflow quotidien des développeurs (notamment dans un environnement d'apprentissage du C / École 42).

[![Bash Shell Script](https://img.shields.io/badge/Language-Bash-4EAA25.svg?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📋 Table des matières

- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Utilisation](#-utilisation)
  - [Compilation C (`ccc` / `c`)](#1-compilation-c-ccc--c)
  - [Git Quick Add, Commit & Push (`git acp`)](#2-git-quick-add-commit--push-git-acp)
  - [Git Clone & Initialisation de projet C (`git c`)](#3-git-clone--initialisation-de-projet-c-git-c)
  - [Git Retry (`git retry`)](#4-git-retry-git-retry)
  - [Gestion de Reviews (`review` / `r`)](#5-gestion-de-reviews-review--r)
- [Désinstallation](#-désinstallation)
- [Structure du dépôt](#-structure-du-dépôt)

---

## ✨ Fonctionnalités

* **Compilation C Simplifiée (`ccc`)** : Compile automatiquement tous les fichiers `.c` d'un dossier avec les flags stricts (`-Wall -Wextra -Werror`).
* **Git Add / Commit / Push Rapide (`git acp`)** : Automatise l'enchaînement standard d'enregistrement et d'envoi des modifications sur Git.
* **Initialisation Automatique de Projet (`git c`)** : Clone un dépôt, prépare les dossiers d'exercices (`ex00`, `ex01`...) et configure un `.gitignore` prêt pour le C.
* **Sauvegarde & Clone Sécurisé (`git retry`)** : Clone un projet dans un dossier adjacent et copie l'état de votre répertoire courant avec préservation stricte des métadonnées (droits, liens, attributs).
* **Environnement de Review / Peer-Evaluation (`review`)** : Nettoie un espace de travail dédié, clone un dépôt distant, ouvre VS Code, et lance automatiquement `norminette` ou `tree`.

---

## ⚙️ Prérequis

* Un environnement UNIX/Linux ou macOS avec **Bash**.
* **Git** installe sur le système.
* Assurez-vous que `$HOME/.local/bin` est bien présent dans votre variable d'environnement `$PATH`.

---

## 🚀 Installation

Chaque outil dispose de son propre script d'installation dans le dossier d'installation correspondant. Pour installer un outil spécifique, exécutez son script d'installation depuis la racine du projet :

```bash
# Exemple pour installer la commande de compilation 'ccc'
./install_ccc.sh

# Exemple pour installer l'alias 'git acp'
./install_git_acp.sh
```