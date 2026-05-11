#!/bin/bash
# ============================================================================
# ShadowOS Hyprland Desktop Setup
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; NC='\033[0m'
step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }

step "CONFIGURING HYPRLAND WAYLAND COMPOSITOR"

mkdir -p ~/.config/hypr

# ─── Main Hyprland Config ───────────────────────────────────────────────
cat > ~/.config/hypr/hyprland.conf << 'HYPRLAND'
# ShadowOS Hyprland Configuration
# Cyberpunk-themed Wayland compositor

# ─── General ────────────────────────────────────────────────────────────
monitor=,preferred,auto,1

# Gaps
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(00ffffee)
    col.inactive_border = rgba(555577aa)
}

# ─── Decoration ─────────────────────────────────────────────────────────
decoration {
    rounding = 10
    shadow {
        enabled = true
        range = 15
        render_power = 3
        color = rgba(00000066)
    }
    blur {
        enabled = true
        size = 8
        passes = 2
        new_optimizations = on
        noise = 0.0117
        contrast = 0.5
        brightness = 0.1
        vibrancy = 0.16
        vibrancy_darkness = 0.0
    }
    dim_inactive = true
    dim_strength = 0.5
}

# ─── Animations ─────────────────────────────────────────────────────────
animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# ─── Windows ────────────────────────────────────────────────────────────
windows_rules {
    float, title:^(Picture-in-Picture)$
    float, title:^(File Upload|Confirm|Alert|Download|Open File)$
    float, class:^(pavucontrol|nm-connection-editor|blueman-manager)$
    float, class:^(steam)$
    float, class:^(file_progress|progress)$
    pin, class:^(Picture-in-Picture)$
}

# ─── Master Layout ──────────────────────────────────────────────────────
master {
    new_status = master
    orientation = center
}

# ─── Misc ────────────────────────────────────────────────────────────────
misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    focus_on_activate = true
    new_window_takes_over_fullscreen = 1
    animate_manual_resizes = true
    middle_click_paste = true
}

# ─── Input ──────────────────────────────────────────────────────────────
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =
    follow_mouse = 1
    sensitivity = 0
    touchpad {
        natural_scroll = true
        tap-to-click = true
        drag_lock = true
    }
}

# ─── Gestures ───────────────────────────────────────────────────────────
gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 300
    workspace_swipe_invert = true
}

# ─── Per-Workspace Settings ─────────────────────────────────────────────
workspace = 1, gapsout:0, gapsin:0
workspace = 2, gapsout:0, gapsin:0
workspace = 3, gapsout:0, gapsin:0
workspace = 4, gapsout:0, gapsin:0
workspace = 5, gapsout:0, gapsin:0
workspace = 6, gapsout:0, gapsin:0
workspace = 7, gapsout:0, gapsin:0
workspace = 8, gapsout:0, gapsin:0
workspace = 9, gapsout:0, gapsin:0
workspace = 10, gapsout:0, gapsin:0

# ─── Keybinds ───────────────────────────────────────────────────────────
# Super = Mod
$mainMod = SUPER

# Kill active window
bind = $mainMod, Q, killactive

# Fullscreen
bind = $mainMod, F, fullscreen

# Toggle floating
bind = $mainMod, Shift, F, togglefloating

# Fake fullscreen
bind = $mainMod, Shift, Z, fakefullscreen

# Move focus
bind = $mainMod, Left, movefocus, l
bind = $mainMod, Right, movefocus, r
bind = $mainMod, Up, movefocus, u
bind = $mainMod, Down, movefocus, d

# Move window
bind = $mainMod Shift, Left, movewindow, l
bind = $mainMod Shift, Right, movewindow, r
bind = $mainMod Shift, Up, movewindow, u
bind = $mainMod Shift, Down, movewindow, d

# Resize
bind = $mainMod Ctrl, Left, resizeactive, -50 0
bind = $mainMod Ctrl, Right, resizeactive, 50 0
bind = $mainMod Ctrl, Up, resizeactive, 0 -50
bind = $mainMod Ctrl, Down, resizeactive, 0 50

# Workspace navigation
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move to workspace
bind = $mainMod Shift, 1, movetoworkspace, 1
bind = $mainMod Shift, 2, movetoworkspace, 2
bind = $mainMod Shift, 3, movetoworkspace, 3
bind = $mainMod Shift, 4, movetoworkspace, 4
bind = $mainMod Shift, 5, movetoworkspace, 5
bind = $mainMod Shift, 6, movetoworkspace, 6
bind = $mainMod Shift, 7, movetoworkspace, 7
bind = $mainMod Shift, 8, movetoworkspace, 8
bind = $mainMod Shift, 9, movetoworkspace, 9
bind = $mainMod Shift, 0, movetoworkspace, 10

