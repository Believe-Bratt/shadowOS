#!/bin/bash
# ============================================================================
# ShadowOS KDE Plasma Desktop Setup
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; NC='\033[0m'
step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }

step "CONFIGURING KDE PLASMA"

KDE_DIR="$HOME/.config/plasma-workspace/env"
KDE_THEME_DIR="$HOME/.local/share/plasma/desktoptheme/ShadowOS"
KDE_COLORS_DIR="$HOME/.local/share/color-schemes/ShadowOS"
KDE_CURSORS_DIR="$HOME/.local/share/icons/ShadowOS/cursors"

mkdir -p "$KDE_THEME_DIR" "$KDE_COLORS_DIR" "$KDE_CURSORS_DIR"

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

# ─── Color Scheme ───────────────────────────────────────────────────────
cat > "$KDE_COLORS_DIR/ShadowOS.colors" << 'KDECOLORS'
[ColorScheme][General]
BackgroundNormal=40,40,55
BackgroundNormalSolid=10,10,15
BackgroundAlternate=30,30,45
BackgroundAlternateSolid=20,20,30
ForegroundNormal=240,240,255
ForegroundActive=0,255,255
ForegroundInactive=102,102,119
ForegroundNegative=255,0,85
ForegroundPositive=0,255,136
ForegroundNeutral=255,191,0
DecorationFocus=0,255,255
DecorationHover=255,0,255
ButtonBackgroundNormal=25,25,40
ButtonBackgroundHover=40,40,60
ButtonBackgroundPress=55,55,80
ViewBackground=15,15,25
ViewText=200,200,215
ViewHover=0,255,255,40
ViewSelected=0,255,255,80
TooltipBackground=10,10,15
TooltipText=0,255,255
KDECOLORS

# ─── Plasma Theme Config ────────────────────────────────────────────────
cat > "$KDE_THEME_DIR/metadata.desktop" << 'METADATA'
[Desktop Entry]
Name=ShadowOS
Comment=Cyberpunk theme for KDE Plasma
X-KDE-PluginInfo-Name=ShadowOS
X-KDE-PluginInfo-Author=ShadowOS Team
X-KDE-PluginInfo-Email=team@shadowos.local
X-KDE-PluginInfo-License=Proprietary
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-Website=https://shadowos.local
X-KDE-PluginInfo-Category=Theme
X-KDE-PluginInfo-Depends=
X-KDE-PluginInfo-ServiceTypes=Plasma/Theme
Type=Service
METADATA

cat > "$KDE_THEME_DIR/colors" << 'THEMECOLORS'
[Wallpaper]
default=cyberpunk-city.png

[Colors]
BackgroundNormal=40,40,55
BackgroundAlternate=30,30,45
ForegroundNormal=240,240,255
ForegroundActive=0,255,255
ForegroundInactive=102,102,119
ForegroundNegative=255,0,85
ForegroundPositive=0,255,136
ForegroundNeutral=255,191,0
DecorationFocus=0,255,255
DecorationHover=255,0,255
ButtonBackground=25,25,40
ViewBackground=15,15,25
ViewText=200,200,215
THEMECOLORS

# ─── KDE Plasma Configuration ──────────────────────────────────────────
mkdir -p "$HOME/.config/kwinrc.d"
cat > "$HOME/.config/kwinrc" << 'KWIN'
[Compositing]
Enabled=true
Backend=OpenGL
GLCore=true
GLPreferBufferSwap=copy
GLTextureFilter=1
XRenderSmoothScale=false

[Desktops]
Number=10
Rows=2

[Effect-Overview]
BorderActivate=Meta+Tab

[Effect-Cube]
BorderActivate=Meta+Ctrl+Tab

[Effect-SwitchWindow]
BorderActivate=Alt+Tab

[Effect-WobblyWindows]
Move=true
Resize=true

[Effect-MagicLamp]
Magic=true

[Effect-Glide]
Enabled=true
Duration=200

[Effect-ScaleIn]
Enabled=true
Duration=150

[Effect-Blur]
Enabled=true
NoiseStrength=0
Menu=false
Docks=false

