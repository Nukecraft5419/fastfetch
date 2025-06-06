#!/bin/bash

# === Info ===
VERSION="1.0.0"
YEAR="2025"

# === Colori ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# === Percorsi ===
CONFIG_DIR="$HOME/.config/fastfetch"
CONFIG_FILE="$CONFIG_DIR/config.jsonc"
BACKUP_DIR="$CONFIG_DIR/backups"
LOGO_DIR="$CONFIG_DIR/logo"
LOGO_FILE="$LOGO_DIR/catppuccin_logo.png"

# === Banner ASCII ===
catppuccin_banner() {
    echo -e "${MAGENTA}"
    echo "  "
    echo "   _____                 __    _____       __         .__       "
    echo " _/ ____\____    _______/  |__/ ____\_____/  |_  ____ |  |__    "
    echo "  \   __\\__  \  /  ___/\   __\   __\/ __ \   __\/ ___\|  |  \  "
    echo "   |  |   / __ \_\___ \  |  |  |  | \  ___/|  | \  \___|   Y  \ "
    echo "   |__|  (____  /____  > |__|  |__|  \___  >__|  \___  >___|  / "
    echo "              \/     \/                  \/          \/     \/  "
    echo "  "
    echo -e "${NC}"
    echo -e "   ${CYAN}Catppuccin Fastfetch Theme Manager v$VERSION — © $YEAR MIT License${NC}\n"
}

# === Help ===
print_help() {
    catppuccin_banner
    echo -e "${BLUE}Usage:${NC} ./install.sh [OPTION] [THEME]"
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo "  -l, --list            List available themes"
    echo "  -b, --list-backups    List backup config files"
    echo "  -u, --uninstall       Uninstall current theme and restore backup"
    echo "  -v, --version         Show version information"
    echo "  THEME                 Install a theme: Latte, Frappe, Macchiato, Mocha"
    echo
    read -n1 -r -p "Press any key to return to menu..." key
}

# === Version ===
print_version() {
    echo -e "Catppuccin Fastfetch Theme Manager v$VERSION — © $YEAR"
    echo
    read -n1 -r -p "Press any key to return to menu..." key
}

# === Conferma disinstallazione ===
confirm_uninstall() {
    echo -e "${YELLOW}⚠️  Are you sure you want to uninstall the Catppuccin Fastfetch theme? [y/N] ${NC}"
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY]) ;; # Procedi
        *) echo -e "${BLUE}ℹ️  Uninstall cancelled.${NC}"
            read -n1 -r -p "Press any key to return to menu..." key
        return 1 ;;
    esac
}

# === Ripristina ultimo backup ===
restore_backup() {
    if [[ -d "$BACKUP_DIR" && $(ls -1 "$BACKUP_DIR" | wc -l) -gt 0 ]]; then
        LAST_BACKUP=$(ls -1t "$BACKUP_DIR"/config_*.jsonc | head -n 1)
        cp "$LAST_BACKUP" "$CONFIG_FILE"
        echo -e "${GREEN}✅  Restored last backup: $(basename "$LAST_BACKUP")${NC}"
    else
        echo -e "${YELLOW}⚠️  No backups found. Removing config.jsonc.${NC}"
        rm -f "$CONFIG_FILE"
    fi
}

# === Pulisci file residui ===
cleanup_files() {
    [[ -f "$LOGO_FILE" ]] && rm -f "$LOGO_FILE" && echo -e "${GREEN}✅  Removed logo.${NC}"
    [[ -d "$LOGO_DIR" && -z "$(ls -A "$LOGO_DIR")" ]] && rmdir "$LOGO_DIR" && echo -e "${GREEN}✅  Removed empty logo directory.${NC}"
    [[ -d "$BACKUP_DIR" && -z "$(ls -A "$BACKUP_DIR")" ]] && rmdir "$BACKUP_DIR" && echo -e "${GREEN}✅  Removed empty backup directory.${NC}"
}

# === Disinstalla tema ===
uninstall_theme() {
    if ! confirm_uninstall; then
        return 0
    fi
    restore_backup
    cleanup_files
    echo -e "${BLUE}ℹ️  Uninstallation completed.${NC}"
    read -n1 -r -p "Press any key to return to menu..." key
}

