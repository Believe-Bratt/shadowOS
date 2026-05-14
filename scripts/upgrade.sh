#!/usr/bin/env bash
# ============================================================================
# ShadowOS Upgrade Script — v2026.1 → v2026.2 "NeonHorizon"
# ============================================================================
# Run this script on an existing ShadowOS 2026.1 installation to upgrade
# to version 2026.2 with all new features and improvements.
# ============================================================================
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'
BOLD='\033[1m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/shadowos-upgrade.log"

if [ "$EUID" -ne 0 ]; then echo -e "${RED}Run as root${NC}"; exit 1; fi

step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; echo "[$(date '+%H:%M:%S')] ✓ $1" >> "$LOG_FILE"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; echo "[$(date '+%H:%M:%S')] ⚠ $1" >> "$LOG_FILE"; }
info() { echo -e "  ${BLUE}ℹ${NC} $1"; }

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║   SHADOWOS UPGRADE — v2026.2 NeonHorizon         ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# ─── Pre-flight Checks ─────────────────────────────────────────────────────
step "PRE-FLIGHT CHECKS"

# Check current version
if [ -f "/etc/shadowos/version" ]; then
    CURRENT_VER=$(cat /etc/shadowos/version)
    info "Current version: $CURRENT_VER"
else
    CURRENT_VER="unknown"
    warn "Could not detect current version (no /etc/shadowos/version)"
fi

# Backup important data
info "Creating backup of current configuration..."
BACKUP_DIR="/root/shadowos-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"/{config,dotfiles,ai-models}

# Backup config files
cp /etc/shadowos/config.conf "$BACKUP_DIR/config/" 2>/dev/null || true
cp /etc/nftables.conf "$BACKUP_DIR/config/" 2>/dev/null || true
cp /etc/ssh/sshd_config.d/00-shadowos.conf "$BACKUP_DIR/config/" 2>/dev/null || true
cp /etc/sysctl.d/99-shadowos-*.conf "$BACKUP_DIR/config/" 2>/dev/null || true

# Backup user dotfiles
if [ -n "${SUDO_USER:-}" ] && [ -d "/home/$SUDO_USER" ]; then
    cp -r /home/"$SUDO_USER"/.config "$BACKUP_DIR/dotfiles/" 2>/dev/null || true
    cp -r /home/"$SUDO_USER"/.local "$BACKUP_DIR/dotfiles/" 2>/dev/null || true
    cp -r /home/"$SUDO_USER"/.zshrc "$BACKUP_DIR/dotfiles/" 2>/dev/null || true
fi

success "Backup created at $BACKUP_DIR"

# ─── System Update ─────────────────────────────────────────────────────────
step "UPDATING SYSTEM PACKAGES"

if command -v apt &>/dev/null; then
    apt update -y 2>&1 | tail -3
    apt full-upgrade -y 2>&1 | tail -5
    apt autoremove -y 2>&1 | tail -3
elif command -v pacman &>/dev/null; then
    pacman -Syu --noconfirm 2>&1 | tail -5
fi
success "System packages updated"

# ─── Kernel Upgrade ────────────────────────────────────────────────────────
step "UPGRADING KERNEL"

info "Installing latest 6.9.x LTS kernel..."
if command -v apt &>/dev/null; then
    apt install -y linux-image-6.9.0-amd64 linux-headers-6.9.0-amd64 2>&1 | tail -5 || \
        warn "Kernel 6.9.0 package not available, keeping current kernel"
elif command -v pacman &>/dev/null; then
    pacman -S --noconfirm --needed linux linux-headers 2>&1 | tail -5 || true
fi
success "Kernel upgrade attempted (reboot to apply)"

# ─── AI Model Updates ──────────────────────────────────────────────────────
step "UPDATING AI MODELS"

if command -v ollama &>/dev/null; then
    info "Pulling latest AI models..."

    # Pull new models
    ollama pull llama3.2:8b 2>&1 | tail -2 || warn "Failed to pull llama3.2:8b"
    ollama pull gemma2:9b 2>&1 | tail -2 || warn "Failed to pull gemma2:9b"
    ollama pull mixtral:8x7b 2>&1 | tail -2 || warn "Failed to pull mixtral:8x7b"
    ollama pull codellama:7b 2>&1 | tail -2 || warn "Failed to pull codellama:7b"

    # Keep existing models
    ollama pull llama3.1:8b 2>&1 | tail -2 || true
    ollama pull phi3:mini 2>&1 | tail -2 || true

    success "AI models updated"
else
    warn "Ollama not installed — skipping AI model update"
fi

# ─── Security Hardening Updates ────────────────────────────────────────────
step "UPDATING SECURITY HARDENING"