# Special workspace
bind = $mainMod, S, togglespecialworkspace
bind = $mainMod Shift, S, movetoworkspace, special

# Scroll workspace
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Window cycling
bind = $mainMod, Tab, cyclenext
bind = $mainMod Shift, Tab, cyclelast

# Center window
bind = $mainMod, C, centerwindow

# Toggle split
bind = $mainMod, U, togglesplit

# Submap for scratchpads
bind = $mainMod, P, submap, scratchpads
submap = scratchpads
bind = $mainMod, P, submap, reset
bind = , Escape, submap, reset
submap = reset

# ─── Exec ───────────────────────────────────────────────────────────────
exec-once = waybar
exec-once = dunst
exec-once = nm-applet
exec-once = blueman-applet
exec-once = picom --config ~/.config/picom/picom.conf
exec-once = hyprpaper
exec-once = kanshi
exec-once = swaync

# ─── Environment Variables ──────────────────────────────────────────────
env = XCURSOR_SIZE, 24
env = HYPRCURSOR_SIZE, 24
env = QT_QPA_PLATFORMTHEME, qt5ct
env = GTK_THEME, ShadowOS-Dark
env = MOZ_ENABLE_WAYLAND, 1
HYPRLAND

success "Hyprland configured"

# ─── Waybar Configuration ───────────────────────────────────────────────
mkdir -p ~/.config/waybar
cat > ~/.config/waybar/config << 'WAYBAR'
{
    "layer": "top",
    "position": "top",
    "height": 32,
    "margin-top": 4,
    "margin-left": 8,
    "margin-right": 8,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery", "tray"],

    "hyprland/workspaces": {
        "format": "{icon}",
        "on-click": "activate",
        "format-icons": {
            "1": "1", "2": "2", "3": "3", "4": "4", "5": "5",
            "6": "6", "7": "7", "8": "8", "9": "9", "10": "10",
            "active": "█", "default": "○"
        },
        "persistent-workspaces": {
            "1": [], "2": [], "3": [], "4": [], "5": [],
            "6": [], "7": [], "8": [], "9": [], "10": []
        }
    },

    "hyprland/window": {
        "format": "{}",
        "max-length": 60,
        "separate-outputs": true
    },

    "clock": {
        "format": " {:%H:%M:%S  %d/%m/%Y}",
        "format-alt": " {:%A, %B %d, %Y}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },

    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": "🔇 MUTED",
        "format-icons": {"default": ["🔈", "🔉", "🔊"]},
        "on-click": "pavucontrol"
    },

    "network": {
        "format-wifi": "📶 {essid} ({signalStrength}%)",
        "format-ethernet": "🔌 {ipaddr}/{cidr}",
        "format-disconnected": "⚠ Disconnected",
        "tooltip-format": "{ifname}: {ipaddr}/{cidr}"
    },

    "cpu": {
        "format": "⚡ {usage}%",
        "interval": 2,
        "on-click": "alacritty -e htop"
    },

    "memory": {
        "format": "🧠 {}%",
        "interval": 5,
        "on-click": "alacritty -e htop"
    },

    "battery": {
        "states": {"warning": 30, "critical": 15},
        "format": "{icon} {capacity}%",
        "format-charging": "⚡ {capacity}%",
        "format-plugged": "⚡ {capacity}%",
        "format-icons": ["🔋", "🪫"]
    },

    "tray": {
        "icon-size": 18,
        "spacing": 10
    }
}
WAYBAR

cat > ~/.config/waybar/style.css << 'WAYBAR_CSS'
* {
    font-family: "JetBrains Mono";
    font-size: 12px;
    border-radius: 6px;
}

window#waybar {
    background: rgba(10, 10, 15, 0.9);
    color: #f0f0ff;
    border-bottom: 2px solid #00ffff;
}

#workspaces button {
    padding: 0 8px;
    color: #666677;
    background: transparent;
}

#workspaces button.active {
    color: #0a0a0f;
    background: #00ffff;
}

#workspaces button:hover {
    color: #00ffff;
    background: rgba(0, 255, 255, 0.2);
}

#window {
    color: #ff00ff;
    font-weight: bold;
    padding: 0 12px;
}

#clock {
    color: #00ffff;
    padding: 0 12px;
}

#cpu, #memory {
    color: #00ff88;
    padding: 0 8px;
}

#network {
    color: #ffbf00;
    padding: 0 8px;
}

