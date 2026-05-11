#!/bin/bash
# ============================================================================
# ShadowOS Backup & Restore System
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'
YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'

BACKUP_DIR="/opt/ShadowOS/backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
error() { echo -e "  ${RED}✗${NC} $1"; }

# ─── Backup ─────────────────────────────────────────────────────────────
do_backup() {
    step "CREATING SHADOWOS BACKUP"
    mkdir -p "$BACKUP_DIR"
    
    local backup_file="$BACKUP_DIR/shadowos-backup-$TIMESTAMP.tar.gz"
    
    echo -e "${YELLOW}Backing up configurations...${NC}"
    
    # Create backup
    tar czf "$backup_file" \
        --exclude='*.cache' \
        --exclude='*.tmp' \
        --exclude='/tmp/*' \
        --exclude='/var/cache/*' \
        --exclude='/proc/*' \
        --exclude='/sys/*' \
        --exclude='/dev/*' \
        /etc/shadowos \
        /etc/nftables.conf \
        /etc/ssh/sshd_config.d \
        /etc/sysctl.d/99-shadowos*.conf \
        /etc/tor/torrc \
        /etc/wireguard \
        /etc/aide \
        /usr/share/sddm/themes/ShadowOS \
        /usr/share/plymouth/themes/shadowos \
        /opt/ShadowOS \
        $HOME/.config/hypr \
        $HOME/.config/kitty \
        $HOME/.config/alacritty \
        $HOME/.config/nvim \
        $HOME/.config/tmux \
        $HOME/.config/waybar \
        $HOME/.config/dunst \
        $HOME/.config/picom \
        $HOME/.config/gtk-3.0 \
        $HOME/.config/gtk-4.0 \
        $HOME/.local/share/plasma \
        $HOME/.p10k.zsh \
        $HOME/.zshrc \
        2>/dev/null
    
    if [ -f "$backup_file" ]; then
        success "Backup created: $backup_file"
        echo -e "  Size: $(du -h "$backup_file" | cut -f1)"
        
        # Create checksum
        sha256sum "$backup_file" > "${backup_file}.sha256"
        success "Checksum created"
    else
        error "Backup failed"
        return 1
    fi
}

# ─── Restore ────────────────────────────────────────────────────────────
do_restore() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        echo -e "${YELLOW}Available backups:${NC}"
        ls -la "$BACKUP_DIR"/*.tar.gz 2>/dev/null || echo "  No backups found"
        return 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
        return 1
    fi
    
    step "RESTORING SHADOWOS BACKUP"
    
    # Verify checksum
    if [ -f "${backup_file}.sha256" ]; then
        echo -e "${YELLOW}Verifying checksum...${NC}"
        if sha256sum -c "${backup_file}.sha256" 2>/dev/null; then
            success "Checksum verified"
        else
            error "Checksum mismatch!"
            return 1
        fi
    fi
    
    echo -e "${YELLOW}Restoring configurations...${NC}"
    tar xzf "$backup_file" -C / 2>&1 | head -20
    
    success "Backup restored from: $backup_file"
    echo -e "${YELLOW}Please reboot for changes to take effect${NC}"
}

# ─── List Backups ───────────────────────────────────────────────────────
list_backups() {
    step "AVAILABLE BACKUPS"
    if ls "$BACKUP_DIR"/*.tar.gz 1>/dev/null 2>&1; then
        ls -lah "$BACKUP_DIR"/*.tar.gz
    else
        echo "  No backups found in $BACKUP_DIR"
    fi
}

# ─── Main ───────────────────────────────────────────────────────────────
case "${1:-backup}" in
    backup)   do_backup ;;
    restore)  do_restore "$2" ;;
    list)     list_backups ;;
    *)
        echo "Usage: $0 {backup|restore <file>|list}"
        exit 1
        ;;
esac