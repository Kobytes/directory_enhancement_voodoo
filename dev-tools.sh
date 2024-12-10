#!/bin/bash

# Version du script
VERSION="1.0.2"

# Couleurs pour les outputs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'


# Validation du dossier Dev
validate_dev_directory() {
    local base_dir=$get_base_dir
    if [ ! -d "$base_dir" ]; then
        echo -e "${RED}Le dossier Dev n'existe pas. Exécutez 'dev init' d'abord.${NC}"
        return 1
    fi
}

get_github_username() {
    local config_file="$get_base_dir/tools/configs/github_username"
    if [ -f "$config_file" ]; then
        cat "$config_file"
    else
        echo ""
    fi
}

configure_github() {
    local github_username=$1
    local config_dir="$get_base_dir/tools/configs"
    
    mkdir -p "$config_dir"
    echo "$github_username" > "$config_dir/github_username"
    echo -e "${GREEN}GitHub username configuré: $github_username${NC}"
}

save_dev_directory() {
  if [ -e "$state_file" ]; then
     sed -i '/^get_base_dir/d' $state_file
  fi
    echo "get_base_dir=$base_dir" >> $state_file
}

init_dev_directory() {
    local custom_path=$1
    local base_dir

    if [ -z "$custom_path" ]; then
        base_dir="$HOME/Dev"
        echo -e "${BLUE}Initialisation du dossier Dev dans l'emplacement par défaut: $base_dir${NC}"
    else
        base_dir=$(realpath "$custom_path/Dev")
        echo -e "${BLUE}Initialisation du dossier Dev dans: $base_dir${NC}"
    fi
    save_dev_directory "$base_dir"

    echo -e "${YELLOW}Création de la structure des dossiers...${NC}"
    mkdir -p "$base_dir"/{projects/{active,archived,ideas},learning/{tutorials,experiments,courses},forks/{contributions,reference},tools/{scripts,configs},sandbox/temp}

    local config_dir="$base_dir/tools/configs"
    mkdir -p "$config_dir"
    echo "$base_dir" > "$config_dir/base_path"

    if ! command -v mise &> /dev/null; then
    echo -e "${YELLOW}Installation de mise...${NC}"
    curl https://mise.run | sh
    
    echo -e "${YELLOW}Configuration de mise trust...${NC}"
    mise trust
    
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "mise activate bash" "$HOME/.bashrc"; then
            echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
            echo 'eval "$(mise completion bash)"' >> ~/.bashrc
        fi
    fi
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "mise activate zsh" "$HOME/.zshrc"; then
            echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
            echo 'eval "$(mise completion zsh)"' >> ~/.zshrc
        fi
    fi
fi

    cat > "$base_dir/.mise.toml" << EOL
[env]
EDITOR = "code"

[tools]
node = "latest"
bun = "latest"
python = "latest"

[tasks]
list = "dev list all"
backup = "dev backup"
clean = "dev clean"
EOL

mise trust "$base_dir/.mise.toml"

    cat > "$base_dir/.gitignore" << EOL
# Dependencies
node_modules/
.pnp
.pnp.js
.yarn/install-state.gz

# Testing
coverage/
.nyc_output

# Next.js
.next/
out/

# Production
build/
dist/
*.tsbuildinfo

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# System files
.DS_Store
*.pem

# IDE
.idea/
.vscode/
*.swp
*.swo

# Vercel
.vercel

# Turborepo
.turbo

# PWA files
public/sw.js
public/workbox-*.js
EOL

    cat > "$base_dir/README.md" << EOL
# Directory Enhancement Voodoo (DEV)

Structure de développement créée le $(date)

## Structure des dossiers

\`\`\`
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
\`\`\`

## Commandes disponibles

Utilisez \`dev help\` pour voir toutes les commandes disponibles.
EOL

    echo -e "${GREEN}✓ Structure Dev créée avec succès${NC}"
    echo -e "${YELLOW}Configuration requise :${NC}"
    echo -e "1. ${BLUE}Ajoutez la fonction suivante dans votre fichier de configuration shell :${NC}"
    echo -e "   ${BLUE}Pour bash : ~/.bashrc${NC}"
    echo -e "   ${BLUE}Pour zsh  : ~/.zshrc${NC}"
    echo
    echo -e "${CYAN}# Configuration pour dev-tools"
    echo "dev() {"
    echo "    # Fonction pour récupérer le base_dir"
    echo "    get_base_dir() {"
    echo "        local config_file=\"\$HOME/Dev/tools/configs/base_path\""
    echo "        if [ -f \"\$config_file\" ]; then"
    echo "            cat \"\$config_file\""
    echo "        else"
    echo "            echo \"\$HOME/Dev\""
    echo "        fi"
    echo "    }"
    echo
    echo "    if [ \"\$1\" = \"goto\" ] && [ -n \"\$2\" ]; then"
    echo "        local base_dir=\$get_base_dir"
    echo "        local found=false"
    echo "        local project_path=\"\""
    echo "        local folders=("
    echo "            \"projects/active\""
    echo "            \"projects/archived\""
    echo "            \"learning/experiments\""
    echo "            \"learning/tutorials\""
    echo "            \"forks/contributions\""
    echo "            \"forks/reference\""
    echo "        )"
    echo
    echo "        for folder in \"\${folders[@]}\"; do"
    echo "            if [ -d \"\$base_dir/\$folder/\$2\" ]; then"
    echo "                found=true"
    echo "                project_path=\"\$base_dir/\$folder/\$2\""
    echo "                break"
    echo "            fi"
    echo "        done"
    echo
    echo "        if [ \"\$found\" = true ]; then"
    echo "            cd \"\$project_path\""
    echo "            echo -e \"\\033[0;32mDéplacé vers: \$project_path\\033[0m\""
    echo "            return 0"
    echo "        else"
    echo "            echo -e \"\\033[0;31mProjet '\$2' non trouvé\\033[0m\""
    echo "            return 1"
    echo "        fi"
    echo "    else"
    echo "        \"\$get_base_dir/tools/scripts/dev-tools.sh\" \"\$@\""
    echo "    fi"
    echo "}"
    echo -e "${NC}"
    echo
    echo -e "2. ${BLUE}Redémarrez votre terminal ou exécutez :${NC}"
    echo -e "   ${CYAN}source ~/.bashrc${NC} ${BLUE}ou${NC} ${CYAN}source ~/.zshrc${NC}"
    
    mkdir -p "$base_dir/tools/scripts"
    cp "$0" "$base_dir/tools/scripts/dev-tools.sh"
    chmod +x "$base_dir/tools/scripts/dev-tools.sh"
}

check_environment() {
    local env_type=$1
    local version=${2:-latest}
    
    if ! command -v mise &> /dev/null; then
        echo -e "${RED}mise n'est pas installé. Installation nécessaire.${NC}"
        return 1
    fi
    
    if ! mise which "$env_type" &> /dev/null; then
        read -p "L'environnement $env_type n'est pas installé. Voulez-vous l'installer ? (Y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            mise use --global "$env_type@$version"
            
            # Recharge l'environnement mise
            eval "$(~/.local/bin/mise activate bash)"
            
            # Vérifie si l'installation a réussie
            if ! command -v "$env_type" &> /dev/null; then
                echo -e "${YELLOW}Installation réussie mais redémarrage du shell nécessaire.${NC}"
                echo -e "${YELLOW}Veuillez exécuter :${NC}"
                echo -e "${CYAN}source ~/.bashrc${NC} ${BLUE}ou${NC} ${CYAN}source ~/.zshrc${NC}"
                echo -e "${YELLOW}puis réessayez la commande.${NC}"
                return 1
            fi
        else
            echo -e "${RED}Installation annulée. Impossible de continuer.${NC}"
            return 1
        fi
    fi
    
    # Double vérification que la commande est disponible
    if ! command -v "$env_type" &> /dev/null; then
        echo -e "${YELLOW}L'environnement $env_type n'est pas activé.${NC}"
        echo -e "${YELLOW}Veuillez exécuter :${NC}"
        echo -e "${CYAN}source ~/.bashrc${NC} ${BLUE}ou${NC} ${CYAN}source ~/.zshrc${NC}"
        return 1
    fi
    
    return 0
}

create_project() {
    local project_name=$1
    local project_type=$2
    local template=$3
    local base_dir=$get_base_dir
    local target_dir
    
    case $project_type in
        "personal")
            target_dir="$base_dir/projects/active/$project_name"
            ;;
        "learn")
            target_dir="$base_dir/learning/experiments/$project_name"
            ;;
        "fork")
            target_dir="$base_dir/forks/reference/$project_name"
            ;;
        *)
            echo -e "${RED}Type de projet invalide. Utilisez: personal, learn, ou fork${NC}"
            return 1
    esac

    # Vérification de l'environnement avant la création
    if [ -n "$template" ]; then
        case $template in
            "next"|"node")
                check_environment "node" || return 1
                ;;
            "bun")
                check_environment "bun" || return 1
                ;;
        esac
    fi

    mkdir -p "$target_dir"
    cd "$target_dir"
    git init
    
    echo "# $project_name" > README.md
    echo "Created on: $(date)" >> README.md
    echo "Project type: $project_type" >> README.md
    
    if [ -n "$template" ]; then
        case $template in
            "next")
                npx create-next-app@latest .
                ;;
            "node")
                npm init -y
                ;;
            "bun")
                bun init
                ;;
            *)
                echo -e "${RED}Template inconnu. Création d'un projet basique.${NC}"
                cp "$base_dir/.gitignore" .gitignore
                ;;
        esac
    else
        cp "$base_dir/.gitignore" .gitignore
    fi

    echo -e "${GREEN}Projet créé dans: $target_dir${NC}"
}

goto_project() {
    local project_name=$1
    local base_dir=$get_base_dir
    local found=false
    local project_path=""

    # Recherche dans tous les dossiers possibles
    local folders=(
        "projects/active"
        "projects/archived"
        "learning/experiments"
        "learning/tutorials"
        "forks/contributions"
        "forks/reference"
    )

    for folder in "${folders[@]}"; do
        if [ -d "$base_dir/$folder/$project_name" ]; then
            found=true
            project_path="$base_dir/$folder/$project_name"
            break
        fi
    done

    if [ "$found" = true ]; then
        cd "$project_path"
        echo -e "${GREEN}Déplacé vers: $project_path${NC}"
        return 0
    else
        echo -e "${RED}Projet '$project_name' non trouvé${NC}"
        return 1
    fi
}

archive_project() {
    local project_name=$1
    local base_dir=$get_base_dir
    
    if [ -d "$base_dir/projects/active/$project_name" ]; then
        mv "$base_dir/projects/active/$project_name" "$base_dir/projects/archived/"
        echo -e "${GREEN}Projet $project_name archivé${NC}"
    else
        echo -e "${RED}Projet non trouvé dans active/${NC}"
    fi
}

list_projects() {
    local base_dir=$get_base_dir
    local category=$1

    echo -e "${BLUE}=== Listage des projets ===${NC}"
    
    case $category in
        "active")
            echo -e "${YELLOW}Projets actifs:${NC}"
            ls -l "$base_dir/projects/active"
            ;;
        "archived")
            echo -e "${YELLOW}Projets archivés:${NC}"
            ls -l "$base_dir/projects/archived"
            ;;
        "learning")
            echo -e "${YELLOW}Projets d'apprentissage:${NC}"
            ls -l "$base_dir/learning/experiments"
            ;;
        "all")
            echo -e "${YELLOW}Projets actifs:${NC}"
            ls -l "$base_dir/projects/active"
            echo -e "\n${YELLOW}Projets archivés:${NC}"
            ls -l "$base_dir/projects/archived"
            echo -e "\n${YELLOW}Projets d'apprentissage:${NC}"
            ls -l "$base_dir/learning/experiments"
            ;;
        *)
            echo -e "${RED}Catégorie invalide. Utilisez: active, archived, learning, ou all${NC}"
            return 1
    esac
}

search_projects() {
    local search_term=$1
    local base_dir=$get_base_dir
    
    echo -e "${BLUE}Recherche de '$search_term' dans les projets...${NC}"
    
    find "$base_dir" -type f \
        ! -path "*/node_modules/*" \
        ! -path "*/.git/*" \
        ! -path "*/dist/*" \
        ! -path "*/build/*" \
        ! -path "*/.next/*" \
        -exec grep -l "$search_term" {} \;
}

clone_github() {
    local repo_url=$1
    local repo_name=$(basename "$repo_url" .git)
    local base_dir=$get_base_dir
    local github_user=$(echo "$repo_url" | grep -oP 'github.com/\K[^/]+')
    local configured_user=$(get_github_username)
    
    if [ -z "$configured_user" ]; then
        echo -e "${YELLOW}GitHub username non configuré. Utilisez 'dev configure-github <username>'${NC}"
        return 1
    fi

    if [ "$github_user" = "$configured_user" ]; then
        target_dir="$base_dir/forks/contributions/$repo_name"
        echo -e "${BLUE}Détecté comme votre projet personnel${NC}"
    else
        target_dir="$base_dir/forks/reference/$repo_name"
        echo -e "${BLUE}Détecté comme projet externe${NC}"
    fi

    mkdir -p "$(dirname "$target_dir")"
    git clone "$repo_url" "$target_dir"
    
    if [ "$github_user" != "$configured_user" ]; then
        echo -e "\n## Reference Project" >> "$target_dir/README.md"
        echo "Original repository: $repo_url" >> "$target_dir/README.md"
        echo "Cloned on: $(date)" >> "$target_dir/README.md"
    fi
    
    echo -e "${GREEN}Repository cloné dans: $target_dir${NC}"
}

backup_dev() {
    local base_dir=$get_base_dir
    local backup_dir="$HOME/Dev_backups/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    rsync -av --progress "$base_dir/" "$backup_dir/" \
        --exclude 'node_modules' \
        --exclude '.next' \
        --exclude 'dist' \
        --exclude '.git' \
        --exclude 'build' \
        --exclude 'coverage' \
        --exclude '.turbo'
    
    echo -e "${GREEN}Backup créé dans: $backup_dir${NC}"
}

clean_node_modules() {
    local base_dir=$get_base_dir
    local space_before=$(du -sh "$base_dir" | cut -f1)
    
    find "$base_dir" -name "node_modules" -type d -prune -exec rm -rf '{}' +
    
    local space_after=$(du -sh "$base_dir" | cut -f1)
    echo -e "${GREEN}Nettoyage terminé. Espace libéré: avant=$space_before, après=$space_after${NC}"
}

setup_environment() {
    local env_type=$1
    local version=$2
    
    case $env_type in
        "node"|"python"|"ruby"|"golang"|"rust"|"bun"|"deno"|"java"|"erlang"|"zig")
            ;;
        *)
            echo -e "${RED}Type d'environnement non supporté: $env_type${NC}"
            echo -e "Types supportés: node, python, ruby, golang, rust, bun, deno, java, erlang, zig"
            return 1
            ;;
    esac

    if ! command -v mise &> /dev/null; then
    echo -e "${YELLOW}Installation de mise...${NC}"
    curl https://mise.run | sh
    
    if [ -f "$HOME/.bashrc" ]; then
        echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
        echo 'eval "$(mise completion bash)"' >> ~/.bashrc
    fi
    if [ -f "$HOME/.zshrc" ]; then
        echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
        echo 'eval "$(mise completion zsh)"' >> ~/.zshrc
    fi
    
    echo -e "${YELLOW}Redémarrez votre terminal ou exécutez 'source ~/.bashrc' ou 'source ~/.zshrc'${NC}"
    return
fi

    if [ -z "$version" ]; then
        echo -e "${BLUE}Configuration de $env_type (dernière version)${NC}"
        mise use --global "$env_type@latest"
    else
        echo -e "${BLUE}Configuration de $env_type version $version${NC}"
        mise use --global "$env_type@$version"
    fi

    local project_indicators=("package.json" "Cargo.toml" "go.mod" "requirements.txt" "Gemfile" "build.gradle" "pom.xml")
    for indicator in "${project_indicators[@]}"; do
        if [ -f "$(pwd)/$indicator" ]; then
            if [ ! -f "$(pwd)/.mise.toml" ]; then
                cat > "$(pwd)/.mise.toml" << EOL
[env]
NODE_ENV = "development"

[tools]
$env_type = "${version:-latest}"

[tasks]
start = "npm start"
dev = "npm run dev"
test = "npm test"
build = "npm run build"
EOL
            else
                mise use "$env_type@${version:-latest}" --path "$(pwd)"
            fi
            echo -e "${GREEN}Configuration locale du projet mise à jour${NC}"
            break
        fi
    done

    echo -e "${GREEN}✓ Installation et configuration terminées${NC}"
    if [ -n "$version" ]; then
        echo -e "${BLUE}$env_type $version est maintenant actif${NC}"
    else
        echo -e "${BLUE}$env_type (dernière version) est maintenant actif${NC}"
    fi
    echo -e "${YELLOW}Utilisez 'mise list' pour voir les versions installées${NC}"
}

show_help() {
    echo -e "${BLUE}DEV: Directory Enhancement Voodoo v${VERSION}${NC}"
    echo -e "${PURPLE}────────────────────────────────────────${NC}"
    echo "Usage:"
    echo -e "${CYAN}Configuration${NC}"
    echo "  init [path]                     - Initialise la structure Dev (optionnel: chemin personnalisé)"
    echo "  configure-github <username>     - Configure votre username GitHub"
    echo
    echo -e "${CYAN}Gestion des projets${NC}"
    echo "  create-project <name> <type> [template] - Crée un nouveau projet"
    echo "    Types: personal, learn, fork"
    echo "    Templates: next, node, bun"
    echo "  archive <project-name>          - Archive un projet actif"
    echo "  list <category>                 - Liste les projets (active/archived/learning/all)"
    echo "  goto <project-name>             - Se déplace vers le dossier du projet"
    echo
    echo -e "${CYAN}Environnements (mise)${NC}"
    echo "  setup-env <type> [version]      - Configure un environnement de développement"
    echo "    Types supportés:"
    echo "      - node, bun, deno          - Environnements JavaScript"
    echo "      - python, ruby, rust        - Langages principaux"
    echo "      - golang, java              - Langages compilés"
    echo "      - erlang, zig              - Autres langages"
    echo
    echo -e "${CYAN}Git et GitHub${NC}"
    echo "  clone <github-url>              - Clone un repo GitHub"
    echo
    echo -e "${CYAN}Utilitaires${NC}"
    echo "  search <term>                   - Recherche dans tous les projets"
    echo "  backup                          - Crée un backup du dossier Dev"
    echo "  clean                           - Nettoie les node_modules"
    echo "  version                         - Affiche la version du script"
}


# load config
state_file_name="dev-tools"
state_file="$HOME/.local/state/$state_file_name"
if [ -f "$state_file" ]; then
  source "$state_file"
else
  get_base_dir="$HOME/Dev"
fi

# Menu principal
case $1 in
    "init")
        init_dev_directory "$2"
        ;;
    "create-project")
        validate_dev_directory && create_project "$2" "$3" "$4"
        ;;
    "archive")
        validate_dev_directory && archive_project "$2"
        ;;
    "list")
        validate_dev_directory && list_projects "$2"
        ;;
    "search")
        validate_dev_directory && search_projects "$2"
        ;;
    "clone")
        validate_dev_directory && clone_github "$2"
        ;;
    "configure-github")
        validate_dev_directory && configure_github "$2"
        ;;
    "setup-env")
        setup_environment "$2" "$3"
        ;;
    "backup")
        validate_dev_directory && backup_dev
        ;;
    "clean")
        validate_dev_directory && clean_node_modules
        ;;
    "goto")
        validate_dev_directory && goto_project "$2"
        ;;
    "completion")
        generate_completion
        ;;
    "version")
        echo -e "${BLUE}DEV version ${VERSION}${NC}"
        ;;
    *)
        show_help
        ;;
esac
