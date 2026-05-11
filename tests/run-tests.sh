#!/bin/bash
# ============================================================================
# ShadowOS Test Suite
# ============================================================================
set -euo pipefail

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

PASS=0; FAIL=0; SKIP=0

log_pass() { echo -e "  ${GREEN}✓ PASS${NC} $1"; ((PASS++)); }
log_fail() { echo -e "  ${RED}✗ FAIL${NC} $1"; ((FAIL++)); }
log_skip() { echo -e "  ${YELLOW}⊘ SKIP${NC} $1"; ((SKIP++)); }

run_test() {
    local name="$1"
    shift
    if "$@" 2>/dev/null; then
        log_pass "$name"
    else
        log_fail "$name"
    fi
}

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  ShadowOS Test Suite v2026.1${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo ""

# ─── System Tests ────────────────────────────────────────────────────────
echo -e "${BOLD}System Tests:${NC}"

run_test "Zsh is installed" command -v zsh
run_test "Tmux is installed" command -v tmux
run_test "Neovim is installed" command -v nvim
run_test "Git is installed" command -v git
run_test "Oh My Zsh installed" test -d /usr/share/oh-my-zsh
run_test "Powerlevel10k installed" test -d /usr/share/zsh-theme-powerlevel10k
run_test "Zsh autosuggestions installed" test -d /usr/share/zsh-autosuggestions
run_test "Zsh syntax highlighting installed" test -d /usr/share/zsh-syntax-highlighting
run_test "fzf installed" command -v fzf
run_test "ripgrep installed" command -v rg
run_test "bat installed" command -v bat
run_test "exa installed" command -v exa
run_test "fd installed" command -v fd
run_test "eza installed" command -v eza || log_skip "eza (optional)"

# ─── Security Tests ──────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Security Tests:${NC}"

run_test "nftables rules loaded" nft list ruleset 2>/dev/null | grep -q "table inet filter"
run_test "SSH root login disabled" grep -q "PermitRootLogin no" /etc/ssh/sshd_config 2>/dev/null || grep -q "PermitRootLogin no" /etc/ssh/sshd_config.d/*.conf 2>/dev/null
run_test "SSH password auth disabled" grep -q "PasswordAuthentication no" /etc/ssh/sshd_config 2>/dev/null || grep -q "PasswordAuthentication no" /etc/ssh/sshd_config.d/*.conf 2>/dev/null
run_test "SSH on custom port" grep -q "Port 2222" /etc/ssh/sshd_config 2>/dev/null || grep -q "Port 2222" /etc/ssh/sshd_config.d/*.conf 2>/dev/null
run_test "AppArmor available" command -v aa-status 2>/dev/null || log_skip "AppArmor not installed"
run_test "AIDE installed" command -v aide 2>/dev/null || log_skip "AIDE not installed"
run_test "rkhunter installed" command -v rkhunter 2>/dev/null || log_skip "rkhunter not installed"
run_test "Kernel ASLR enabled" grep -q "2" /proc/sys/kernel/randomize_va_space 2>/dev/null
run_test "ICMP redirects disabled" grep -q "0" /proc/sys/net/ipv4/conf/all/accept_redirects 2>/dev/null
run_test "IP forwarding disabled" grep -q "0" /proc/sys/net/ipv4/ip_forward 2>/dev/null
run_test "Core dumps disabled" grep -q "* hard core 0" /etc/security/limits.conf 2>/dev/null

# ─── Terminal Tests ──────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Terminal Tests:${NC}"

run_test "Kitty installed" command -v kitty 2>/dev/null || log_skip "Kitty not installed"
run_test "Alacritty installed" command -v alacritty 2>/dev/null || log_skip "Alacritty not installed"
run_test "Kitty config exists" test -f /etc/skel/.config/kitty/kitty.conf
run_test "Alacritty config exists" test -f /etc/skel/.config/alacritty/alacritty.toml
run_test "Tmux config exists" test -f /etc/skel/.config/tmux/tmux.conf
run_test "Powerlevel10k config exists" test -f /etc/skel/.p10k.zsh

# ─── AI Tests ────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}AI Tests:${NC}"

run_test "Ollama installed" command -v ollama 2>/dev/null || log_skip "Ollama not installed"
run_test "AI script exists" test -x /etc/skel/.local/bin/ai
run_test "AI scan script exists" test -x /etc/skel/.local/bin/ai-scan
run_test "AI review script exists" test -x /etc/skel/.local/bin/ai-review
run_test "AI start script exists" test -x /etc/skel/.local/bin/ai-start
run_test "Python torch available" python3 -c "import torch" 2>/dev/null || log_skip "PyTorch not installed"
run_test "Python transformers available" python3 -c "import transformers" 2>/dev/null || log_skip "Transformers not installed"

# ─── Privacy Tests ───────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Privacy Tests:${NC}"

run_test "Tor installed" command -v tor 2>/dev/null || log_skip "Tor not installed"
run_test "Torsocks installed" command -v torsocks 2>/dev/null || log_skip "Torsocks not installed"
run_test "WireGuard installed" command -v wg 2>/dev/null || log_skip "WireGuard not installed"
run_test "Tor config exists" test -f /etc/skel/.config/tor/torrc
run_test "Proxychains installed" command -v proxychains4 2>/dev/null || log_skip "Proxychains not installed"
run_test "DNS-over-HTTPS config exists" test -f /etc/skel/.config/dns/dns-over-https.json
run_test "macchanger installed" command -v macchanger 2>/dev/null || log_skip "macchanger not installed"

# ─── Desktop Tests ───────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Desktop Tests:${NC}"

run_test "Hyprland setup script exists" test -x desktop-environments/hyprland/setup.sh
run_test "KDE setup script exists" test -x desktop-environments/kde/setup.sh
run_test "GTK3 settings exists" test -f /etc/skel/.config/gtk-3.0/settings.ini
run_test "GTK4 settings exists" test -f /etc/skel/.config/gtk-4.0/settings.ini
run_test "SDDM theme exists" test -f /usr/share/sddm/themes/ShadowOS/theme.conf 2>/dev/null || log_skip "SDDM theme not installed yet"
run_test "Waybar config exists" test -f /etc/skel/.config/waybar/config
run_test "Picom config exists" test -f /etc/skel/.config/picom/picom.conf

# ─── Dev Environment Tests ──────────────────────────────────────────────
echo ""
echo -e "${BOLD}Dev Environment Tests:${NC}"

run_test "Docker installed" command -v docker 2>/dev/null || log_skip "Docker not installed"
run_test "Podman installed" command -v podman 2>/dev/null || log_skip "Podman not installed"
run_test "Workspace directory exists" test -d /opt/workspace
run_test "Git configured" git config --global user.name >/dev/null 2>&1 || log_skip "Git user not configured"
run_test "CMake presets exist" test -f /opt/workspace/configs/CMakePresets.json

# ─── Build System Tests ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Build System Tests:${NC}"

run_test "Makefile exists" test -f Makefile
run_test "Build script exists" test -x build-system/build.sh
run_test "Post-install script exists" test -x scripts/post-install.sh
run_test "Security hardening script exists" test -x security-hardening/apply-hardening.sh
run_test "AI setup script exists" test -x ai-integration/setup-ai.sh
run_test "Pentest tools list exists" test -f pentest-suite/kali-tools.list

# ─── Performance Tests ──────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Performance Tests:${NC}"

run_test "Boot time < 15s" test $(systemd-analyze time 2>/dev/null | grep -oP '\d+' | head -1 || echo 999) -lt 15 || log_skip "Could not measure"
run_test "Memory usage < 500MB idle" test $(free -m | awk '/^Mem:/{print $3}') -lt 500 || log_skip "Memory check skipped"

# ─── Results ─────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}Passed: $PASS${NC}  |  ${RED}Failed: $FAIL${NC}  |  ${YELLOW}Skipped: $SKIP${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}  All critical tests passed!${NC}"
    exit 0
else
    echo -e "${RED}  $FAIL test(s) failed. Review the output above.${NC}"
    exit 1
fi