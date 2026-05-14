#!/bin/bash
# ============================================================================
# ShadowOS Cyberpunk Theme Installer
# Installs all UI components: GTK, icons, cursors, SDDM, terminals, Neovim,
# Conky, Waybar modules, lock screen, Picom, Rofi, wallpapers, fonts.
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
error() { echo -e "  ${RED}✗${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_NAME="ShadowOS-Dark"
ICON_THEME="ShadowOS"
CURSOR_THEME="ShadowOS"

# ─── Helpers ──────────────────────────────────────────────────────────────────
run_as_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "  Requesting sudo for system installation..."
        sudo "$@"
    else
        "$@"
    fi
}

# ─── Start ────────────────────────────────────────────────────────────────────
step "SHADOWOS CYBERPUNK THEME INSTALLER"

# ─── 1. GTK Theme ─────────────────────────────────────────────────────────────
step "1. Installing GTK Theme ($THEME_NAME)"

THEME_SRC="$SCRIPT_DIR/gtk"
THEME_DST_SYS="/usr/share/themes/$THEME_NAME"
THEME_DST_USER="$HOME/.themes/$THEME_NAME"

# System-wide install
if [[ -d "$THEME_SRC" ]]; then
    run_as_root mkdir -p "$THEME_DST_SYS"
    run_as_root cp -r "$THEME_SRC/gtk-3.0" "$THEME_DST_SYS/"
    run_as_root cp -r "$THEME_SRC/gtk-4.0" "$THEME_DST_SYS/"
    run_as_root cp "$THEME_SRC/index.theme" "$THEME_DST_SYS/"
    success "GTK theme installed to $THEME_DST_SYS"
fi

# User install
mkdir -p "$THEME_DST_USER"
cp -r "$THEME_SRC/gtk-3.0" "$THEME_DST_USER/" 2>/dev/null || true
cp -r "$THEME_SRC/gtk-4.0" "$THEME_DST_USER/" 2>/dev/null || true
cp "$THEME_SRC/index.theme" "$THEME_DST_USER/" 2>/dev/null || true
success "GTK theme copied to ~/.themes/"

# ─── 2. Icon Theme ────────────────────────────────────────────────────────────
step "2. Installing Icon Theme ($ICON_THEME)"

ICON_SRC="$SCRIPT_DIR/icons/svg"
ICON_DST_SYS="/usr/share/icons/$ICON_THEME"
ICON_DST_USER="$HOME/.icons/$ICON_THEME"

