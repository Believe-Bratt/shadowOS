# ShadowOS BeltrixOS Style Migration — Complete

## Summary

Successfully transformed ShadowOS UI to match the **BeltrixOS** cyberpunk aesthetic from https://beltrix-os-forge.lovable.app.

**Date:** 2026-05-14
**Base Theme:** ShadowOS Cyberpunk
**Target Style:** BeltrixOS (Future. Controlled.)

---

## 🎨 Color Palette Migration

### Old → New Color Mapping

| Component | Old Color | New Color | Change |
|-----------|-----------|-----------|--------|
| Primary Accent | `#00ffff` (cyan) | `#00ffff` (cyan) | Kept |
| Secondary Accent | `#ff00ff` (magenta) | `#c54dff` (purple) | **Changed** |
| Tertiary | `#ffbf00` (amber) | `#ffbf00` (amber) | Kept |
| Success | `#00ff88` (green) | `#00ff88` (green) | Kept |
| Error | `#ff0055` (red) | `#ff0055` (red) | Kept |
| Background | `#0a0a0f` | `#0a0a0f` | Kept |
| Panel | `#1a1a2e` (solid) | `rgba(26,26,46,0.85)` (glass) | **Glassmorphism** |

### New BeltrixOS Colors Added
- `#c54dff` — Neon Purple (AI features, secondary accents)
- `#d47dff` — Bright Purple (terminal bright magenta)
- Glassmorphic backgrounds with alpha transparency

---

## 📁 Files Modified/Created

### Modified Files (8)
1. **GTK Theme** — `cyberpunk-theme/gtk/gtk-3.0/gtk.css`
   - Updated all `@define-color` declarations
   - Added glassmorphism variables
   - Enhanced glow effects on windows and buttons

2. **Rofi Launcher** — `cyberpunk-theme/rofi/shadowos.rasi`
   - Changed `accent2` from `#ff00ff` → `#c54dff`
   - Increased border radius to `10px`
   - Updated selected item styling

3. **Alacritty Terminal** — `cyberpunk-theme/alacritty/alacritty.yml`
   - `color5` (magenta): `#ff00ff` → `#c54dff`
   - `color13` (bright magenta): `#ff55ff` → `#d47dff`
   - Vi mode cursor now purple

4. **Kitty Terminal** — `cyberpunk-theme/kitty/kitty.conf`
   - Same color updates as Alacritty

5. **Conky Widget** — `cyberpunk-theme/conky/shadowos.conkyrc`
   - Reformatted to BeltrixOS "System Overview" layout
   - Color-coded sections with new palette
   - Improved border styling

6. **Picom Compositor** — `cyberpunk-theme/picom/picom.conf`
   - Blur strength: `8` → `12`
   - Shadow radius: `15` → `20`
   - Shadow opacity: `0.4` → `0.5`

7. **SDDM Login** — `cyberpunk-theme/sddm/theme/Main.qml`
   - Added `neonPurple` property
   - Replaced all `neonMagenta` references with `neonPurple`
   - Updated hex colors from `#ff00ff` → `#c54dff`

8. **Install Script** — `cyberpunk-theme/install-theme.sh`
   - Added wallpaper installation step
   - Updated Waybar module installation to include Python files
   - Enhanced summary with wallpaper info

### New Files Created (10)
1. **Waybar Config** — `cyberpunk-theme/waybar/config`
   - Full Waybar configuration with BeltrixOS module layout
   - Includes AI, Security, System, Media modules

2. **Waybar Style** — `cyberpunk-theme/waybar/style.css`
   - Glassmorphic module backgrounds
   - Color-coded module indicators
   - Neon borders and hover effects

3. **AI Status Module** — `cyberpunk-theme/waybar/modules/ai-status.py`
   - Python script for Ollama AI status
   - Outputs: `"ONLINE: {model}|#c54dff|tooltip"`
   - Purple color coding

4. **Security Status Module** — `cyberpunk-theme/waybar/modules/security-status.py`
   - Python script for security services status
   - Checks: firewall, Tor, VPN, AppArmor
   - Color-coded: green (all good), amber (partial), red (critical)

