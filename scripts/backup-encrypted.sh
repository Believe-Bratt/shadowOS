#!/usr/bin/env bash
# ============================================================================
# ShadowOS Encrypted Backup Script
# Creates encrypted backups of system configuration and user data
# ============================================================================

set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
BOLD='\033[1m'

BACKUP_DIR="/opt/ShadowOS-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="shadowos-backup-${TIMESTAMP}"
ENCRYPTED_FILE="${BACKUP_DIR}/${BACKUP_NAME}.tar.gz.gpg"
LOG_FILE="/var/log/shadowos-backup.log"

log() { echo -e "$1" | tee -a "$LOG_FILE"; }
step() { log "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { log "  ${GREEN}✓${NC} $1"; }
warn() { log "  ${YELLOW}⚠${NC} $1"; }
info() { log "  ${BLUE}ℹ${NC} $1"; }

show_help() {
    echo -e "${BOLD}ShadowOS Encrypted Backup${NC}"
    echo ""
    echo "Usage: backup-encrypted [command]"
    echo ""
    echo "Commands:"
    echo "  create    — Create encrypted backup"
    echo "  restore   — Restore from encrypted backup"
    echo "  list      — List available backups"
    echo "  verify    — Verify backup integrity"
    echo "  cleanup   — Remove backups older than N days"
    echo "  export    — Export GPG key for backup decryption"
}

check_gpg() {
    if ! command -v gpg &>/dev/null; then
        echo -e "${RED}GPG not installed. Install with: apt install gnupg${NC}"
        exit 1
    fi
}

get_backup_key() {
    local key_id
    key_id=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep "sec" | head -1 | awk '{print $2}' | cut -d'/' -f2)

    if [ -z "$key_id" ]; then
        echo -e "${YELLOW}No GPG key found. Creating backup key...${NC}"
        # Generate a key non-interactively
        cat > /tmp/gpg-key-gen << 'GPGEOF'
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: ShadowOS Backup
Name-Email: backup@shadowos.local
Expire-Date: 2y
%commit
GPGEOF
        gpg --batch --gen-key /tmp/gpg-key-gen 2>/dev/null
        rm -f /tmp/gpg-key-gen
        key_id=$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep "sec" | head -1 | awk '{print $2}' | cut -d'/' -f2)

        if [ -z "$key_id" ]; then
            echo -e "${RED}Failed to generate GPG key${NC}"
            exit 1
        fi
        echo "  Generated key: $key_id"
    fi

    echo "$key_id"
}

create_backup() {
    step "CREATING ENCRYPTED BACKUP"
    check_gpg

    local key_id
    key_id=$(get_backup_key)
    info "Using GPG key: $key_id"

    mkdir -p "$BACKUP_DIR"

    # Create temporary directory for backup contents
    local tmp_dir
    tmp_dir=$(mktemp -d)

    info "Collecting system configuration..."

    # System configuration
    mkdir -p "$tmp_dir/etc"
    cp -a /etc/shadowos "$tmp_dir/etc/" 2>/dev/null || true
    cp -a /etc/nftables.conf "$tmp_dir/etc/" 2>/dev/null || true
    cp -a /etc/sysctl.d/99-shadowos*.conf "$tmp_dir/etc/" 2>/dev/null || true
    cp -a /etc/ssh/sshd_config.d "$tmp_dir/etc/" 2>/dev/null || true
    cp -a /etc/ssh/sshd_config "$tmp_dir/etc/" 2>/dev/null || true

    # ShadowOS custom files
    mkdir -p "$tmp_dir/opt/shadowos"
    cp -a /opt/ShadowOS/scripts "$tmp_dir/opt/shadowos/" 2>/dev/null || true
    cp -a /opt/ShadowOS/security-hardening "$tmp_dir/opt/shadowos/" 2>/dev/null || true
    cp -a /opt/ShadowOS/system-services "$tmp_dir/opt/shadowos/" 2>/dev/null || true

    # User configuration (if running as root with SUDO_USER)
    if [ -n "${SUDO_USER:-}" ] && [ -d "/home/$SUDO_USER" ]; then
        info "Collecting user configuration for: $SUDO_USER"
        mkdir -p "$tmp_dir/home/$SUDO_USER"
        cp -a /home/"$SUDO_USER"/.zshrc "$tmp_dir/home/$SUDO_USER/" 2>/dev/null || true
        cp -a /home/"$SUDO_USER"/.config "$tmp_dir/home/$SUDO_USER/" 2>/dev/null || true
        cp -a /home/"$SUDO_USER"/.ssh "$tmp_dir/home/$SUDO_USER/" 2>/dev/null || true
        cp -a /home/"$SUDO_USER"/.local/bin "$tmp_dir/home/$SUDO_USER/" 2>/dev/null || true
    fi

    # Package lists
    info "Recording package state..."
    dpkg --get-selections 2>/dev/null > "$tmp_dir/package-list.txt" || true

    # System state
    info "Recording system state..."
    {
        echo "=== ShadowOS Backup Manifest ==="
        echo "Date: $(date -Iseconds)"
        echo "Hostname: $(hostname)"
        echo "Kernel: $(uname -r)"
        echo "ShadowOS Version: $(cat /etc/shadowos/version 2>/dev/null || echo 'unknown')"
        echo ""
        echo "=== Files Included ==="
        find "$tmp_dir" -type f 2>/dev/null | head -100
    } > "$tmp_dir/MANIFEST.txt"

    # Create tarball
    info "Creating compressed archive..."
    local tarball="${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
    tar -czf "$tarball" -C "$tmp_dir" . 2>&1 | tee -a "$LOG_FILE"

    # Encrypt
    info "Encrypting backup with GPG..."
    gpg --batch --yes --trust-model always \
        --recipient "$key_id" \
        --encrypt \
        --output "$ENCRYPTED_FILE" \
        "$tarball" 2>&1 | tee -a "$LOG_FILE"

    # Verify
    if [ -f "$ENCRYPTED_FILE" ]; then
        local size=$(du -h "$ENCRYPTED_FILE" | cut -f1)
        success "Encrypted backup created: $ENCRYPTED_FILE ($size)"
    else
        fail "Failed to create encrypted backup"
    fi

    # Cleanup
    rm -rf "$tmp_dir"
    rm -f "$tarball"

    # Verify the backup
    verify_backup "$ENCRYPTED_FILE"
}

