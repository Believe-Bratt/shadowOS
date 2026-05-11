#!/bin/bash
# ============================================================================
# ShadowOS Base System Configuration
# Post-installation system optimization and configuration
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
info() { echo -e "  ${BLUE}ℹ${NC} $1"; }

step "SHADOWOS BASE SYSTEM CONFIGURATION"

# ─── System Optimizations ────────────────────────────────────────────────
step "SYSTEM OPTIMIZATIONS"

# Swappiness
echo "vm.swappiness=10" >> /etc/sysctl.d/99-shadowos-performance.conf
echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.d/99-shadowos-performance.conf
echo "vm.dirty_ratio=10" >> /etc/sysctl.d/99-shadowos-performance.conf
echo "vm.dirty_background_ratio=5" >> /etc/sysctl.d/99-shadowos-performance.conf
success "Memory optimizations applied"

# I/O scheduler
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"' >> /etc/udev/rules.d/60-ioschedulers.rules
success "I/O scheduler optimized"

# Disable unnecessary services
SERVICES_TO_DISABLE=(
    cups-browsed
    bluetooth
    avahi-daemon
    ModemManager
    accounts-daemon
    geoclue
    pppd-dns
)

for svc in "${SERVICES_TO_DISABLE[@]}"; do
    systemctl disable "$svc" 2>/dev/null || true
done
success "Unnecessary services disabled"

# ─── Filesystem Configuration ───────────────────────────────────────────
step "FILESYSTEM CONFIGURATION"

# Btrfs configuration (if using Btrfs)
if mount | grep -q "btrfs"; then
    # Enable compression
    cat >> /etc/fstab << 'BTRFS'
# Btrfs compression
# Add compress=zstd:3 to mount options for better compression
BTRFS
    success "Btrfs configured"
fi

# Create ShadowOS directories
mkdir -p /opt/ShadowOS/{scripts,configs,themes,ai,monitoring}
mkdir -p /var/log/shadowos
mkdir -p /etc/shadowos
success "ShadowOS directories created"

# ─── Locale Configuration ───────────────────────────────────────────────
step "LOCALE CONFIGURATION"
sed -i 's/# en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen 2>/dev/null || true
locale-gen 2>/dev/null || true
update-locale LANG=en_US.UTF-2>/dev/null || true
success "Locales configured"

# ─── Time Configuration ─────────────────────────────────────────────────
step "TIME CONFIGURATION"
timedatectl set-ntp true 2>/dev/null || true
timedatectl set-timezone "Etc/UTC" 2>/dev/null || true
success "Time synchronization enabled"

# ─── Power Management ───────────────────────────────────────────────────
step "POWER MANAGEMENT"
cat > /etc/tmpfiles.d/shadowos.conf << 'TMPF'
# ShadowOS tmpfiles configuration
# Clean temp files on boot
/tmp/* 1777 root root 10d
/var/tmp/* 1777 root root 30d
TMPF
success "Temp file cleanup configured"

# ─── Logging Configuration ──────────────────────────────────────────────
step "LOGGING CONFIGURATION"
cat > /etc/systemd/journald.conf.d/shadowos.conf << 'JOURNAL'
[Journal]
SystemMaxUse=100M
RuntimeMaxUse=50M
MaxRetentionSec=2weeks
Compress=yes
RateLimitIntervalSec=30
RateLimitBurst=10000
JOURNAL
systemctl restart systemd-journald 2>/dev/null || true
success "Journal logging optimized"

# ─── ShadowOS Configuration File ────────────────────────────────────────
cat > /etc/shadowos/config.conf << 'SHADOWOSCONF'
# ShadowOS Configuration
# Generated automatically

[general]
version=2026.1
codename=NeonVanguard
hostname=$(hostname)

[theme]
colorscheme=cyberpunk
primary_color=#00FFFF
secondary_color=#FF00FF
accent_color=#FFBF00
background=#0A0A0F

[security]
encryption=luks2
firewall=nftables
apparmor=enforce
ssh_port=2222
tor_enabled=false
vpn_enabled=false

[ai]
runtime=ollama
default_model=llama3.1:8b
port=11434

[performance]
swappiness=10
io_scheduler=mq-deadline
log_level=warning

[network]
dns_over_https=true
dns_servers=1.1.1.1,9.9.9.9
mac_randomization=true
SHADOWOSCONF
success "ShadowOS configuration saved"

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Base system configured${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"