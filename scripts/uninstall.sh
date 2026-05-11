#!/bin/bash
# ============================================================================
# ShadowOS Uninstall Script
# Restores system to pre-ShadowOS state
# ============================================================================
set -euo pipefail

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'

warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
success() { echo -e "${GREEN}✓ $1${NC}"; }
error() { echo -e "${RED}✗ $1${NC}"; }

echo ""
echo -e "${RED}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║  ⚠  SHADOWOS UNINSTALL                          ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════╝${NC}"
echo ""
warn "This will remove ShadowOS configurations and packages."
warn "Your personal files will be preserved."
echo ""
read -p "Continue? [y/N]: " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
fi

# ─── Remove Services ────────────────────────────────────────────────────
echo -e "\n${YELLOW}Removing ShadowOS services...${NC}"
for svc in shadowos-ai shadowos-monitor shadowos-privacy shadowos-security \
           shadowos-update shadowos-update.timer shadowos-boot-status; do
    systemctl stop "$svc" 2>/dev/null || true
    systemctl disable "$svc" 2>/dev/null || true
    rm -f "/etc/systemd/system/${svc}.service" "/etc/systemd/system/${svc}.timer"
    success "Removed service: $svc"
done
systemctl daemon-reload

# ─── Remove ShadowOS Packages ───────────────────────────────────────────
echo -e "\n${YELLOW}Removing ShadowOS packages...${NC}"
if command -v apt &>/dev/null; then
    apt remove -y --purge \
        firejail apparmor nftables tor torsocks proxychains4 \
        wireguard-tools openvpn \
        lynis rkhunter chkrootkit aide clamav \
        ollama \
        2>&1 | tail -5 || true
    apt autoremove -y 2>&1 | tail -3 || true
    apt autoclean 2>&1 | tail -3 || true
fi
success "ShadowOS packages removed"

# ─── Restore SSH Defaults ───────────────────────────────────────────────
echo -e "\n${YELLOW}Restoring SSH defaults...${NC}"
rm -f /etc/ssh/sshd_config.d/00-shadowos.conf
rm -f /etc/ssh/banner
# Restore default port
if command -v sed &>/dev/null; then
    sed -i 's/^Port 2222/Port 22/' /etc/ssh/sshd_config 2>/dev/null || true
    sed -i 's/^PermitRootLogin no/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config 2>/dev/null || true
fi
success "SSH defaults restored"

# ─── Restore Kernel Parameters ──────────────────────────────────────────
echo -e "\n${YELLOW}Restoring kernel parameters...${NC}"
rm -f /etc/sysctl.d/99-shadowos-hardening.conf
rm -f /etc/sysctl.d/99-shadowos-security.conf
sysctl --system 2>/dev/null || true
success "Kernel parameters restored"

# ─── Remove ShadowOS Configurations ─────────────────────────────────────
echo -e "\n${YELLOW}Removing ShadowOS configurations...${NC}"
rm -rf /etc/shadowos
rm -rf /opt/ShadowOS
rm -rf /usr/share/ShadowOS
rm -f /etc/skel/.local/bin/ai
rm -f /etc/skel/.local/bin/ai-scan
rm -f /etc/skel/.local/bin/ai-review
rm -f /etc/skel/.local/bin/ai-start
rm -f /etc/skel/.local/bin/ai-stop
rm -f /etc/skel/.local/bin/ai-complete
rm -f /etc/skel/.local/bin/ai-diagnose
rm -f /etc/skel/.config/kitty/kitty.conf
rm -f /etc/skel/.config/alacritty/alacritty.toml
rm -f /etc/skel/.config/tmux/tmux.conf
rm -f /etc/skel/.config/nvim/init.vim
rm -f /etc/skel/.config/nvim/lua/ai_copilot.lua
rm -f /etc/skel/.config/gtk-3.0/settings.ini
rm -f /etc/skel/.config/gtk-4.0/settings.ini
rm -f /etc/skel/.config/dunst/dunstrc
rm -f /etc/skel/.config/waybar/config
rm -f /etc/skel/.config/waybar/style.css
rm -f /etc/skel/.config/picom/picom.conf
rm -f /etc/skel/.config/hypr/hyprland.conf
rm -f /etc/skel/.config/hypr/hyprpaper.conf
rm -f /etc/skel/.config/Kvantum/Kvantum.kvconfig
rm -f /etc/skel/.p10k.zsh
rm -f /etc/skel/.zshrc
rm -f /etc/skel/.local/bin/shadowos-prompt.sh
rm -f /etc/skel/.config/dns/dns-over-https.json
rm -f /etc/skel/.config/tor/torrc
rm -f /usr/share/sddm/themes/ShadowOS/theme.conf
rm -rf /usr/share/sddm/themes/ShadowOS
rm -f /usr/share/plymouth/themes/shadowos/shadowos.plymouth
rm -f /usr/share/plymouth/themes/shadowos/shadowos.script
rm -rf /usr/share/plymouth/themes/shadowos
success "Configurations removed"

# ─── Restore Default Shell ──────────────────────────────────────────────
echo -e "\n${YELLOW}Restoring default shell...${NC}"
if command -v chsh &>/dev/null; then
    chsh -s /bin/bash root 2>/dev/null || true
    if [ -n "${SUDO_USER:-}" ]; then
        chsh -s /bin/bash "$SUDO_USER" 2>/dev/null || true
    fi
fi
success "Default shell restored"

# ─── Remove ShadowOS Repositories ───────────────────────────────────────
echo -e "\n${YELLOW}Removing ShadowOS repositories...${NC}"
rm -f /etc/apt/sources.list.d/shadowos.list
rm -f /usr/share/keyrings/shadowos-archive-keyring.gpg 2>/dev/null || true
success "Repositories removed"

# ─── Remove Audit Rules ─────────────────────────────────────────────────
echo -e "\n${YELLOW}Removing ShadowOS audit rules...${NC}"
rm -f /etc/audit/rules.d/shadowos.rules
auditctl -R /etc/audit/rules.d/ 2>/dev/null || true
success "Audit rules removed"

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ ShadowOS uninstalled successfully${NC}"
echo -e "${GREEN}  ✓ Reboot recommended${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo ""
echo "Please reboot: sudo reboot"