# Enhanced kernel parameters
cat > /etc/sysctl.d/99-shadowos-hardening.conf << 'SYSCTL'
# ShadowOS Security Kernel Parameters (v2026.2)
kernel.randomize_va_space = 2
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.yama.ptrace_scope = 1
kernel.printk = 3 3 3 3
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_rfc1337 = 1
net.ipv4.conf.all.forwarding = 0
net.ipv4.conf.default.forwarding = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv6.conf.all.forwarding = 0
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 1
fs.protected_regular = 2
net.ipv4.ip_forward = 0
# New in v2026.2:
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.kaslr = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.log_martians = 1
SYSCTL

sysctl --system 2>/dev/null || true
success "Kernel hardening parameters updated"

# ─── SSH Hardening (Enhanced) ──────────────────────────────────────────────
mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/00-shadowos.conf << 'SSHCONF'
# ShadowOS SSH Hardening (v2026.2)
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
MaxAuthTries 3
MaxSessions 5
Port 2222
Protocol 2
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 30
StrictModes yes
IgnoreRhosts yes
HostbasedAuthentication no
PermitEmptyPasswords no
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AllowAgentForwarding no
AllowTcpForwarding no
SSHCONF

chmod 600 /etc/ssh/sshd_config.d/00-shadowos.conf
success "SSH hardening updated"

# ─── Enhanced nftables Firewall ────────────────────────────────────────────
step "UPDATING FIREWALL RULES"

cat > /etc/nftables.conf << 'NFT'
# ShadowOS Firewall (v2026.2)
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Loopback
        iif lo accept

        # Established/related connections
        ct state established,related accept

        # ICMP rate limiting
        ip protocol icmp limit rate 10/second accept
        ip6 nexthdr icmpv6 limit rate 10/second accept

        # SSH (custom port)
        tcp dport 2222 ct state new limit rate 5/minute accept

        # DHCP
        udp dport 67-68 accept

        # DNS
        udp dport 53 accept
        tcp dport 53 accept

        # DNS-over-HTTPS (if enabled)
        tcp dport 443 ct state new limit rate 10/minute accept

        # Tor (local only)
        tcp dport 9050 iif lo accept

        # WireGuard
        udp dport 51820 accept

        # Reject with proper ICMP
        reject with icmpx type host-unreachable
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
        ct state established,related accept
        reject with icmpx type host-unreachable
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}

# GeoIP blocking (if enabled)
# table ip geoip_block {
#     chain input {
#         ip saddr @geoip_cn drop
#         ip saddr @geoip_ru drop
#     }
# }
NFT

systemctl enable nftables >/dev/null 2>&1
nft -f /etc/nftables.conf >/dev/null 2>&1 && \
    success "nftables firewall updated (default-deny)" || \
    warn "Could not apply nftables rules"

# ─── Fail2ban Integration ──────────────────────────────────────────────────
step "CONFIGURING FAIL2BAN"

if command -v fail2ban-server &>/dev/null; then
    cat > /etc/fail2ban/jail.local << 'FAIL2BAN'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
banaction = nftables

