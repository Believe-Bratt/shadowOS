# ShadowOS Wallpapers — BeltrixOS Inspired

This directory contains the ShadowOS desktop wallpapers.

## Cyber City Wallpaper

The BeltrixOS-inspired theme features a cyberpunk cityscape background with neon glow effects.

### Default Wallpaper

**`wallpaper1.png`** — Pre-included cyberpunk city wallpaper that matches the BeltrixOS color palette perfectly. This is the recommended default.

### Setup

#### Automatic (Linux)
Run the setup script to verify or download an alternative:
```bash
./setup-wallpaper.sh
```

#### Manual (Using Default)
The wallpaper `wallpaper1.png` is already included. Simply set it as your background:

**Hyprland:**
Add to `~/.config/hypr/hyprland.conf`:
```
exec = feh --bg-fill ~/.config/shadowos/cyberpunk-theme/wallpapers/wallpaper1.png
```

**Sway:**
Add to `~/.config/sway/config`:
```
output * bg ~/.config/shadowos/cyberpunk-theme/wallpapers/wallpaper1.png fill
```

**GNOME:**
```bash
gsettings set org.gnome.desktop.background picture-uri file:///home/$USER/.config/shadowos/cyberpunk-theme/wallpapers/wallpaper1.png
```

**KDE Plasma:**
System Settings → Workspace → Desktop → Wallpaper → Add Image → Select `wallpaper1.png`

**XFCE:**
Right-click desktop → Desktop → Background → Add image → Select `wallpaper1.png`

### Recommended Wallpaper Sources

- **Pexels**: Search "cyberpunk city" or "neon city"
- **Unsplash**: Search "cyberpunk" or "neon"
- **Wallhaven**: Tag: cyberpunk, neon, city

### Setting the Wallpaper

#### Hyprland
Add to `~/.config/hypr/hyprland.conf`:
```
exec = feh --bg-fill ~/.config/shadowos/cyberpunk-theme/wallpapers/cyber-city.jpg
```

#### Sway
Add to `~/.config/sway/config`:
```
output * bg ~/.config/shadowos/cyberpunk-theme/wallpapers/cyber-city.jpg fill
```

#### GNOME
```bash
gsettings set org.gnome.desktop.background picture-uri file:///home/$USER/.config/shadowos/cyberpunk-theme/wallpapers/cyber-city.jpg
```

#### KDE Plasma
System Settings → Workspace → Desktop → Wallpaper → Add Image

#### XFCE
Right-click desktop → Desktop → Background → Add image

### Wallpaper Requirements

- **Resolution**: 1920x1080 minimum (4K recommended)
- **Aspect Ratio**: 16:9
- **Style**: Dark cyberpunk city with neon lights
- **Colors**: Should complement the ShadowOS neon palette (cyan #00ffff, purple #c54dff, magenta #ff00ff)