if [[ -d "$ICON_SRC" ]]; then
    # Create icon theme structure
    run_as_root mkdir -p "$ICON_DST_SYS/apps"
    run_as_root mkdir -p "$ICON_DST_SYS/devices"
    run_as_root mkdir -p "$ICON_DST_SYS/mimetypes"
    run_as_root mkdir -p "$ICON_DST_SYS/places"

    # Copy SVG icons
    run_as_root cp "$ICON_SRC"/apps/*.svg "$ICON_DST_SYS/apps/" 2>/dev/null || true
    run_as_root cp "$ICON_SRC"/devices/*.svg "$ICON_DST_SYS/devices/" 2>/dev/null || true
    run_as_root cp "$ICON_SRC"/mimetypes/*.svg "$ICON_DST_SYS/mimetypes/" 2>/dev/null || true
    run_as_root cp "$ICON_SRC"/places/*.svg "$ICON_DST_SYS/places/" 2>/dev/null || true

    # Create index.theme
    cat > /tmp/icon-index.theme << ICON_INDEX
[Icon Theme]
Name=ShadowOS
Comment=Cyberpunk icon theme for ShadowOS
Inherits=default
Directories=apps,devices,mimetypes,places

[apps]
Size=48
MaxSize=512
Type=Scalable

[devices]
Size=48
MaxSize=512
Type=Scalable

[mimetypes]
Size=48
MaxSize=512
Type=Scalable

[places]
Size=48
MaxSize=512
Type=Scalable
ICON_INDEX
    run_as_root cp /tmp/icon-index.theme "$ICON_DST_SYS/index.theme"
    success "Icon theme installed to $ICON_DST_SYS"
fi

# User copy
mkdir -p "$ICON_DST_USER/apps" 2>/dev/null || true
cp "$ICON_SRC"/apps/*.svg "$ICON_DST_USER/apps/" 2>/dev/null || true
success "Icon theme copied to ~/.icons/"

# ─── 3. Cursor Theme ──────────────────────────────────────────────────────────
step "3. Installing Cursor Theme ($CURSOR_THEME)"

CURSOR_SRC="$SCRIPT_DIR/cursors"
CURSOR_DST_SYS="/usr/share/icons/$CURSOR_THEME"
CURSOR_DST_USER="$HOME/.icons/$CURSOR_THEME"

if [[ -d "$CURSOR_SRC" ]]; then
    run_as_root mkdir -p "$CURSOR_DST_SYS/cursors"
    run_as_root cp "$CURSOR_SRC"/*.cursor "$CURSOR_DST_SYS/cursors/" 2>/dev/null || true
    run_as_root cp "$CURSOR_SRC"/index.theme "$CURSOR_DST_SYS/" 2>/dev/null || true
    success "Cursor theme installed to $CURSOR_DST_SYS"
fi

mkdir -p "$CURSOR_DST_USER/cursors" 2>/dev/null || true
cp "$CURSOR_SRC"/*.cursor "$CURSOR_DST_USER/cursors/" 2>/dev/null || true
success "Cursor theme copied to ~/.icons/"

# ─── 4. SDDM Theme ────────────────────────────────────────────────────────────
step "4. Installing SDDM Login Theme"

SDDM_SRC="$SCRIPT_DIR/sddm/theme"
SDDM_DST="/usr/share/sddm/themes/ShadowOS"

if [[ -d "$SDDM_SRC" ]]; then
    run_as_root mkdir -p "$SDDM_DST"
    run_as_root cp "$SDDM_SRC"/*.qml "$SDDM_DST/"
    run_as_root cp "$SDDM_SRC"/*.conf "$SDDM_DST/"
    run_as_root cp "$SDDM_SRC"/*.png "$SDDM_DST/" 2>/dev/null || true
    success "SDDM theme installed to $SDDM_DST"
fi

# Set as default (optional)
if command -v sddm &>/dev/null; then
    read -p "Set ShadowOS as default SDDM theme? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_as_root sddm --example-config > /tmp/sddm.conf
        if [[ -f /etc/sddm.conf ]]; then
            run_as_root sed -i 's/^Theme=.*/Theme=ShadowOS/' /etc/sddm.conf 2>/dev/null || true
        fi
        success "SDDM theme set as default"
    fi
fi

# ─── 5. Rofi Theme ────────────────────────────────────────────────────────────
step "5. Installing Rofi Theme"

ROFI_SRC="$SCRIPT_DIR/rofi/shadowos.rasi"
ROFI_DST_USER="$HOME/.config/rofi/ShadowOS.rasi"

if [[ -f "$ROFI_SRC" ]]; then
    mkdir -p "$HOME/.config/rofi"
    cp "$ROFI_SRC" "$ROFI_DST_USER"
    success "Rofi theme installed to $ROFI_DST_USER"
fi

# ─── 6. Kitty Terminal Config ─────────────────────────────────────────────────
step "6. Installing Kitty Terminal Config"

KITTY_SRC="$SCRIPT_DIR/kitty/kitty.conf"
KITTY_DST_USER="$HOME/.config/kitty/kitty.conf"

if [[ -f "$KITTY_SRC" ]]; then
    mkdir -p "$HOME/.config/kitty"
    cp "$KITTY_SRC" "$KITTY_DST_USER"
    success "Kitty config installed to $KITTY_DST_USER"
fi

# ─── 7. Alacritty Config ──────────────────────────────────────────────────────
step "7. Installing Alacritty Config"

ALACRITTY_SRC="$SCRIPT_DIR/alacritty/alacritty.yml"
ALACRITTY_DST_USER="$HOME/.config/alacritty/alacritty.yml"

if [[ -f "$ALACRITTY_SRC" ]]; then
    mkdir -p "$HOME/.config/alacritty"
    cp "$ALACRITTY_SRC" "$ALACRITTY_DST_USER"
    success "Alacritty config installed to $ALACRITTY_DST_USER"
fi

# ─── 8. Neovim Configuration ─────────────────────────────────────────────────
step "8. Installing Neovim UI Enhancements"

NVIM_SRC="$SCRIPT_DIR/../terminal-setup/nvim"
NVIM_DST_USER="$HOME/.config/nvim"

