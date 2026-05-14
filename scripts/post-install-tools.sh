#!/bin/bash
# ============================================================================
# ShadowOS Post-Install Tools Script
# STAGE 2: Install AI, Pentest, Graphics, and additional tools
# Run this AFTER the base system is installed
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

log() { echo -e "$1"; }
step() { log "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { log "  ${GREEN}✓${NC} $1"; }
error() { log "  ${RED}✗${NC} $1"; }
warn() { log "  ${YELLOW}!${NC} $1"; }

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Please run as root (use sudo)"
    exit 1
fi

# ─── Install Powerlevel10k via Git ─────────────────────────────────────────
install_powerlevel10k() {
    step "INSTALLING POWERLEVEL10K (Git)"
    
    # Install Oh My Zsh if not present
    if [ ! -d "/usr/share/oh-my-zsh" ]; then
        log "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>/dev/null || true
    fi
    
    # Clone powerlevel10k
    if [ ! -d "/usr/share/zsh-theme-powerlevel10k" ]; then
        log "Cloning powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k
        success "powerlevel10k installed"
    else
        success "powerlevel10k already installed"
    fi
    
    # Clone zsh plugins
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions 2>/dev/null || true
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting /usr/share/zsh-syntax-highlighting 2>/dev/null || true
}

# ─── Install Ollama via Manual Installer ───────────────────────────────────
install_ollama() {
    step "INSTALLING OLLAMA (Manual)"
    
    if command -v ollama &>/dev/null; then
        success "Ollama already installed"
        return
    fi
    
    log "Downloading Ollama installer..."
    curl -fsSL https://ollama.com/install.sh | sh
    
    # Enable and start ollama service
    systemctl enable ollama 2>/dev/null || true
    
    success "Ollama installed"
}

# ─── Install AI Tools ───────────────────────────────────────────────────────
install_ai_tools() {
    step "INSTALLING AI TOOLS"
    
    # Python AI packages
    pip3 install --no-cache-dir torch transformers numpy pandas scipy scikit-learn 2>/dev/null || warn "Some Python AI packages may have failed"
    
    # Jupyter
    pip3 install --no-cache-dir jupyter jupyterlab 2>/dev/null || warn "Jupyter installation may have issues"
    
    success "AI tools installed"
}

# ─── Install Pentest Tools ─────────────────────────────────────────────────
install_pentest_tools() {
    step "INSTALLING PENTEST TOOLS"
    
    # Core pentest tools from Kali repos
    apt-get install -y --no-install-recommends \
        nmap \
        masscan \
        nikto \
        sqlmap \
        metasploit-framework \
        wireshark \
        john \
        hashcat \
        hydra \
        aircrack-ng \
        recon-ng \
        theharvester \
        mitmproxy \
        burpsuite \
        dirb \
        gobuster \
        wfuzz \
        ffuf \
        subfinder \
        amass \
        ghidra \
        radare2 \
        binwalk \
        volatility \
        autopsy \
        sleuthkit \
        2>/dev/null || warn "Some pentest tools may have failed"
    
    success "Pentest tools installed"
}

# ─── Install Graphics Tools ─────────────────────────────────────────────────
install_graphics_tools() {
    step "INSTALLING GRAPHICS TOOLS"
    
    apt-get install -y --no-install-recommends \
        imagemagick \
        gimp \
        inkscape \
        blender \
        krita \
        2>/dev/null || warn "Some graphics tools may have failed"
    
    success "Graphics tools installed"
}

# ─── Install Office Suite ───────────────────────────────────────────────────
install_office_suite() {
    step "INSTALLING OFFICE SUITE"
    
    apt-get install -y --no-install-recommends \
        libreoffice \
        libreoffice-gtk3 \
        2>/dev/null || warn "Office suite installation may have issues"
    
    success "Office suite installed"
}

# ─── Install Docker ─────────────────────────────────────────────────────────
install_docker() {
    step "INSTALLING DOCKER"
    
    # Install Docker from official repo
    apt-get install -y --no-install-recommends \
        docker.io \
        docker-compose \
        2>/dev/null || warn "Docker installation may have issues"
    
    # Enable Docker service
    systemctl enable docker 2>/dev/null || true
    
    success "Docker installed"
}

# ─── Install Additional Terminal Tools ─────────────────────────────────────
install_terminal_tools() {
     step "INSTALLING TERMINAL TOOLS"

     apt-get install -y --no-install-recommends \
         fzf \
         ripgrep \
         fd-find \
         bat \
         exa \
         eza \
         dust \
         procs \
         sd \
         tldr \
         broot \
         lazygit \
         delta \
         ranger \
         ncdu \
         tmuxinator \
         zoxide \
         mcfly \
         atuin \
         bottom \
         bandwhich \
         duf \
         2>/dev/null || warn "Some terminal tools may have failed"

     success "Terminal tools installed"
 }

# ─── Install Security & Privacy Tools ──────────────────────────────────────
install_security_tools() {
     step "INSTALLING SECURITY & PRIVACY TOOLS"

     apt-get install -y --no-install-recommends \
         usbguard \
         fail2ban \
         aide \
         rkhunter \
         chkrootkit \
         lynis \
         firejail \
         bubblewrap \
         2>/dev/null || warn "Some security tools may have failed"

     success "Security tools installed"
 }

# ─── Install Multimedia Tools ───────────────────────────────────────────────
install_multimedia() {
    step "INSTALLING MULTIMEDIA TOOLS"
    
    apt-get install -y --no-install-recommends \
        vlc \
        mpv \
        ffmpeg \
        pavucontrol \
        pipewire \
        wireplumber \
        2>/dev/null || warn "Some multimedia tools may have failed"
    
    success "Multimedia tools installed"
}

# ─── Main Menu ──────────────────────────────────────────────────────────────
show_menu() {
    log "\n${CYAN}ShadowOS Post-Install Tools Installer${NC}\n"
    log "Select components to install:\n"
    log "  1) All tools (full installation)"
    log "  2) AI tools only"
    log "  3) Pentest tools only"
    log "  4) Graphics tools only"
    log "  5) Office suite only"
    log "  6) Docker only"
    log "  7) Terminal tools only"
     log "  8) Security & Privacy tools"
     log "  9) Custom selection"
     log "  10) Exit\n"
    
    read -p "Choice [1-9]: " choice
    
    case "$choice" in
        1) 
            install_powerlevel10k
            install_ollama
            install_ai_tools
            install_pentest_tools
            install_graphics_tools
            install_office_suite
            install_docker
            install_terminal_tools
            install_multimedia
            ;;
        2) install_powerlevel10k; install_ollama; install_ai_tools ;;
        3) install_pentest_tools ;;
        4) install_graphics_tools ;;
        5) install_office_suite ;;
        6) install_docker ;;
        7) install_powerlevel10k; install_terminal_tools ;;
         8) install_security_tools ;;
         9) custom_install ;;
         10) exit 0 ;;
         *) error "Invalid choice"; exit 1 ;;
    esac
}

