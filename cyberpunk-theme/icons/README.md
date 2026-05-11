# ShadowOS Icon Theme

## Overview
Custom neon-styled icon theme for ShadowOS with cyberpunk aesthetics.

## Color Palette
- Primary: `#00FFFF` (Neon Cyan)
- Secondary: `#FF00FF` (Neon Magenta)
- Accent: `#FFBF00` (Neon Amber)
- Background: `#0A0A0F` (Deep Black)

## Structure
```
icons/ShadowOS/
├── index.theme          # Theme metadata
├── cursors/             # Custom cursor set
│   ├── default          # Arrow cursor
│   ├── pointer          # Hand cursor
│   ├── text             # I-beam cursor
│   ├── wait             # Loading cursor
│   ├── crosshair        # Crosshair cursor
│   └── ...
├── 16x16/               # Small icons
├── 24x24/               # Medium icons
├── 32x32/               # Standard icons
├── 48x48/               # Large icons
├── 64x64/               # XLarge icons
├── 128x128/             # XXLarge icons
├── 256x256/             # Huge icons
├── scalable/            # Vector icons
│   ├── actions/
│   ├── apps/
│   ├── categories/
│   ├── devices/
│   ├── emblems/
│   ├── mimetypes/
│   ├── places/
│   └── status/
└── animations/          # Animated cursors
```

## Installation
```bash
# Copy to system icons directory
sudo cp -r ShadowOS /usr/share/icons/
sudo update-alternatives --install /usr/share/icons/default/index.theme \
    x-cursor-theme /usr/share/icons/ShadowOS/index.theme 90

# Or install for user only
cp -r ShadowOS ~/.local/share/icons/
gsettings set org.gnome.desktop.interface cursor-theme 'ShadowOS'
gsettings set org.gnome.desktop.interface cursor-size 24
```

## Design Guidelines
- All icons use neon glow effects
- Dark transparent backgrounds
- Consistent 1px stroke width
- Glowing edges matching the cyberpunk palette
- Animated cursors for wait/busy states