# === Lista backup ===
list_backups() {
    echo -e "${MAGENTA}📂  Backups in $BACKUP_DIR:${NC}"
    ls "$BACKUP_DIR" 2>/dev/null || echo -e "${YELLOW}No backups found.${NC}"
    echo
    read -n1 -r -p "Press any key to return to menu..." key
}

# === Installa tema ===
install_theme() {
    THEME="$1"

    # Controlla file tema
    if [[ ! -f "themes/Catppuccin-$THEME/config.jsonc" ]]; then
        echo -e "${RED}❌  Theme file not found: themes/Catppuccin-$THEME/config.jsonc${NC}"
        read -n1 -r -p "Press any key to return to menu..." key
        return 0
    fi

    # Controlla logo
    if [[ ! -f "themes/Catppuccin-$THEME/logo/catppuccin_logo.png" ]]; then
        echo -e "${RED}❌  Logo file not found: themes/Catppuccin-$THEME/logo/catppuccin_logo.png${NC}"
        read -n1 -r -p "Press any key to return to menu..." key
        return 0
    fi

    # Crea directory se non esistono
    mkdir -p "$BACKUP_DIR" "$LOGO_DIR"

    # Backup
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    if [[ -f "$CONFIG_FILE" ]]; then
        cp "$CONFIG_FILE" "$BACKUP_DIR/config_$TIMESTAMP.jsonc"
        echo -e "${BLUE}📦  Backup created: config_$TIMESTAMP.jsonc${NC}"
    fi

    # Copia config e logo
    cp "themes/Catppuccin-$THEME/config.jsonc" "$CONFIG_FILE"
    cp "themes/Catppuccin-$THEME/logo/catppuccin_logo.png" "$LOGO_FILE"
    echo -e "${GREEN}✅  Installed theme flavor: $THEME${NC}"
    echo -e "${GREEN}✅  Logo installed to: $LOGO_FILE${NC}"
    echo
    read -n1 -r -p "Press any key to return to menu..." key
}

# === Menu interattivo ===
interactive_menu() {
    clear
    catppuccin_banner
    echo -e "${CYAN}Select a theme to install or an option:${NC}"
    echo -e "  ${GREEN}1)${NC} Install Latte flavor"
    echo -e "  ${YELLOW}2)${NC} Install Frappe flavor"
    echo -e "  ${BLUE}3)${NC} Install Macchiato flavor"
    echo -e "  ${RED}4)${NC} Install Mocha flavor"
    echo -e "  ${MAGENTA}5)${NC} List backups"
    echo -e "  ${CYAN}6)${NC} Uninstall theme"
    echo -e "  ${GREEN}7)${NC} Show version"
    echo -e "  ${YELLOW}8)${NC} Help"
    echo -e "  9) Exit"
    echo -n -e "${CYAN}Enter choice [1-9]: ${NC}"
    read -r choice
    clear
    case "$choice" in
        1) install_theme "Latte" ;;
        2) install_theme "Frappe" ;;
        3) install_theme "Macchiato" ;;
        4) install_theme "Mocha" ;;
        5) list_backups ;;
        6) uninstall_theme ;;
        7) print_version ;;
        8) print_help ;;
        9) echo -e "${CYAN}👋  Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}❌  Invalid choice.${NC}"
        read -n1 -r -p "Press any key to return to menu..." key ;;
    esac
}

# === MAIN ===
if [[ $# -eq 0 ]]; then
    while true; do
        interactive_menu
    done
else
    case "$1" in
        -h|--help)
            print_help
            exit 0
        ;;
        -v|--version)
            print_version
            exit 0
        ;;
        -l|--list)
            echo -e "${CYAN}Available themes:${NC} Latte, Frappe, Macchiato, Mocha"
            exit 0
        ;;
        -b|--list-backups)
            echo -e "${MAGENTA}📂  Backups in $BACKUP_DIR:${NC}"
            ls "$BACKUP_DIR" 2>/dev/null || echo -e "${YELLOW}No backups found.${NC}"
            exit 0
        ;;
        -u|--uninstall)
            uninstall_theme
            exit 0
        ;;
        Latte|Frappe|Macchiato|Mocha)
            install_theme "$1"
            exit 0
        ;;
        *)
            echo -e "${RED}❌  Invalid option or theme: $1${NC}"
            print_help
            exit 1
        ;;
    esac
fi