if [[ -d "$NVIM_SRC" ]]; then
    mkdir -p "$NVIM_DST_USER"
    # Copy init.vim if exists
    [[ -f "$NVIM_SRC/init.vim" ]] && cp "$NVIM_SRC/init.vim" "$NVIM_DST_USER/init.vim"
    # Copy colorscheme
    mkdir -p "$NVIM_DST_USER/colors"
    [[ -f "$NVIM_SRC/cyberpunk.vim" ]] && cp "$NVIM_SRC/cyberpunk.vim" "$NVIM_DST_USER/colors/cyberpunk.vim"
    # Copy lua config if exists
    mkdir -p "$NVIM_DST_USER/lua"
    cp -r "$NVIM_SRC"/lua/* "$NVIM_DST_USER/lua/" 2>/dev/null || true
    # Copy after plugin
    mkdir -p "$NVIM_DST_USER/after/plugin"
    cp -r "$NVIM_SRC"/after/plugin/* "$NVIM_DST_USER/after/plugin/" 2>/dev/null || true
    success "Neovim config installed to $NVIM_DST_USER"
fi

# ─── 9. Conky Widget ──────────────────────────────────────────────────────────
step "9. Installing Conky Desktop Widget"

CONKY_SRC="$SCRIPT_DIR/conky/shadowos.conkyrc"
CONKY_DST_USER="$HOME/.config/conky/shadowos.conkyrc"

if [[ -f "$CONKY_SRC" ]]; then
    mkdir -p "$HOME/.config/conky"
    cp "$CONKY_SRC" "$CONKY_DST_USER"
    success "Conky config installed to $CONKY_DST_USER"
fi

# ─── 10. Waybar Custom Modules ────────────────────────────────────────────────
step "10. Installing Waybar Custom Modules"

WAYBAR_SRC="$SCRIPT_DIR/waybar"
WAYBAR_DST_USER="$HOME/.config/waybar"

if [[ -d "$WAYBAR_SRC" ]]; then
    mkdir -p "$WAYBAR_DST_USER"
    # Copy config
    [[ -f "$WAYBAR_SRC/config" ]] && cp "$WAYBAR_SRC/config" "$WAYBAR_DST_USER/"
    # Copy style
    [[ -f "$WAYBAR_SRC/style.css" ]] && cp "$WAYBAR_SRC/style.css" "$WAYBAR_DST_USER/"
    # Copy Python modules
    cp "$WAYBAR_SRC/modules"/*.py "$WAYBAR_DST_USER/modules/" 2>/dev/null || true
    # Make modules executable
    chmod +x "$WAYBAR_DST_USER/modules"/*.py 2>/dev/null || true
    success "Waybar config and modules installed to $WAYBAR_DST_USER"
fi

# ─── 11. Lock Screen (Swaylock) ───────────────────────────────────────────────
step "11. Installing Lock Screen Config"

LOCK_SRC="$SCRIPT_DIR/lock/swaylock.conf"
LOCK_DST_USER="$HOME/.config/swaylock/config"

if [[ -f "$LOCK_SRC" ]]; then
    mkdir -p "$HOME/.config/swaylock"
    cp "$LOCK_SRC" "$LOCK_DST_USER"
    success "Swaylock config installed to $LOCK_DST_USER"
fi

# ─── 12. Picom Enhanced ───────────────────────────────────────────────────────
step "12. Installing Enhanced Picom Config"

PICOM_SRC="$SCRIPT_DIR/picom/picom.conf"
PICOM_DST_USER="$HOME/.config/picom/picom.conf"

if [[ -f "$PICOM_SRC" ]]; then
    mkdir -p "$HOME/.config/picom"
    cp "$PICOM_SRC" "$PICOM_DST_USER"
    success "Picom config installed to $PICOM_DST_USER"
fi

# ─── 13. Environment Variables ────────────────────────────────────────────────
step "13. Setting Environment Variables"

PROFILE_FILE="$HOME/.profile"
ZSHRC_FILE="$HOME/.zshrc"

# Add to .profile if not present
if [[ -f "$PROFILE_FILE" ]]; then
    grep -q "GTK_THEME=$THEME_NAME" "$PROFILE_FILE" 2>/dev/null || {
        echo "" >> "$PROFILE_FILE"
        echo "# ShadowOS Theme" >> "$PROFILE_FILE"
        echo "export GTK_THEME=$THEME_NAME" >> "$PROFILE_FILE"
        echo "export ICON_THEME=$ICON_THEME" >> "$PROFILE_FILE"
        echo "export XCURSOR_THEME=$CURSOR_THEME" >> "$PROFILE_FILE"
        echo "export XCURSOR_SIZE=24" >> "$PROFILE_FILE"
        success "Environment variables added to ~/.profile"
    }
fi

# Also add to .zshrc if exists
if [[ -f "$ZSHRC_FILE" ]]; then
    grep -q "GTK_THEME=" "$ZSHRC_FILE" 2>/dev/null || {
        echo "" >> "$ZSHRC_FILE"
        echo "# ShadowOS Theme" >> "$ZSHRC_FILE"
        echo "export GTK_THEME=$THEME_NAME" >> "$ZSHRC_FILE"
        echo "export ICON_THEME=$ICON_THEME" >> "$ZSHRC_FILE"
        echo "export XCURSOR_THEME=$CURSOR_THEME" >> "$ZSHRC_FILE"
        success "Environment variables added to ~/.zshrc"
    }
fi

# ─── 14. Qt5/Qt6 Theme ─────────────────────────────────────────────────────────
step "14. Configuring Qt5/Qt6 Theme"

QT_SETTINGS="$HOME/.config/qt5ct/qt5ct.conf"
mkdir -p "$HOME/.config/qt5ct"
if [[ ! -f "$QT_SETTINGS" ]]; then
    cat > "$QT_SETTINGS" << QTEOF
[Appearance]
style=ShadowOS-Dark
palette=ShadowOS-Dark
icon_theme=ShadowOS
font=JetBrains Mono 11
QTEOF
    success "Qt5ct config created"
fi

# ─── 14. Wallpaper Setup ─────────────────────────────────────────────────────────
step "14. Setting Up Wallpaper"

WALLPAPER_SRC="$SCRIPT_DIR/wallpapers"
WALLPAPER_DST_USER="$HOME/.config/shadowos/cyberpunk-theme/wallpapers"
WALLPAPER_DST_SYS="/usr/share/backgrounds/shadowos"

if [[ -d "$WALLPAPER_SRC" ]]; then
    # User installation
    mkdir -p "$(dirname "$WALLPAPER_DST_USER")"
    cp -r "$WALLPAPER_SRC" "$(dirname "$WALLPAPER_DST_USER")/" 2>/dev/null || true
    success "Wallpaper files installed to ~/.config/shadowos/cyberpunk-theme/wallpapers/"

    # System-wide installation for SDDM and display managers
    if [[ -f "$WALLPAPER_SRC/wallpaper1.png" ]]; then
        run_as_root mkdir -p "$WALLPAPER_DST_SYS"
        run_as_root cp "$WALLPAPER_SRC/wallpaper1.png" "$WALLPAPER_DST_SYS/"
        run_as_root chmod 644 "$WALLPAPER_DST_SYS/wallpaper1.png"
        success "System wallpaper installed to $WALLPAPER_DST_SYS/"

        # Update SDDM theme to use system wallpaper
        if [[ -d "/usr/share/sddm/themes/ShadowOS" ]]; then
            run_as_root sed -i 's|^Background=.*|Background=../wallpapers/wallpaper1.png|' /usr/share/sddm/themes/ShadowOS/theme.conf 2>/dev/null || true
            run_as_root sed -i 's|^Background=.*|Background=/usr/share/backgrounds/shadowos/wallpaper1.png|' /usr/share/sddm/themes/ShadowOS/theme.conf 2>/dev/null || true
            success "SDDM wallpaper path updated"
        fi
    fi

    # Offer to set user wallpaper
    if command -v feh &>/dev/null; then
        read -p "Set wallpaper with feh now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            feh --bg-fill "$WALLPAPER_DST_USER/wallpapers/wallpaper1.png" 2>/dev/null || true
            success "Wallpaper set with feh"
        fi
    fi
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ ShadowOS Cyberpunk Theme Installation Complete${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}Installed components:${NC}"
echo -e "    • GTK Theme: $THEME_NAME"
echo -e "    • Icon Theme: $ICON_THEME"
echo -e "    • Cursor Theme: $CURSOR_THEME"
echo -e "    • SDDM Login Theme"
echo -e "    • Rofi Launcher Theme"
echo -e "    • Kitty & Alacritty Terminal Configs"
echo -e "    • Neovim UI Enhancements"
echo -e "    • Conky Desktop Widget"
echo -e "    • Waybar Config + AI & Security Modules"
echo -e "    • Swaylock Lock Screen"
echo -e "    • Enhanced Picom (blur, animations, wobbly)"
echo -e "    • Cyber City Wallpaper (BeltrixOS style)"
echo ""
echo -e "  ${YELLOW}To activate:${NC}"
echo -e "    • Log out and log back in (for GTK/icon theme)"
echo -e "    • Or run: gsettings set org.gnome.desktop.interface gtk-theme '$THEME_NAME'"
echo -e "    • For SDDM: sudo sddm --example-config | sudo tee /etc/sddm.conf"
echo -e "    • For Waybar: killall waybar && waybar &"
echo ""
echo -e "  ${CYAN}Enjoy your cyberpunk desktop! 🌑${NC}"
echo ""
 