custom_install() {
    log "\nSelect components (y/n):\n"
    
    read -p "  Powerlevel10k? [y/N]: " p10k
    read -p "  Ollama? [y/N]: " ollama
    read -p "  AI tools? [y/N]: " ai
    read -p "  Pentest tools? [y/N]: " pentest
    read -p "  Graphics tools? [y/N]: " graphics
    read -p "  Office suite? [y/N]: " office
    read -p "  Docker? [y/N]: " docker
    read -p "  Terminal tools? [y/N]: " terminal
    read -p "  Multimedia? [y/N]: " media
     read -p "  Security & Privacy tools? [y/N]: " security

     [ "$p10k" = "y" ] && install_powerlevel10k
     [ "$ollama" = "y" ] && install_ollama
     [ "$ai" = "y" ] && install_ai_tools
     [ "$pentest" = "y" ] && install_pentest_tools
     [ "$graphics" = "y" ] && install_graphics_tools
     [ "$office" = "y" ] && install_office_suite
     [ "$docker" = "y" ] && install_docker
     [ "$terminal" = "y" ] && install_terminal_tools
     [ "$media" = "y" ] && install_multimedia
     [ "$security" = "y" ] && install_security_tools
}

# ─── Run ─────────────────────────────────────────────────────────────────────
main() {
    step "ShadowOS Post-Install Tools"
    
    # Update package lists
    apt-get update
    
    # Show menu or run all
    if [ "${1:-}" = "--all" ]; then
        install_powerlevel10k
        install_ollama
        install_ai_tools
        install_pentest_tools
        install_graphics_tools
        install_office_suite
        install_docker
        install_terminal_tools
        install_security_tools
        install_multimedia
    else
        show_menu
    fi
    
    step "Installation Complete"
    log "\nYou may want to reboot for all changes to take effect.\n"
}

main "$@"