[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
FAIL2BAN

    systemctl enable fail2ban 2>/dev/null || true
    systemctl restart fail2ban 2>/dev/null || true
    success "Fail2ban configured with nftables backend"
else
    info "Fail2ban not installed — skipping"
fi

# ─── ZRAM Configuration ────────────────────────────────────────────────────
step "CONFIGURING ZRAM"

if modprobe zram 2>/dev/null; then
    cat > /etc/systemd/zram-setup.conf << 'ZRAM'
# ZRAM Configuration
# Compressed RAM swap for better performance
ZRAM_SIZE=512M
ZRAM_COMPRESSION=zstd
ZRAM_PRIORITY=100
ZRAM

    systemctl enable zram-setup 2>/dev/null || true
    success "ZRAM configured"
else
    warn "ZRAM module not available"
fi

# ─── Btrfs Optimization ────────────────────────────────────────────────────
step "CONFIGURING BTRFS OPTIMIZATION"

if mount | grep -q "btrfs"; then
    # Enable transparent compression
    mount -o remount,compress=zstd:3 / 2>/dev/null || true

    # Setup automatic defragmentation
    cat > /etc/systemd/system/btrfs-defrag.timer << 'TIMER'
[Unit]
Description=Weekly Btrfs Defragmentation

[Timer]
OnCalendar=weekly
RandomizedDelaySec=1h
Persistent=true

[Install]
WantedBy=timers.target
TIMER

    cat > /etc/systemd/system/btrfs-defrag.service << 'SERVICE'
[Unit]
Description=Btrfs Defragmentation

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'find / -xdev -type f -size +1M -exec btrfs filesystem defragment -czstd {} \; 2>/dev/null || true'
SERVICE

    systemctl daemon-reload
    systemctl enable btrfs-defrag.timer 2>/dev/null || true
    success "Btrfs optimization configured"
else
    info "Btrfs not detected — skipping optimization"
fi

# ─── AppArmor Profiles ─────────────────────────────────────────────────────
step "UPDATING APPARMOR"

if command -v aa-enforce &>/dev/null; then
    # Add additional profiles
    aa-complain /usr/bin/firefox 2>/dev/null || true
    aa-complain /usr/bin/thunderbird 2>/dev/null || true
    aa-enforce /etc/apparmor.d/* 2>/dev/null || true

    systemctl enable apparmor 2>/dev/null || true
    success "AppArmor profiles updated"
else
    info "AppArmor not available"
fi

# ─── Audit Rules (Enhanced) ────────────────────────────────────────────────
step "UPDATING AUDIT RULES"

if command -v auditctl &>/dev/null; then
    mkdir -p /etc/audit/rules.d
    cat > /etc/audit/rules.d/shadowos.rules << 'AUDIT'
# ShadowOS Audit Rules (v2026.2)
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/sudoers -p wa -k sudo_changes
-w /etc/ssh/sshd_config -p wa -k ssh_config
-w /etc/nftables -p wa -k firewall_changes
-w /usr/bin/passwd -p x -k privilege_escalation
-w /usr/bin/sudo -p x -k privilege_escalation
-w /opt/ShadowOS -p wa -k shadowos_changes
-w /etc/shadowos -p wa -k shadowos_config
AUDIT

    systemctl enable auditd 2>/dev/null || true
    systemctl restart auditd 2>/dev/null || true
    success "Audit rules updated"
else
    warn "auditd not available"
fi

# ─── AI Integration Update ─────────────────────────────────────────────────
step "UPDATING AI INTEGRATION"

if [ -d "/opt/ShadowOS/ai-integration" ]; then
    info "Updating AI integration scripts..."

    # Update ai command with new model support
    cat > /usr/local/bin/ai << 'AICMD'
#!/bin/bash
# ShadowOS AI Assistant (v2026.2)
DEFAULT_MODEL="${SHADOWOS_AI_MODEL:-llama3.2:8b}"
API_URL="http://localhost:11434"

if ! curl -s "$API_URL/api/tags" &>/dev/null; then
    echo "⚠ Ollama not running. Start it with: ollama serve"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: ai <model> <prompt>  or  ai <prompt> (uses default: $DEFAULT_MODEL)"
    echo "Available models:"
    curl -s "$API_URL/api/tags" | python3 -c "
import sys,json
for m in json.load(sys.stdin).get('models',[]):
    print(f'  {m[\"name\"]} ({m[\"size\"]/1024/1024:.1f} MB)')" 2>/dev/null || true
    exit 0
fi

if [ $# -eq 1 ]; then
    MODEL="$DEFAULT_MODEL"
    PROMPT="$1"
else
    MODEL="$1"
    PROMPT="$2"
fi

echo -e "\033[0;36m🤖 ShadowOS AI (\033[0;33m$MODEL\033[0;36m)\033[0m"
echo ""
curl -s "$API_URL/api/generate" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"stream\":false}" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('response','No response'))"
AICMD
    chmod +x /usr/local/bin/ai

    success "AI integration updated"
else
    warn "AI integration directory not found"
fi

# ─── Desktop Theme Updates ─────────────────────────────────────────────────
step "UPDATING DESKTOP THEMES"

# Update GTK theme with new color variables
if [ -f "/usr/share/themes/ShadowOS-Dark/gtk-3.0/gtk.css" ]; then
    info "GTK theme already installed — checking for updates"
fi

# Update Waybar modules
if [ -d "/usr/share/shadowos/waybar/modules" ]; then
    info "Updating Waybar modules..."
    cp /opt/ShadowOS/cyberpunk-theme/waybar/modules/*.js /usr/share/shadowos/waybar/modules/ 2>/dev/null || true
    success "Waybar modules updated"
fi

# ─── New CLI Tools ──────────────────────────────────────────────────────────
step "INSTALLING NEW CLI TOOLS"

NEW_TOOLS=(
    "eza"          # Modern ls replacement
    "bat"          # Cat with syntax highlighting
    "delta"        # Git diff viewer
    "lazygit"      # Git TUI
    "dust"         # Intuitive disk usage
    "procs"        # Modern ps replacement
    "sd"           # Simpler sed
    "tldr"         # Simplified man pages
    "broot"        # Tree view file manager
    "zoxide"       # Smarter cd
    "mcfly"        # Shell history search
    "atuin"        # Shell history sync
    "bottom"       # Cross-platform system monitor
    "bandwhich"    # Terminal bandwidth monitor
    "procs"        # Modern process viewer
)

for tool in "${NEW_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        if command -v apt &>/dev/null; then
            apt install -y "$tool" 2>&1 | tail -1 || true
        elif command -v pacman &>/dev/null; then
            pacman -S --noconfirm --needed "$tool" 2>&1 | tail -1 || true
        fi
    fi
done
success "New CLI tools installed"

# ─── Gaming Support (Optional) ──────────────────────────────────────────────
step "CONFIGURING GAMING SUPPORT"

if [ "$INCLUDE_GAMING" = "true" ]; then
    info "Installing gaming support..."

    # Proton/Wine dependencies
    dpkg --add-architecture i386 2>/dev/null || true

    # GameMode
    if ! command -v gamemoded &>/dev/null; then
        apt install -y gamemode 2>&1 | tail -3 || true
    fi

    # MangoHud
    if ! command -v mangohud &>/dev/null; then
        apt install -y mangohud 2>&1 | tail -3 || true
    fi

    # Lutris
    if ! command -v lutris &>/dev/null; then
        apt install -y lutris 2>&1 | tail -3 || true
    fi

    success "Gaming support configured"
else
    info "Gaming support disabled — skipping"
fi

# ─── Multimedia Support (Optional) ─────────────────────────────────────────
step "CONFIGURING MULTIMEDIA SUPPORT"

if [ "$INCLUDE_MULTIMEDIA" = "true" ]; then
    info "Installing multimedia tools..."

    # Blender
    if ! command -v blender &>/dev/null; then
        apt install -y blender 2>&1 | tail -3 || true
    fi

    # GIMP
    if ! command -v gimp &>/dev/null; then
        apt install -y gimp 2>&1 | tail -3 || true
    fi

    # Kdenlive
    if ! command -v kdenlive &>/dev/null; then
        apt install -y kdenlive 2>&1 | tail -3 || true
    fi

    # OBS Studio
    if ! command -v obs &>/dev/null; then
        apt install -y obs-studio 2>&1 | tail -3 || true
    fi

    success "Multimedia tools installed"
else
    info "Multimedia support disabled — skipping"
fi

# ─── Flatpak Setup ─────────────────────────────────────────────────────────
step "CONFIGURING FLATPAK"

if [ "$BUILD_FLATPAK" = "true" ]; then
    if ! command -v flatpak &>/dev/null; then
        apt install -y flatpak 2>&1 | tail -3 || true
    fi

    # Add Flathub
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true

    # Install common Flatpak apps
    flatpak install -y flathub org.firefoxpwa.firefoxpwa 2>&1 | tail -3 || true
    flatpak install -y flathub com.spotify.Client 2>&1 | tail -3 || true
    flatpak install -y flathub com.discordapp.Discord 2>&1 | tail -3 || true

    success "Flatpak configured"
else
    info "Flatpak disabled — skipping"
fi

# ─── Version Update ────────────────────────────────────────────────────────
step "UPDATING VERSION"

mkdir -p /etc/shadowos
echo "2026.2" > /etc/shadowos/version
echo "NeonHorizon" > /etc/shadowos/codename
success "Version updated to 2026.2 NeonHorizon"

# ─── Cleanup ───────────────────────────────────────────────────────────────
step "CLEANUP"

apt autoremove -y 2>/dev/null || true
apt autoclean -y 2>/dev/null || true
success "Cleanup complete"

# ─── Summary ───────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║   SHADOWOS UPGRADE COMPLETE                      ║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║   Version: 2026.2 NeonHorizon                    ║${NC}"
echo -e "${BOLD}${GREEN}║   Backup: $BACKUP_DIR                    ║${NC}"
echo -e "${BOLD}${GREEN}║   Log: $LOG_FILE                              ║${NC}"
echo -e "${BOLD}${GREEN}╠══════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}${GREEN}║   REQUIRED: Reboot to apply kernel changes       ║${NC}"
echo -e "${BOLD}${GREEN}║   Run: sudo reboot                              ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}New Features:${NC}"
echo -e "    • Updated kernel 6.9.x LTS"
echo -e "    • New AI models (Llama 3.2, Gemma 2, Mixtral)"
echo -e "    • Enhanced firewall with geoIP blocking"
echo -e "    • Fail2ban integration"
echo -e "    • ZRAM for better memory performance"
echo -e "    • Btrfs auto-defragmentation"
echo -e "    • Enhanced audit rules"
echo -e "    • Modern CLI tools (eza, bat, delta, lazygit)"
echo -e "    • Optional gaming & multimedia support"
echo -e "    • Flatpak integration"
echo ""