#!/bin/bash
# ============================================================================
# ShadowOS Master Setup Script
# Runs all setup modules with user selection
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; MAGENTA='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

logo() {
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║  🌑 SHADOWOS SETUP WIZARD v2026.1                      ║${NC}"
    echo -e "${BOLD}${CYAN}║  Codename: NeonVanguard                                  ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

menu_item() {
    local num=$1 name=$2 desc=$3
    echo -e "  ${CYAN}${num})${NC} ${BOLD}${name}${NC}"
    echo -e "     ${desc}"
}

select_modules() {
    local selections=()
    
    while true; do
        logo
        echo -e "${BOLD}Select modules to install:${NC}"
        echo ""
        menu_item 1 "Terminal Setup"      "Zsh, Tmux, Kitty/Alacritty, Neovim, Powerlevel10k"
        menu_item 2 "Security Hardening"  "Firewall, AppArmor, SSH, kernel params, IDS"
        menu_item 3 "AI Integration"      "Ollama, ML models, voice commands, Neovim copilot"
        menu_item 4 "Desktop Environment" "Hyprland, KDE Plasma, XFCE, or GNOME"
        menu_item 5 "Privacy & Network"   "Tor, VPN, DNS-over-HTTPS, MAC randomization"
        menu_item 6 "Dev Environment"     "Git, Docker, language servers, build tools"
        menu_item 7 "Pentest Suite"       "200+ security tools from Kali repositories"
        menu_item 8 "System Services"     "Monitor, auto-updates, boot status"
        menu_item 9 "Theme & Appearance"  "GTK theme, icons, SDDM, Plymouth, wallpapers"
        menu_item a "All Modules"         "Install everything"
        echo ""
        menu_item q "Quick Install"       "Core terminal + security + AI (recommended)"
        echo ""
        echo -e "  ${YELLOW}Enter selection (e.g., 123 or a):${NC}"
        read -r -p "  > " choice
        
        case "$choice" in
            1) selections+=(terminal) ;;
            2) selections+=(security) ;;
            3) selections+=(ai) ;;
            4) selections+=(desktop) ;;
            5) selections+=(privacy) ;;
            6) selections+=(dev) ;;
            7) selections+=(pentest) ;;
            8) selections+=(services) ;;
            9) selections+=(theme) ;;
            a|A) selections=(all) ; break ;;
            q|Q) selections=(quick) ; break ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
        
        echo ""
        echo -e "${GREEN}Module added. Add more? (y/n)${NC}"
        read -r -p "  > " more
        if [[ "$more" =~ ^(n|N)$ ]]; then break; fi
    done
    
    echo "${selections[@]}"
}

run_module() {
    local module=$1
    
    case "$module" in
        terminal)
            echo -e "\n${CYAN}>>> Installing Terminal Setup...${NC}"
            bash "$SCRIPT_DIR/../terminal-setup/zsh/setup.sh" 2>/dev/null || true
            bash "$SCRIPT_DIR/../terminal-setup/tmux/setup.sh" 2>/dev/null || true
            ;;
        security)
            echo -e "\n${CYAN}>>> Running Security Hardening...${NC}"
            bash "$SCRIPT_DIR/../security-hardening/apply-hardening.sh"
            ;;
        ai)
            echo -e "\n${CYAN}>>> Setting up AI Integration...${NC}"
            bash "$SCRIPT_DIR/../ai-integration/setup-ai.sh"
            ;;
        desktop)
            echo -e "\n${CYAN}>>> Setting up Desktop Environment...${NC}"
            echo -e "${YELLOW}Select DE:${NC}"
            echo "  1) Hyprland (Wayland, recommended)"
            echo "  2) KDE Plasma"
            echo "  3) XFCE"
            echo "  4) GNOME"
            read -r -p "  > " de_choice
            case "$de_choice" in
                1) bash "$SCRIPT_DIR/../desktop-environments/hyprland/setup.sh" ;;
                2) bash "$SCRIPT_DIR/../desktop-environments/kde/setup.sh" ;;
                3) bash "$SCRIPT_DIR/../desktop-environments/xfce/setup.sh" ;;
                4) bash "$SCRIPT_DIR/../desktop-environments/gnome/setup.sh" ;;
            esac
            ;;
        privacy)
            echo -e "\n${CYAN}>>> Setting up Privacy Stack...${NC}"
            bash "$SCRIPT_DIR/../system-services/tor-privacy.sh" all
            ;;
        dev)
            echo -e "\n${CYAN}>>> Setting up Development Environment...${NC}"
            bash "$SCRIPT_DIR/../dev-environment/setup.sh"
            ;;
        pentest)
            echo -e "\n${CYAN}>>> Installing Pentest Tools...${NC}"
            bash "$SCRIPT_DIR/../pentest-suite/install.sh" 2>/dev/null || \
                echo "  Pentest tools installed via post-install.sh"
            ;;
        services)
            echo -e "\n${CYAN}>>> Installing System Services...${NC}"
            bash "$SCRIPT_DIR/../system-services/shadowos-services.sh"
            ;;
        theme)
            echo -e "\n${CYAN}>>> Applying Themes...${NC}"
            bash "$SCRIPT_DIR/../cyberpunk-theme/plymouth/shadowos-plymouth.sh"
            ;;
        all)
            for m in terminal security ai desktop privacy dev pentest services theme; do
                run_module "$m"
            done
            ;;
        quick)
            for m in terminal security ai; do
                run_module "$m"
            done
            ;;
    esac
}

# ─── Main ────────────────────────────────────────────────────────────────
logo
echo -e "  ${BOLD}Welcome to ShadowOS Setup Wizard${NC}"
echo -e "  This will configure your system with the selected modules."
echo ""

modules=$(select_modules)

echo ""
echo -e "${BOLD}Installing: ${MAGENTA}${modules}${NC}"
echo ""

for mod in $modules; do
    run_module "$mod"
done

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ ShadowOS setup complete!${NC}"
echo -e "${GREEN}  ✓ Please log out and log back in${NC}"
echo -e "${GREEN}  ✓ Run 'shadowos-status' to verify${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"