5. **Wallpaper Directory** — `cyberpunk-theme/wallpapers/`
   - Contains `wallpaper1.png` (pre-included cyber city wallpaper)
   - Setup scripts for Linux and Windows

6. **Wallpaper Setup (Linux)** — `cyberpunk-theme/wallpapers/setup-wallpaper.sh`
   - Downloads cyberpunk city wallpaper from Pexels
   - Provides manual setup instructions

7. **Wallpaper Setup (Windows)** — `cyberpunk-theme/wallpapers/setup-wallpaper.bat`
   - PowerShell-based downloader for Windows

8. **Wallpaper README** — `cyberpunk-theme/wallpapers/README.md`
   - Setup instructions for all desktop environments
   - Wallpaper requirements and sources

9. **Documentation** — `cyberpunk-theme/BELTRIXOS-STYLE.md`
   - Complete design guide
   - Color palette reference
   - Component breakdown
   - Installation & troubleshooting

10. **Migration Summary** — `cyberpunk-theme/BELTRIXOS-MIGRATION.md` (this file)

---

## 🔧 Component-by-Component Changes

### GTK Applications
- **Windows**: Neon cyan border, glassmorphic background, radial gradient glow
- **Headerbars**: Cyan bottom border, gradient background
- **Buttons**: Neon border, hover glow, active state color shift
- **Entries**: Focus ring with neon cyan glow
- **Progress Bars**: Cyan→magenta gradient fill with glow
- **Sliders**: Cyan highlight, neon thumb
- **Menus**: Glassmorphic with neon borders
- **Dialogs**: Enhanced neon glow on borders

### Waybar Top Panel
- **Container**: Cyan bottom border, panel glow
- **Workspaces**: Glass buttons, active state with cyan glow
- **Clock**: Purple text, purple border
- **System Monitors**:
  - CPU: Cyan
  - RAM: Magenta
  - Disk: Amber
  - Battery: Green (warning: amber, critical: red)
  - Network: Cyan
  - Audio: Magenta (muted: red)
- **Custom Modules**:
  - AI Status: Purple (shows Ollama model)
  - Security Status: Green (firewall/Tor/VPN/AppArmor)
  - Power: Red (wlogout trigger)

### SDDM Login
- **Background**: Cyber city wallpaper (`wallpaper1.png`)
- **Frame**: Cyan neon border with glow
- **Corner Decorations**: Cyan (top-left) and Magenta→Purple (top-right)
- **Title**: "SHADOWOS" in large cyan glow text
- **ComboBoxes**: Cyan border, glass background
- **Login Button**: Full cyan fill with glow
- **Power Buttons**: Amber (reboot), Red (shutdown)
- **Clock**: Cyan time, purple date

### Conky Desktop Widget
- **Panel Style**: Cyan-bordered boxes with glass backgrounds
- **CPU Section**: Cyan color, percentage display
- **RAM Section**: Magenta color
- **Disk Section**: Amber color
- **Network**: Cyan with speed indicators
- **AI Activity**: Purple with process/model counts
- **Security**: Green with service status icons
- **Uptime/Time**: Green uptime, magenta time, amber date
- **Top Processes**: Cyan-bordered list

### Rofi Launcher
- **Window**: Dark glass background, thick cyan border, glow
- **Input Bar**: Glass background, cyan border
- **Prompt**: Cyan text
- **Entry**: Light text, purple cursor
- **List Items**: Transparent, hover glass effect
- **Selected**: Purple background, cyan border, glow
- **Urgent**: Amber background
- **Icons**: 24px with cache

### Terminals
- **Cursor**: Cyan beam (vi mode: purple)
- **Selection**: Cyan on dark
- **Tabs**: Active cyan, inactive dark
- **Borders**: Cyan (active), dim (inactive)
- **Bell**: Amber border
- **Colors**: Full 16-color palette with purple magentas

### Compositor (Picom)
- **Blur**: Dual Kawase method, strength 12 (stronger glassmorphism)
- **Shadows**: Radius 20, opacity 0.5 (pronounced neon glow)
- **Rounded Corners**: 10px radius
- **Animations**: Enabled (fade, wobbly windows)
- **Opacity Rules**: Terminals 95%, Rofi 90%, etc.

---

## 🖼️ Wallpaper Integration