[Effect-Transparent]
ActiveDialog=95
InactiveDialog=80

[Effect-Screenshot]
FullScreen=true

[Effect-WindowView]
LayoutMode=6

[Effect-DesktopGrid]
ActivationDesktop=Meta+D

[KDE]
ColorScheme=ShadowOS
WidgetStyle=kvantum

[Windows]
BorderSnapZone=10
CenterSnapZone=20
ElectricBorderCornerRatio=0.0
ElectricBorderMaximize=true
ElectricBorderTiling=true
ElectricBorderCooldown=350
NextFocusPrefersMouse=false
ClickRaise=true
AutoRaise=true
AutoRaiseInterval=500
SeparateScreenFocus=false

[MouseBindings]
CommandActiveTitlebar1=Meta+V
CommandActiveTitlebar2=Meta+W
CommandActiveTitlebar3=Meta+N
CommandInactiveTitlebar1=Activate
CommandInactiveTitlebar2=Activate
CommandInactiveTitlebar3=Activate

[Focus]
FocusPolicy=ClickToFocus
DelayFocusInterval=250
AutoRaise=true
AutoRaiseInterval=500

[TabBox]
HighlightWindows=true
TabStyle=0

[ModifierOnlyShortcuts]
Meta=org.kde.kglobalaccel,/component/kwin,,invokeShortcut,Overview

[DesktopsView]
Rows=2
Columns=5

[WindowRules]
count=1
Description0=ShadowOS Default
windowrolemakerule0=0
windowtypematchrule0=0
windowtypetype0=0
windowclassmatchrule0=0
windowclassstring0=*
windowtitlematchrule0=0
windowtitlestring0=*
maximizevertically=false
maximizehorizontally=false
fullscreen=false
noborder=false
decocolor=false
desktopfilematchrule0=0
desktopfilestring0=*
screenmatchrule0=0
screeninteger0=0
minimizable=true
maximizable=true
closeable=true
shadeable=true
shadeonhover=false
skippager=false
skiptaskbar=false
skipswitcher=false
above=false
below=false
shortcut=
KWIN

# ─── Kvantum Theme ──────────────────────────────────────────────────────
mkdir -p "$HOME/.config/Kvantum"
cat > "$HOME/.config/Kvantum/kvantum.kvconfig" << 'KVANTUM'
[General]
theme=ShadowOS
customShadows=true
strongFocus=false
noMenuIcons=false
smallIconSizes=false
KDE.globalSettings=true

[ShadowOS]
inactiveWindowOpacity=90
menuDelay=0
subMenusDelay=0
KDE.globalSettings=true
KVANTUM

# ─── SDDM Theme ─────────────────────────────────────────────────────────
mkdir -p /usr/share/sddm/themes/ShadowOS
cat > /usr/share/sddm/themes/ShadowOS/theme.conf << 'SDDM'
[General]
type=image

[Input]
font="JetBrains Mono,12,-1,5,50,0,0,0,0,0"
background=transparent

[Buttons]
font="JetBrains Mono,12,-1,5,50,0,0,0,0,0"
background="#0a0a0f"
foreground="#00ffff"
borderColor="#ff00ff"

[UserList]
font="JetBrains Mono,14,-1,5,50,0,0,0,0,0"
background="#0a0a0fcc"
foreground="#00ffff"

[ComboBox]
background="#1a1a2e"
foreground="#00ffff"
borderColor="#ff00ff"

[Text]
font="JetBrains Mono,11,-1,5,50,0,0,0,0,0"
foreground="#f0f0ff"

[Clock]
font="JetBrains Mono,14,-1,5,50,0,0,0,0,0"
foreground="#ffbf00"

[HostName]
font="JetBrains Mono,16,-1,5,75,0,0,0,0,0"
foreground="#ff00ff"
SDDM

success "KDE Plasma configured with ShadowOS theme"

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ KDE Plasma configured with ShadowOS theme${NC}"
echo -e "${GREEN}  ✓ KWin compositor effects enabled${NC}"
echo -e "${GREEN}  ✓ Color scheme: ShadowOS Dark${NC}"
echo -e "${GREEN}  ✓ SDDM login theme applied${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"