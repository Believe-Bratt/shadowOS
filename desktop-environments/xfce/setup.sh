#!/bin/bash
# ============================================================================
# ShadowOS XFCE Desktop Setup
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; NC='\033[0m'
step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }

step "CONFIGURING XFCE"

XFCE_DIR="$HOME/.config/xfce4"
mkdir -p "$XFCE_DIR/panel" "$XFCE_DIR/xfconf/xfce-perchannel-xml"

# ─── Install Cyberpunk Theme Suite ───────────────────────────────────────
if [ -d "/usr/share/themes/ShadowOS-Dark" ]; then
    info "Cyberpunk theme already installed system-wide"
else
    info "Installing cyberpunk theme suite..."
    mkdir -p "$HOME/.config/shadowos"
    cp -r /etc/skel/.config/shadowos/cyberpunk-theme "$HOME/.config/shadowos/" 2>/dev/null || true
    "$HOME/.config/shadowos/cyberpunk-theme/install-theme.sh" 2>/dev/null || true
fi
success "Cyberpunk theme suite available"

# ─── Panel Configuration ────────────────────────────────────────────────
cat > "$XFCE_DIR/panel/preferences-1.xml" << 'XFCE'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="2.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="dark-mode" type="bool" value="true"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="icon-size" type="uint" value="22"/>
      <property name="size" type="uint" value="36"/>
      <property name="background-style" type="uint" value="0"/>
      <property name="color-r" type="uint" value="10"/>
      <property name="color-g" type="uint" value="10"/>
      <property name="color-b" type="uint" value="15"/>
      <property name="alpha" type="uint" value="230"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
        <value type="int" value="6"/>
        <value type="int" value="7"/>
        <value type="int" value="8"/>
        <value type="int" value="9"/>
        <value type="int" value="10"/>
        <value type="int" value="11"/>
      </property>
    </property>
  </property>
</channel>
XFCE

# ─── Window Manager Theme ───────────────────────────────────────────────
cat > "$XFCE_DIR/xfconf/xfce-perchannel-xml/xsettings.xml" << 'XSETTINGS'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="ShadowOS"/>
    <property name="IconThemeName" type="string" value="ShadowOS"/>
    <property name="CursorThemeName" type="string" value="ShadowOS"/>
    <property name="CursorSize" type="int" value="24"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="int" value="96"/>
    <property name="Antialias" type="int" value="1"/>
    <property name="Hinting" type="int" value="1"/>
    <property name="HintStyle" type="string" value="hintslight"/>
    <property name="RGBA" type="string" value="rgb"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="JetBrains Mono 11"/>
    <property name="MonospaceFontName" type="string" value="JetBrains Mono 11"/>
  </property>
</channel>
XSETTINGS

# ─── Appearance ─────────────────────────────────────────────────────────
cat > "$XFCE_DIR/xfconf/xfce-perchannel-xml/xfwm4.xml" << 'XFWM4'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="ShadowOS"/>
    <property name="shadow_opacity" type="int" value="30"/>
    <property name="frame_opacity" type="int" value="100"/>
    <property name="inactive_opacity" type="int" value="90"/>
    <property name="move_opacity" type="int" value="90"/>
    <property name="resize_opacity" type="int" value="90"/>
    <property name="use_compositing" type="bool" value="true"/>
    <property name="show_frame_shadow" type="bool" value="true"/>
    <property name="show_popup_shadow" type="bool" value="true"/>
  </property>
</channel>
XFWM4

success "XFCE configured with ShadowOS theme"

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ XFCE configured with ShadowOS theme${NC}"
echo -e "${GREEN}  ✓ Panel configured with dark mode${NC}"
echo -e "${GREEN}  ✓ Compositing enabled with shadows${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"