# 🧙‍♂️ Directory Enhancement Voodoo (DEV)

DEV est un outil en ligne de commande conçu pour simplifier et standardiser l'organisation de votre environnement de développement. Il crée et maintient une structure cohérente pour vos projets, automatise les tâches courantes, et intègre les meilleures pratiques de développement.

## ✨ Caractéristiques

### 📁 Organisation Structurée
- Structure de dossiers standardisée pour tous vos projets
- Séparation claire entre projets actifs, archivés, et apprentissage
- Gestion automatisée des forks GitHub
- Organisation intuitive des outils et configurations

### 🛠️ Gestion des Environnements
- Intégration native avec [mise](https://mise.jdx.dev/) pour la gestion des versions
- Support pour de nombreux langages et environnements :
  - JavaScript : Node.js, Bun, Deno
  - Langages principaux : Python, Ruby, Rust
  - Langages compilés : Go, Java
  - Autres : Erlang, Zig
- Configuration automatique des environnements par projet

### 🚀 Fonctionnalités

- **Gestion de Projets**
  - Création de projets avec templates (Next.js, Node.js, Bun)
  - Navigation rapide entre les projets
  - Système d'archivage intégré
  - Recherche globale dans les projets

- **Intégration GitHub**
  - Clonage intelligent (différenciation contributions/références)
  - Configuration automatique des dépôts
  - Organisation des forks

- **Utilitaires**
  - Système de backup automatisé
  - Nettoyage des dépendances
  - Recherche dans le code

## 🚀 Installation

### Méthode 1 : Clone depuis GitHub
```bash
git clone https://github.com/Kobytes/directory_enhancement_voodoo.git
cd directory_enhancement_voodoo
chmod +x install.sh
./install.sh
```

### Méthode 2 : Installation manuelle
1. Clonez le script dans votre dossier de scripts :
```bash
mkdir -p ~/scripts
curl -o ~/scripts/dev-tools.sh https://raw.githubusercontent.com/Kobytes/directory_enhancement_voodoo/main/dev-tools.sh
chmod +x ~/scripts/dev-tools.sh
```

2. Ajoutez la fonction suivante à votre `.bashrc` ou `.zshrc` :
```bash
dev() {
    # Fonction pour récupérer le base_dir
    get_base_dir() {
        local config_file="$HOME/Dev/tools/configs/base_path"
        if [ -f "$config_file" ]; then
            cat "$config_file"
        else
            echo "$HOME/Dev"
        fi
    }

    if [ "$1" = "goto" ] && [ -n "$2" ]; then
        local base_dir=$(get_base_dir)
        local found=false
        local project_path=""
        local folders=(
            "projects/active"
            "projects/archived"
            "learning/experiments"
            "learning/tutorials"
            "forks/contributions"
            "forks/reference"
        )

        for folder in "${folders[@]}"; do
            if [ -d "$base_dir/$folder/$2" ]; then
                found=true
                project_path="$base_dir/$folder/$2"
                break
            fi
        done

        if [ "$found" = true ]; then
            cd "$project_path"
            echo -e "\033[0;32mDéplacé vers: $project_path\033[0m"
            return 0
        else
            echo -e "\033[0;31mProjet '$2' non trouvé\033[0m"
            return 1
        fi
    else
        "$(get_base_dir)/tools/scripts/dev-tools.sh" "$@"
    fi
}
```

3. Initialisez l'environnement :
```bash
dev init
```

## 📖 Utilisation

### Configuration Initiale
```bash
# Initialisation de base
dev init

# Initialisation avec chemin personnalisé
dev init /chemin/personnalisé

# Configuration GitHub
dev configure-github <username>
```

### Gestion des Projets
```bash
# Création de projet
dev create-project mon-projet personal next
dev create-project test-app learn node
dev create-project demo fork bun

# Navigation
dev goto mon-projet

# Listage des projets
dev list active
dev list all

# Archivage
dev archive ancien-projet
```

### Gestion des Environnements
```bash
# Installation d'environnements
dev setup-env node 18
dev setup-env python latest
dev setup-env bun latest
```

### Utilitaires
```bash
# Recherche
dev search "terme"

# Backup
dev backup

# Nettoyage
dev clean
```

## 📁 Structure des Dossiers

```
Dev/
├── projects/              # Projets personnels
│   ├── active/           # Projets en cours
│   ├── archived/         # Projets terminés
│   └── ideas/            # Idées de projets
├── learning/             # Apprentissage
│   ├── tutorials/        # Tutoriels suivis
│   ├── experiments/      # Tests et expérimentations
│   └── courses/          # Cours en ligne
├── forks/                # Projets GitHub
│   ├── contributions/    # Vos projets
│   └── reference/        # Projets externes
├── tools/                # Outils
│   ├── scripts/          # Scripts utilitaires
│   └── configs/          # Configurations
└── sandbox/              # Tests rapides
    └── temp/            # Fichiers temporaires
```

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Signaler des bugs
- Proposer des nouvelles fonctionnalités
- Soumettre des pull requests