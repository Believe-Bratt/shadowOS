# ShadowOS Cursor Theme

## Overview
Custom cursor theme with cyberpunk neon aesthetics.

## Installation
```bash
# Copy to system cursors directory
sudo cp -r . /usr/share/icons/ShadowOS/cursors
sudo update-alternatives --install /usr/share/icons/default/index.theme \
    x-cursor-theme /usr/share/icons/ShadowOS/cursors/index.theme 90
sudo update-alternatives --set x-cursor-theme /usr/share/icons/ShadowOS/cursors/index.theme

# Or for user only
cp -r . ~/.local/share/icons/ShadowOS/cursors
gsettings set org.gnome.desktop.interface cursor-theme 'ShadowOS'
```

## Cursor Types
- `default` — Standard arrow (cyan glow)
- `pointer` — Hand cursor (magenta glow)
- `text` — I-beam text cursor (white)
- `wait` — Spinning loading cursor (amber animation)
- `crosshair` — Crosshair for precision (cyan)
- `hand1/hand2` — Alternative hand cursors
- `xterm` — Text input cursor
- `watch` — Busy/wait cursor
- `left_ptr` — Default left pointer
- `top_left_arrow` — Corner resize
- `sizing` — Resize cursors

## Design
- All cursors have neon glow outlines
- Cyan (#00FFFF) primary with magenta (#FF00FF) accent
- 24px and 32px sizes
- X11 cursor format (.cur and .png)
- Animated wait/watch cursors (10 frames)