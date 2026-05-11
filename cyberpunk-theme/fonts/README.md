# ShadowOS Font Configuration

## Recommended Fonts

### Primary Font: JetBrains Mono
- Monospaced, designed for developers
- Excellent glyph distinction (0 vs O, l vs 1, etc.)
- Ligatures support for programming
- Install: `sudo apt install fonts-jetbrains-mono`

### Secondary Fonts
- **Fira Code** — Alternative programming font with ligatures
- **Noto Sans** — UI text and internationalization
- **DejaVu Sans Mono** — Fallback monospace font

## Installation
```bash
# Install all recommended fonts
sudo apt install fonts-jetbrains-mono fonts-firacode fonts-noto fonts-dejavu fonts-liberation

# Or install manually
mkdir -p ~/.local/share/fonts
cp *.ttf ~/.local/share/fonts/
fc-cache -fv
```

## Configuration
Set in your desktop environment settings or via:
```bash
gsettings set org.gnome.desktop.interface font-name 'JetBrains Mono 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 11'
```

## Nerd Fonts (Optional)
For icon support in terminal prompts:
```bash
# Download JetBrains Mono Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts/
fc-cache -fv
```

## ShadowOS Font Palette
- Terminal: JetBrains Mono 13px
- Editor: JetBrains Mono 12-14px
- Desktop: JetBrains Mono 11px
- Status bar: JetBrains Mono 11-12px
- Login screen: JetBrains Mono 14-16px