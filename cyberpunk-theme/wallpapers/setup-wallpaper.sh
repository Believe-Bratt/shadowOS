#!/bin/bash
# ============================================================================
# ShadowOS Wallpaper Setup — BeltrixOS Inspired Cyber City
# ============================================================================
# This script downloads a cyberpunk city wallpaper matching the BeltrixOS aesthetic
# ============================================================================

set -e

WALLPAPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER_FILE="$WALLPAPER_DIR/cyber-city.jpg"

echo "=== ShadowOS Wallpaper Setup ==="
echo ""

# Check if wallpaper already exists
if [ -f "$WALLPAPER_FILE" ]; then
    echo "Wallpaper already exists at: $WALLPAPER_FILE"
    read -p "Do you want to re-download? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting..."
        exit 0
    fi
fi

# Try to download using curl or wget
echo "Downloading cyberpunk city wallpaper..."
if command -v curl &> /dev/null; then
    # Download from a reliable source (Pexels free image)
    # This is a cyberpunk city image that matches BeltrixOS aesthetic
    curl -L -o "$WALLPAPER_FILE" "https://images.pexels.com/photos/12832188/pexels-photo-12832188.jpeg?auto=compress&cs=tinysrgb&w=1920" 2>/dev/null || \
    curl -L -o "$WALLPAPER_FILE" "https://images.pexels.com/photos/1562/italian-architecture-ancient-old-rome.jpeg?auto=compress&cs=tinysrgb&w=1920" 2>/dev/null || \
    echo "Warning: Download failed. Please manually add a wallpaper to: $WALLPAPER_FILE"
elif command -v wget &> /dev/null; then
    wget -O "$WALLPAPER_FILE" "https://images.pexels.com/photos/12832188/pexels-photo-12832188.jpeg?auto=compress&cs=tinysrgb&w=1920" 2>/dev/null || \
    wget -O "$WALLPAPER_FILE" "https://images.pexels.com/photos/1562/italian-architecture-ancient-old-rome.jpeg?auto=compress&cs=tinysrgb&w=1920" 2>/dev/null || \
    echo "Warning: Download failed. Please manually add a wallpaper to: $WALLPAPER_FILE"
else
    echo "Error: Neither curl nor wget found."
    echo "Please manually download a cyberpunk city wallpaper and place it at:"
    echo "  $WALLPAPER_FILE"
    exit 1
fi

# Check if download succeeded
if [ -f "$WALLPAPER_FILE" ] && [ -s "$WALLPAPER_FILE" ]; then
    echo "✓ Wallpaper downloaded successfully!"
    echo "  Location: $WALLPAPER_FILE"
    echo ""
    echo "To set the wallpaper:"
    echo "  - For Hyprland: feh --bg-fill $WALLPAPER_FILE (add to ~/.config/hypr/hyprland.conf)"
    echo "  - For Sway:   swaymsg output * bg $WALLPAPER_FILE fill"
    echo "  - For GNOME:  gsettings set org.gnome.desktop.background picture-uri file://$WALLPAPER_FILE"
    echo "  - For KDE:    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'string: var wallpaper = \"$WALLPAPER_FILE\"; var allDesktops = desktops(); for (i=0;i<allDesktops.length;i++) { allDesktops[i].wallpaperPlugin = \"org.kde.image\"; allDesktops[i].currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\"); allDesktops[i].writeConfig(\"Image\", wallpaper) }'"
else
    echo "✗ Download failed."
    echo "Please manually download a cyberpunk city wallpaper and place it at:"
    echo "  $WALLPAPER_FILE"
    exit 1
fi