#pulseaudio {
    color: #ff00ff;
    padding: 0 8px;
}

#battery {
    color: #00d4ff;
    padding: 0 8px;
}

#tray {
    padding: 0 8px;
}
WAYBAR_CSS

success "Waybar configured with cyberpunk theme"

# ─── Picom Config ───────────────────────────────────────────────────────
mkdir -p ~/.config/picom
cat > ~/.config/picom/picom.conf << 'PICOM'
# ShadowOS Picom Configuration
# GPU-accelerated compositor effects

backend = "glx";
vsync = true;
glx-no-stencil = true;
glx-no-rebind-pixmap = true;
use-damage = true;
log-level = "warn";

# Shadow effects
shadow = true;
shadow-radius = 12;
shadow-offset-x = -5;
shadow-offset-y = -5;
shadow-opacity = 0.3;
shadow-color = "#000000";
shadow-exclude = [
    "name = 'Notification'",
    "class_g = 'Conky'",
    "class_g ?= 'Notify-osd'",
    "class_g ?= 'Cairo-clock'",
    "_GTK_FRAME_EXTENTS@:c"
];

# Blur effects
blur-method = "dual_kawase";
blur-strength = 6;
blur-background = true;
blur-background-frame = true;
blur-background-fixed = true;
blur-background-exclude = [
    "window_type = 'dock'",
    "window_type = 'desktop'",
    "class_g = 'slop'"
];

# Opacity
opacity-rule = [
    "95:class_g = 'Alacritty'",
    "95:class_g = 'kitty'",
    "90:class_g = 'Rofi'",
    "90:class_g = 'dunst'",
    "100:class_g = 'firefox'"
];

# Fading
fading = true;
fade-in-step = 0.03;
fade-out-step = 0.03;
fade-delta = 5;
fade-exclude = [0];

# Corner rounding
rounded-corners = 10;
rounded-corners-exclude = [
    "window_type = 'dock'",
    "window_type = 'desktop'",
    "override_redirect = 1"
];
PICOM

success "Picom configured with blur and shadow effects"

# ─── Hyprpaper (Wallpaper) ──────────────────────────────────────────────
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprpaper.conf << 'HYPRPAPER'
# ShadowOS Wallpaper Configuration
preload = /usr/share/backgrounds/shadowos/cyberpunk-city.png

screens = 1920x1080@60

wallpaper = eDP-1,/usr/share/backgrounds/shadowos/cyberpunk-city.png
wallpaper = HDMI-A-1,/usr/share/backgrounds/shadowos/cyberpunk-city.png
HYPRPAPER

success "Hyprpaper configured"

# ─── Notification Daemon ────────────────────────────────────────────────
mkdir -p ~/.config/dunst
cat > ~/.config/dunst/dunstrc << 'DUNST'
# ShadowOS Notification Configuration
[global]
    font = JetBrains Mono 10
    format = "<b>%s</b>\n%b"
    geometry = "300x50-20+20"
    separator_height = 2
    padding = 10
    horizontal_padding = 10
    frame_width = 2
    frame_color = "#00ffff"
    corner_radius = 8
    shrink = true

    # Cyberpunk colors
    background = "#0a0a0fcc"
    foreground = "#f0f0ff"
    highlight = "#00ffff"

    # Urgency colors
    [urgency_low]
        background = "#1a1a2e"
        foreground = "#666677"
        frame_color = "#333344"

    [urgency_normal]
        background = "#0a0a0fcc"
        foreground = "#f0f0ff"
        frame_color = "#00ffff"

    [urgency_critical]
        background = "#ff0055cc"
        foreground = "#ffffff"
        frame_color = "#ff00ff"
        timeout = 0
DUNST

success "Dunst notifications configured"

# ─── GTK Theme ──────────────────────────────────────────────────────────
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << 'GTK3'
[Settings]
gtk-theme-name=ShadowOS-Dark
gtk-icon-theme-name=ShadowOS
gtk-font-name=JetBrains Mono 11
gtk-cursor-theme-name=ShadowOS
gtk-cursor-size=24
gtk-application-prefer-dark-theme=1
gtk-enable-animations=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-decoration-layout=menu:minimize,maximize,close
GTK3

mkdir -p ~/.config/gtk-4.0
cp ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

success "GTK theme configured"

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Hyprland Wayland desktop configured${NC}"
echo -e "${GREEN}  ✓ Waybar status bar with cyberpunk theme${NC}"
echo -e "${GREEN}  ✓ Picom compositor with blur effects${NC}"
echo -e "${GREEN}  ✓ Dunst notifications styled${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"