verify_backup() {
    local file="${1:-$ENCRYPTED_FILE}"
    step "VERIFYING BACKUP INTEGRITY"

    if [ ! -f "$file" ]; then
        fail "Backup file not found: $file"
        return 1
    fi

    # Check GPG integrity
    if gpg --batch --decrypt --output /dev/null "$file" 2>&1 | grep -q "gpg:"; then
        success "GPG signature: VALID"
    else
        warn "GPG signature: could not verify"
    fi

    local size=$(du -h "$file" | cut -f1)
    local date=$(stat -c %y "$file" 2>/dev/null | cut -d. -f1)
    log "  File: $file"
    log "  Size: $size"
    log "  Created: $date"
}

list_backups() {
    step "AVAILABLE BACKUPS"

    if [ ! -d "$BACKUP_DIR" ]; then
        info "No backup directory found at $BACKUP_DIR"
        return
    fi

    local count=0
    for f in "$BACKUP_DIR"/*.tar.gz.gpg; do
        [ -f "$f" ] || continue
        local size=$(du -h "$f" | cut -f1)
        local date=$(stat -c %y "$f" 2>/dev/null | cut -d. -f1)
        local name=$(basename "$f")
        log "  $name — $size — $date"
        ((count++))
    done

    if [ "$count" -eq 0 ]; then
        info "No encrypted backups found"
    else
        log "  Total: $count backup(s)"
    fi
}

restore_backup() {
    step "RESTORING FROM ENCRYPTED BACKUP"
    check_gpg

    local file="$1"
    if [ -z "$file" ]; then
        # Use latest backup
        file=$(ls -t "$BACKUP_DIR"/*.tar.gz.gpg 2>/dev/null | head -1)
        if [ -z "$file" ]; then
            fail "No backup file specified and no backups found"
            exit 1
        fi
    fi

    if [ ! -f "$file" ]; then
        fail "Backup file not found: $file"
        exit 1
    fi

    echo -e "${YELLOW}WARNING: This will overwrite current configuration!${NC}"
    read -rp "Continue? (yes/no): " confirm
    [ "$confirm" = "yes" ] || exit 0

    local tmp_dir
    tmp_dir=$(mktemp -d)

    info "Decrypting backup..."
    gpg --batch --decrypt --output "${tmp_dir}/backup.tar.gz" "$file"

    info "Extracting backup..."
    tar -xzf "${tmp_dir}/backup.tar.gz" -C "$tmp_dir"

    # Restore system configuration
    if [ -d "$tmp_dir/etc" ]; then
        info "Restoring /etc configuration..."
        cp -a "$tmp_dir/etc/"* /etc/ 2>/dev/null || true
    fi

    # Restore ShadowOS files
    if [ -d "$tmp_dir/opt/shadowos" ]; then
        info "Restoring /opt/ShadowOS..."
        mkdir -p /opt/ShadowOS
        cp -a "$tmp_dir/opt/shadowos/"* /opt/ShadowOS/ 2>/dev/null || true
    fi

    # Restore user configuration
    if [ -d "$tmp_dir/home" ]; then
        for user_dir in "$tmp_dir/home"/*/; do
            local user=$(basename "$user_dir")
            if [ -d "/home/$user" ]; then
                info "Restoring home for: $user"
                cp -a "$user_dir/"* "/home/$user/" 2>/dev/null || true
                chown -R "$user:$user" "/home/$user/" 2>/dev/null || true
            fi
        done
    fi

    # Cleanup
    rm -rf "$tmp_dir"

    success "Backup restored. Reboot recommended."
    echo "  Run: sudo reboot"
}

cleanup_old() {
    local days="${1:-30}"
    step "CLEANING OLD BACKUPS (older than $days days)"

    local count=0
    while IFS= read -r -d '' file; do
        rm -f "$file"
        info "Removed: $(basename "$file")"
        ((count++))
    done < <(find "$BACKUP_DIR" -name "*.tar.gz.gpg" -type f -mtime +"$days" -print0 2>/dev/null)

    if [ "$count" -eq 0 ]; then
        info "No old backups to clean"
    else
        success "Removed $count old backup(s)"
    fi
}

export_key() {
    step "EXPORTING GPG BACKUP KEY"
    check_gpg

    local key_id
    key_id=$(get_backup_key)
    local export_file="${BACKUP_DIR}/backup-key-${TIMESTAMP}.asc"

    mkdir -p "$BACKUP_DIR"
    gpg --armor --export "$key_id" > "$export_file"

    success "GPG key exported: $export_file"
    echo "  Store this file securely for backup decryption on other systems"
}

# Main
case "${1:-help}" in
    create)  create_backup ;;
    restore) restore_backup "$2" ;;
    list)    list_backups ;;
    verify)  verify_backup "$2" ;;
    cleanup) cleanup_old "${2:-30}" ;;
    export)  export_key ;;
    help|--help|-h) show_help ;;
    *)       echo -e "${RED}Unknown command: $1${NC}"; show_help; exit 1 ;;
esac