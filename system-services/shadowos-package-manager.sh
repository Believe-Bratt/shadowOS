#!/bin/bash
# ============================================================================
# ShadowOS Package Manager — Enhanced APT Wrapper
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

# ─── Configuration ──────────────────────────────────────────────────────
SHADOWOS_REPO="https://packages.shadowos.local"
APT_CONF="/etc/apt/sources.list.d/shadowos.list"
CACHE_DIR="/var/cache/apt/archives"
LOG_FILE="/var/log/shadowos-packages.log"

# ─── Colors & Formatting ────────────────────────────────────────────────
header() {
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║  🌑 ShadowOS Package Manager v2026.1            ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    printf "\r  ["
    printf "%0.s█" $(seq 1 $filled)
    printf "%0.s░" $(seq 1 $empty)
    printf "] %3d%%" "$percent"
}

# ─── Add ShadowOS Repositories ──────────────────────────────────────────
add_repos() {
    header
    echo -e "${BOLD}Adding ShadowOS repositories...${NC}"
    
    # Create sources list
    cat > "$APT_CONF" << 'REPOS'
# ShadowOS Custom Repositories
# Enhanced packages and custom builds

# ShadowOS Main Repository
# deb [signed-by=/usr/share/keyrings/shadowos-archive-keyring.gpg] https://packages.shadowos.local/apt stable main

# Kali Linux (penetration testing)
deb http://http.kali.org/kali kali-rolling main non-free non-free-firmware contrib

# Additional repositories for AI/ML
# deb https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/ cuda main
REPOS

    # Import keys (placeholder - real keys would be added during ISO build)
    # gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys SHADOWOS_KEY
    # gpg --export SHADOWOS_KEY | gpg --dearmor -o /usr/share/keyrings/shadowos-archive-keyring.gpg
    
    success "ShadowOS repositories configured"
    echo ""
    echo -e "  ${YELLOW}Note:${NC} Custom ShadowOS repository requires signing key"
    echo -e "  ${YELLOW}Note:${NC} Kali repositories provide penetration testing tools"
}

# ─── Smart Update ────────────────────────────────────────────────────────
smart_update() {
    header
    echo -e "${BOLD}Updating package lists...${NC}"
    
    local start_time=$(date +%s)
    
    apt update 2>&1 | while IFS= read -r line; do
        if echo "$line" | grep -q "Get:"; then
            echo -e "  ${CYAN}⟳${NC} $line"
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    success "Package lists updated in ${duration}s"
}

# ─── Smart Upgrade ───────────────────────────────────────────────────────
smart_upgrade() {
    header
    echo -e "${BOLD}Upgrading packages...${NC}"
    
    local total=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || echo "0")
    local current=0
    
    apt upgrade -y 2>&1 | while IFS= read -r line; do
        if echo "$line" | grep -q "^Setting up\|Unpacking\|Preparing"; then
            ((current++))
            progress_bar "$current" "$total"
        fi
    done
    
    echo ""
    success "System upgraded"
}

# ─── Install Package ────────────────────────────────────────────────────
install_pkg() {
    local package="$1"
    
    header
    echo -e "${BOLD}Installing: ${MAGENTA}${package}${NC}"
    
    # Check if package exists
    if apt-cache show "$package" &>/dev/null; then
        apt install -y "$package" 2>&1 | tee -a "$LOG_FILE"
        success "Installed: $package"
    else
        error "Package not found: $package"
        echo -e "  ${YELLOW}Searching alternatives...${NC}"
        apt-cache search "$package" | head -5
        return 1
    fi
}

# ─── Remove Package ─────────────────────────────────────────────────────
remove_pkg() {
    local package="$1"
    
    header
    echo -e "${BOLD}Removing: ${MAGENTA}${package}${NC}"
    
    apt remove -y "$package" 2>&1 | tee -a "$LOG_FILE"
    apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
    success "Removed: $package"
}

# ─── Search Package ─────────────────────────────────────────────────────
search_pkg() {
    local query="$1"
    
    header
    echo -e "${BOLD}Searching: ${MAGENTA}${query}${NC}"
    echo ""
    
    apt-cache search "$query" | head -20
}

# ─── Package Info ───────────────────────────────────────────────────────
info_pkg() {
    local package="$1"
    
    header
    echo -e "${BOLD}Information: ${MAGENTA}${package}${NC}"
    echo ""
    
    apt-cache show "$package" 2>/dev/null | head -30 || error "Package not found"
}

