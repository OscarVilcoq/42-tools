 dans le dossier de review et le nettoie
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