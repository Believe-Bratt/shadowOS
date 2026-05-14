# ShadowOS × BeltrixOS Style Guide

## Overview

This document describes the BeltrixOS-inspired visual redesign of ShadowOS. The theme has been updated to match the futuristic cyberpunk aesthetic showcased at [beltrix-os-forge.lovable.app](https://beltrix-os-forge.lovable.app).

## Design Philosophy

BeltrixOS represents "Future. Controlled." — a sleek, neon-lit interface that combines cyberpunk aesthetics with practical usability. ShadowOS now adopts this design language across all UI components.

## Color Palette

### Primary Neon Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| **Neon Cyan** | `#00ffff` | rgb(0, 255, 255) | Primary accent, borders, highlights |
| **Neon Purple** | `#c54dff` | rgb(197, 77, 255) | Secondary accent, AI features |
| **Neon Magenta** | `#ff00ff` | rgb(255, 0, 255) | Tertiary accent, active states |
| **Neon Amber** | `#ffbf00` | rgb(255, 191, 0) | Warnings, disk usage |
| **Neon Green** | `#00ff88` | rgb(0, 255, 136) | Success, security status |
| **Neon Red** | `#ff0055` | rgb(255, 0, 85) | Errors, critical alerts |

### Backgrounds

| Name | Value | Usage |
|------|-------|-------|
| **bg_dark** | `#0a0a0f` | Main background (deep black-blue) |
| **bg_panel** | `#1a1a2e` | Panel backgrounds (semi-transparent) |
| **bg_glass** | `rgba(26, 26, 46, 0.6)` | Glassmorphism panels |
| **fg_light** | `#f0f0ff` | Primary text (off-white) |
| **fg_dim** | `#8888aa` | Secondary text (muted) |

## Component Updates

### 1. GTK Theme (`cyberpunk-theme/gtk/`)

**Changes:**
- Updated color definitions to use BeltrixOS palette
- Enhanced window borders with neon glow (`box-shadow`)
- Improved progress bars with gradient fills (cyan → magenta)
- Better focus indicators with neon outlines
- Glassmorphism effects on panels using semi-transparent backgrounds

**Files modified:**
- `gtk-3.0/gtk.css` — Complete color palette update
- `index.theme` — Theme metadata

**Key CSS variables:**
```css
@define-color neon_cyan #00ffff;
@define-color neon_purple #c54dff;
@define-color neon_magenta #ff00ff;
@define-color bg_glass rgba(26, 26, 46, 0.6);
```

### 2. Waybar (`cyberpunk-theme/waybar/`)

**New files:**
- `config` — Waybar configuration with modules for AI, security, system monitoring
- `style.css` — BeltrixOS-inspired styling with glassmorphism and neon borders
- `modules/ai-status.py` — Python module for Ollama AI status
- `modules/security-status.py` — Python module for firewall/Tor/VPN/AppArmor status

**Features:**
- Top panel with neon cyan bottom border and glow
- Glassmorphic module backgrounds (`rgba(26, 26, 46, 0.6)`)
- Color-coded modules:
  - Clock: Purple (`#c54dff`)
  - CPU: Cyan (`#00ffff`)
  - Memory: Magenta (`#ff00ff`)
  - Disk: Amber (`#ffbf00`)
  - Battery: Green (`#00ff88`) / Red (critical)
  - AI Status: Purple
  - Security Status: Green
  - Power: Red
- Workspace buttons with active glow effect
- Tooltips with neon borders

### 3. SDDM Login Screen (`cyberpunk-theme/sddm/`)

**Changes:**
- Updated color palette to use neon purple instead of magenta
- Enhanced glow effects on login button and borders
- Maintained the animated grid background and corner decorations
- Clock now uses cyan/magenta color scheme

**Files modified:**
- `theme/Main.qml` — Color property updates and styling

### 4. Conky System Monitor (`cyberpunk-theme/conky/`)

**Changes:**
- Reformatted to match BeltrixOS "System Overview" panel layout
- Color-coded sections:
  - CPU: Cyan
  - RAM: Magenta
  - Disk: Amber
  - Swap: Cyan
  - Network: Cyan
  - AI Activity: Purple
  - Security: Green
  - Uptime/Time: Magenta/Amber
- Improved border styling with neon colors
- Better spacing and organization

**File modified:**
- `shadowos.conkyrc`

### 5. Rofi Launcher (`cyberpunk-theme/rofi/`)

**Changes:**
- Updated accent color from magenta to purple (`#c54dff`)
- Increased border radius to 10px for softer look
- Selected items now use purple background with cyan border
- Enhanced box-shadow for neon glow effect

**File modified:**
- `shadowos.rasi`

### 6. Terminal Colors

#### Alacritty (`cyberpunk-theme/alacritty/`)
- Updated `color5` (magenta) from `#ff00ff` → `#c54dff`
- Updated bright magenta `color13` from `#ff55ff` → `#d47dff`
- Vi mode cursor now uses purple for visual distinction

#### Kitty (`cyberpunk-theme/kitty/`)
- Same color updates as Alacritty
- Maintained all other cyberpunk styling (blur, borders, tabs)

### 7. Picom Compositor (`cyberpunk-theme/picom/`)

**Enhancements:**
- Increased blur strength from 8 → 12 for stronger glassmorphism
- Increased shadow radius from 15 → 20 for more pronounced glow
- Increased shadow opacity to 0.5 for better visibility
- Added note about neon glow simulation via shadows

**File modified:**
- `picom.conf`

### 8. Wallpapers (`cyberpunk-theme/wallpapers/`)

**New directory:**
- Contains wallpaper setup scripts
- `setup-wallpaper.sh` — Bash script to download cyber city wallpaper
- `setup-wallpaper.bat` — Windows batch file alternative
- `README.md` — Instructions for wallpaper setup and sources

**Recommended:** Dark cyberpunk cityscape with neon lights that complement the cyan/purple palette.

## Installation

Run the main installer to apply all components:

```bash
cd cyberpunk-theme
./install-theme.sh
```

The installer will:
1. Install GTK theme (system-wide and user)
2. Install icons and cursors
3. Install SDDM login theme
4. Install Rofi launcher theme
5. Install Kitty terminal config
6. Install Alacritty terminal config
7. Install Neovim UI enhancements
8. Install Conky desktop widget
9. Install Waybar config + Python modules
10. Install Swaylock config
11. Install enhanced Picom config
12. Set environment variables
13. Configure Qt5/Qt6 themes
14. **NEW:** Setup wallpaper

## Manual Component Activation

### Waybar
After installation, restart Waybar:
```bash
killall waybar && waybar &
```

The AI and Security modules require Python 3 and the following system services:
- `ollama` for AI status
- `nftables` for firewall
- `tor` for Tor status
- `wireguard` or `wg` for VPN
- `apparmor` for security

### Conky
Add to your startup:
```bash
conky -c ~/.config/conky/shadowos.conkyrc
```

Or for Hyprland, add to `~/.config/hypr/hyprland.conf`:
```
exec-once = conky -c ~/.config/conky/shadowos.conkyrc
```

### SDDM
Set as default:
```bash
sudo sddm --example-config | sudo tee /etc/sddm.conf
sudo sed -i 's/^Theme=.*/Theme=ShadowOS/' /etc/sddm.conf
```

### Rofi
Add to your keybindings (e.g., in Sway/Hyprland):
```
bindsym $mod+d exec rofi -show drun -theme ShadowOS
```

## Color Reference Summary

| Element | Color | Hex |
|---------|-------|-----|
| Primary accent | Cyan | `#00ffff` |
| Secondary accent | Purple | `#c54dff` |
| Tertiary accent | Magenta | `#ff00ff` |
| Warning | Amber | `#ffbf00` |
| Success | Green | `#00ff88` |
| Error | Red | `#ff0055` |
| Background | Dark | `#0a0a0f` |
| Panel | Semi-transparent | `rgba(26,26,46,0.85)` |

## Design Principles

1. **Neon Glow**: All interactive elements have subtle glow effects via box-shadow
2. **Glassmorphism**: Panels use semi-transparent backgrounds with blur (via Picom)
3. **Color Coding**: Each system component has a dedicated neon color
4. **Consistent Borders**: 1-2px neon borders on all UI elements
5. **Smooth Animations**: Fading, wobbly windows, and transitions via Picom
6. **Monospace Fonts**: JetBrains Mono throughout for that terminal/hacker feel

## Compatibility

- **Desktop Environments**: Hyprland, Sway, GNOME, KDE, XFCE
- **Window Managers**: i3, bspwm, awesome, dwm
- **Display Managers**: SDDM (themed), LightDM (GTK theme works)
- **Terminals**: Kitty, Alacritty (configs provided)
- **Launchers**: Rofi (themed)
- **Panels**: Waybar (themed), Polybar (manual config needed)

## Troubleshooting

### GTK theme not applying
```bash
# Check available themes
ls ~/.themes/ /usr/share/themes/

# Set manually
gsettings set org.gnome.desktop.interface gtk-theme "ShadowOS-Dark"
gsettings set org.gnome.desktop.interface icon-theme "ShadowOS"
```

### Waybar modules not working
Ensure Python 3 is installed and modules are executable:
```bash
chmod +x ~/.config/waybar/modules/*.py
```

### Picom blur not working
Make sure your GPU drivers support GLX:
```bash
glxinfo | grep "GLX"
```

If using NVIDIA, you may need to set:
```bash
export __GLX_VENDOR_LIBRARY_NAME=nvidia
```

## Credits

- **BeltrixOS** — Design inspiration and aesthetic direction
- **ShadowOS** — Original cyberpunk theme framework
- **Lovable** — BeltrixOS forge platform

---

*Last updated: 2026-05-14*
*ShadowOS Cyberpunk Theme — BeltrixOS Edition*