# ─── List Installed ShadowOS Packages ───────────────────────────────────
list_shadowos() {
    header
    echo -e "${BOLD}ShadowOS Installed Packages:${NC}"
    echo ""
    
    local categories=("pentest" "ai" "dev" "security" "network" "terminal" "desktop")
    
    for cat in "${categories[@]}"; do
        echo -e "  ${CYAN}[$cat]${NC}"
        case $cat in
            pentest)
                for pkg in nmap metasploit-framework sqlmap burpsuite wireshark; do
                    dpkg -l "$pkg" &>/dev/null && echo -e "    ${GREEN}✓${NC} $pkg" || echo -e "    ${RED}✗${NC} $pkg"
                done
                ;;
            ai)
                for pkg in ollama python3-torch python3-transformers; do
                    dpkg -l "$pkg" &>/dev/null && echo -e "    ${GREEN}✓${NC} $pkg" || echo -e "    ${RED}✗${NC} $pkg"
                done
                ;;
            dev)
                for pkg in git neovim docker.io golang rustc; do
                    dpkg -l "$pkg" &>/dev/null && echo -e "    ${GREEN}✓${NC} $pkg" || echo -e "    ${RED}✗${NC} $pkg"
                done
                ;;
            security)
                for pkg in nftables apparmor firejail lynis aide; do
                    dpkg -l "$pkg" &>/dev/null && echo -e "    ${GREEN}✓${NC} $pkg" || echo -e "    ${RED}✗${NC} $pkg"
                done
                ;;
            network)
                for pkg in tor wireguard-tools proxychains4 nmap; do
                    dpkg -l "$pkg" &>/dev/null && echo -e "    ${GREEN}✓${NC} $pkg" || echo -e "    ${RED}✗${NC} $pkg"
                done
                ;;
            terminal)
                for pkg in zsh tmux alacritty kitty fzf; do
                    dpkg -l "$pkg" &>/dev/null && echo -e "    ${GREEN}✓${NC} $pkg" || echo -e "    ${RED}✗${NC} $pkg"
                done
                ;;
            desktop)
                for pkg in kde-plasma-desktop sddm plymouth; do
                    dpkg -l "$pkg" &>/dev/null && echo -e "    ${GREEN}✓${NC} $pkg" || echo -e "    ${RED}✗${NC} $pkg"
                done
                ;;
        esac
    done
}

# ─── System Cleanup ─────────────────────────────────────────────────────
cleanup() {
    header
    echo -e "${BOLD}Cleaning system...${NC}"
    
    apt autoremove -y 2>&1 | tail -3
    apt autoclean 2>&1 | tail -3
    rm -rf /var/lib/apt/lists/*
    
    # Clean pip cache
    rm -rf ~/.cache/pip 2>/dev/null
    
    # Clean npm cache
    npm cache clean --force 2>/dev/null || true
    
    success "System cleaned"
}

# ─── Main Interface ─────────────────────────────────────────────────────
case "${1:-help}" in
    update)     smart_update ;;
    upgrade)    smart_upgrade ;;
    install)    install_pkg "$2" ;;
    remove)     remove_pkg "$2" ;;
    search)     search_pkg "$2" ;;
    info)       info_pkg "$2" ;;
    repos)      add_repos ;;
    list)       list_shadowos ;;
    clean)      cleanup ;;
    status)
        echo -e "${CYAN}Package Status:${NC}"
        echo "  Updates available: $(apt list --upgradable 2>/dev/null | grep -c upgradable || echo 0)"
        echo "  Installed packages: $(dpkg -l | grep -c "^ii")"
        echo "  Cache size: $(du -sh /var/cache/apt/archives 2>/dev/null | cut -f1)"
        ;;
    help|*)
        echo ""
        echo -e "${BOLD}ShadowOS Package Manager${NC}"
        echo ""
        echo -e "  ${CYAN}update${NC}          — Update package lists"
        echo -e "  ${CYAN}upgrade${NC}         — Upgrade all packages"
        echo -e "  ${CYAN}install <pkg>${NC}    — Install a package"
        echo -e "  ${CYAN}remove <pkg>${NC}     — Remove a package"
        echo -e "  ${CYAN}search <query>${NC}   — Search packages"
        echo -e "  ${CYAN}info <pkg>${NC}       — Package information"
        echo -e "  ${CYAN}repos${NC}           — Configure repositories"
        echo -e "  ${CYAN}list${NC}            — List ShadowOS packages"
        echo -e "  ${CYAN}clean${NC}           — Clean cache and unused packages"
        echo -e "  ${CYAN}status${NC}          — Package status"
        ;;
esac