#!/bin/bash
# ============================================================================
# ShadowOS GNOME Desktop Setup
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; NC='\033[0m'
step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }

step "CONFIGURING GNOME"

GNOME_DIR="$HOME/.config/gnome"
mkdir -p "$GNOME_DIR"

# ─── GSettings Configuration ────────────────────────────────────────────
gsettings set org.gnome.desktop.interface gtk-theme 'ShadowOS-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'ShadowOS' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-theme 'ShadowOS' 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name 'JetBrains Mono 11' 2>/dev/null || true
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11' 2>/dev/null || true
gsettings set org.gnome.desktop.interface document-font-name 'JetBrains Mono 11' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences theme 'ShadowOS' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'JetBrains Mono Bold 11' 2>/dev/null || true

# ─── Dash to Dock Configuration ─────────────────────────────────────────
gsettings set org.gnome.shell.extensions.dash-to-dock \
    dock-position 'BOTTOM' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock \
    transparency-mode 'DYNAMIC' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock \
    background-opacity 0.8 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock \
    custom-background-color true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock \
    background-color '#0a0a0f' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock \
    running-indicator-style 'DOTS' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock \
    running-indicator-dominant-color true 2>/dev/null || true

# ─── Top Bar Configuration ──────────────────────────────────────────────
gsettings set org.gnome.desktop.interface clock-show-weekday true 2>/dev/null || true
gsettings set org.gnome.desktop.interface clock-format '12h' 2>/dev/null || true
gsettings set org.gnome.desktop.interface clock-show-seconds true 2>/dev/null || true
gsettings set org.gnome.desktop.interface battery-percentage-style 'bar' 2>/dev/null || true

# ─── Night Light ────────────────────────────────────────────────────────
gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true 2>/dev/null || true
gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 4500 2>/dev/null || true

# ─── Workspaces ─────────────────────────────────────────────────────────
gsettings set org.gnome.desktop.wm.preferences num-workspaces 10 2>/dev/null || true
gsettings set org.gnome.mutter dynamic-workspaces false 2>/dev/null || true

# ─── Window Management ──────────────────────────────────────────────────
gsettings set org.gnome.desktop.wm.preferences focus-mode 'click' 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences resize-with-right-button true 2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close' 2>/dev/null || true

# ─── Files Configuration ────────────────────────────────────────────────
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'icon-view' 2>/dev/null || true
gsettings set org.gnome.nautilus.preferences show-create-link true 2>/dev/null || true
gsettings set org.gnome.nautilus.preferences show-delete-permanently true 2>/dev/null || true
gsettings set org.gnome.nautilus.preferences search-filter-time-type 'last_modified' 2>/dev/null || true

# ─── Terminal Configuration ─────────────────────────────────────────────
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ \
    visible-name 'ShadowOS Terminal' 2>/dev/null || true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ \
    use-theme-colors false 2>/dev/null || true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ \
    foreground-color '#f0f0ff' 2>/dev/null || true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ \
    background-color '#0a0a0f' 2>/dev/null || true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ \
    palette "#1a1a2e:#ff0055:#00ff88:#ffbf00:#00ffff:#ff00ff:#00d4ff:#c0c0c0:#555577:#ff3377:#00ffaa:#ffcc00:#55ffff:#ff55ff:#88ffff:#ffffff" 2>/dev/null || true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ \
    font 'JetBrains Mono 11' 2>/dev/null || true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ \
    use-system-font false 2>/dev/null || true
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")/ \
    scrollback-lines 10000 2>/dev/null || true

# ─── Screenshot Configuration ───────────────────────────────────────────
gsettings set org.gnome.gnome-screenshot auto-save-directory "file:///home/$USER/Pictures/Screenshots" 2>/dev/null || true
gsettings set org.gnome.gnome-screenshot include-pointer false 2>/dev/null || true
gsettings set org.gnome.gnome-screenshot include-border false 2>/dev/null || true

success "GNOME configured with ShadowOS theme"

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ GNOME configured with ShadowOS theme${NC}"
echo -e "${GREEN}  ✓ Dark mode enabled${NC}"
echo -e "${GREEN}  ✓ JetBrains Mono font set${NC}"
echo -e "${GREEN}  ✓ 10 workspaces configured${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"