### Default Wallpaper
- **File:** `cyberpunk-theme/wallpapers/wallpaper1.png`
- **Size:** ~2.2MB (high-resolution cyber city)
- **Installation:** Copied to `/usr/share/backgrounds/shadowos/` (system) and `~/.config/shadowos/cyberpunk-theme/wallpapers/` (user)
- **SDDM:** Configured to use system wallpaper
- **Desktop:** Instructions provided for all DEs

### Wallpaper Requirements
- Resolution: 1920x1080 minimum (4K recommended)
- Aspect: 16:9
- Style: Dark cyberpunk city with neon lights
- Colors: Complement cyan/purple palette

---

## 📦 Installation

```bash
# Run the complete installer
cd cyberpunk-theme
./install-theme.sh
```

The installer handles:
1. GTK theme (system + user)
2. Icons & cursors
3. SDDM login theme (with wallpaper)
4. Rofi launcher theme
5. Kitty & Alacritty configs
6. Neovim UI
7. Conky widget
8. Waybar config + Python modules
9. Swaylock config
10. Picom enhanced config
11. Environment variables
12. Qt5/Qt6 theme
13. Wallpaper setup (uses `wallpaper1.png`)

### Post-Installation

**Activate GTK theme:**
```bash
gsettings set org.gnome.desktop.interface gtk-theme "ShadowOS-Dark"
gsettings set org.gnome.desktop.interface icon-theme "ShadowOS"
```

**Start Waybar:**
```bash
killall waybar && waybar &
```

**Start Conky:**
```bash
conky -c ~/.config/conky/shadowos.conkyrc
```

**Set SDDM theme (optional):**
```bash
sudo sddm --example-config | sudo tee /etc/sddm.conf
sudo sed -i 's/^Theme=.*/Theme=ShadowOS/' /etc/sddm.conf
```

---

## 🎯 Design Principles (BeltrixOS)

1. **Neon Glow** — Every interactive element has subtle box-shadow glow
2. **Glassmorphism** — Semi-transparent panels with blur (Picom)
3. **Color Coding** — Each system component has dedicated neon color
4. **Consistent Borders** — 1-2px neon borders throughout
5. **Smooth Animations** — Fading, wobbly windows, transitions
6. **Monospace Typography** — JetBrains Mono for terminal/hacker aesthetic

---

## 🧪 Testing Checklist

- [ ] GTK applications display correct colors and borders
- [ ] Waybar shows with glassmorphic modules and correct colors
- [ ] AI status module shows Ollama status (purple)
- [ ] Security status module shows firewall/Tor/VPN status (green)
- [ ] SDDM login screen displays wallpaper and neon styling
- [ ] Conky widget shows system overview with color-coded sections
- [ ] Rofi launcher shows purple selection with cyan border
- [ ] Terminals (Kitty/Alacritty) use updated color palette
- [ ] Picom blur and shadow effects are visible
- [ ] Wallpaper displays on desktop (set via DE settings)
- [ ] All neon colors glow under black background

---

## 🐛 Troubleshooting

### GTK theme not applying
```bash
ls ~/.themes/ /usr/share/themes/
gsettings set org.gnome.desktop.interface gtk-theme "ShadowOS-Dark"
```

### Waybar modules not working
```bash
chmod +x ~/.config/waybar/modules/*.py
# Ensure Python 3 and required system services (ollama, nftables, tor, wg, apparmor)
```

### Picom blur not working
```bash
glxinfo | grep "GLX"  # Check GLX support
export __GLX_VENDOR_LIBRARY_NAME=nvidia  # For NVIDIA GPUs
```

### Wallpaper not showing in SDDM
```bash
# Verify wallpaper exists
ls -la /usr/share/backgrounds/shadowos/wallpaper1.png

# Update SDDM config if needed
sudo nano /etc/sddm.conf
# Theme=ShadowOS
```

---

## 📚 References

- **BeltrixOS:** https://beltrix-os-forge.lovable.app
- **ShadowOS:** Original cyberpunk theme framework
- **Color Palette:** Based on OKLCH color space conversions
- **Wallpaper Source:** Pexels (cyberpunk city photography)

---

*Migration completed successfully. ShadowOS now embodies the BeltrixOS vision: **Future. Controlled.** 🌑*
