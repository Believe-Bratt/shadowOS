# 🌑 ShadowOS

**The Cyberpunk Operating System for Security, Privacy & AI**

> *"The future doesn't forgive. Neither does ShadowOS."*

---

## Overview

ShadowOS is a fully customized, cyberpunk-inspired Linux operating system engineered for:

- 🔒 **Privacy & Security** — Tor, VPN, WireGuard, LUKS2 encryption, firewall, sandboxing
- 🤖 **AI Integration** — Local LLMs via Ollama, AI-assisted commands, voice support
- 💻 **Penetration Testing** — 200+ Kali Linux tools, custom scanners, AI-powered analysis
- 🎨 **Cyberpunk Aesthetics** — Neon themes, transparent terminals, animated dashboards
- ⚡ **High Performance** — GPU acceleration, optimized kernel, fast boot times
- 🛠 **Developer Friendly** — Full dev stack, Docker, language servers, Git workflows

---

## Quick Start

```bash
# 1. Clone the project
git clone <repo-url> && cd shadowos

# 2. Run the interactive setup wizard
sudo bash scripts/shadowos-setup.sh

# 3. Or run the full automated install
sudo bash scripts/post-install.sh

# 4. Reboot and enjoy!
sudo reboot
```

### After Installation

```bash
shadowos-status          # View system dashboard
ai-start                 # Start AI engine
ai "Hello, ShadowOS!"    # Chat with AI
neofetch                 # Display system info
```

---

## Features

### 🎨 Cyberpunk UI Theme Suite
ShadowOS includes a complete, system-wide cyberpunk-themed user interface that transforms every aspect of the desktop experience:

**GTK Theme (ShadowOS-Dark)**
- Full GTK3 & GTK4 theme with neon color palette
- Colors: `#00ffff` (cyan), `#ff00ff` (magenta), `#ffbf00` (amber), `#00ff88` (green), `#ff0055` (red)
- Dark backgrounds with subtle gradients and neon glow effects
- Custom widget styling for buttons, entries, notebooks, menus
- Consistent theming across all GTK applications

**Icon Theme (ShadowOS)**
- Complete SVG icon set with cyberpunk aesthetic
- Categories: Applications, Devices, Mime Types, Places, System
- Neon-styled icons with glowing accents
- 24px cursor size with custom neon cursor theme

**SDDM Login Theme**
- Full QML-based login screen with animated neon borders
- Real-time clock with cyberpunk typography
- User selection with hover effects
- Password field with glowing focus indicator
- Session selection with neon highlighting

**Rofi Application Launcher**
- Custom Rasi theme for rofi drun/run/ssh modes
- Neon color scheme matching system theme
- Animated selection with blur effects
- Custom font: JetBrains Mono

**Terminal Configurations**
- **Kitty**: GPU-accelerated with neon cursor, transparency, tab styling
- **Alacritty**: Hardware-accelerated with cyberpunk color palette
- Both configured with JetBrains Mono font and matching colors

**Neovim UI Enhancement**
- Complete `init.vim` with modern plugin ecosystem:
  - **lualine**: Neon status line with mode indicators
  - **bufferline**: Tab management with cyberpunk colors
  - **alpha-nvim**: Custom dashboard with logo
  - **neo-tree**: File explorer with icons
  - **telescope**: Fuzzy finder with preview
  - **which-key**: Keybinding hints
  - **treesitter**: Syntax highlighting
  - **LSP**: Language Server Protocol support
  - **nvim-cmp**: Auto-completion with AI integration
  - **git-signs**: Git diff indicators
  - **gitsigns-nvim**: Enhanced Git integration
  - **vim-fugitive**: Git wrapper
  - **vim-commentary**: Comment toggling
  - **surround**: Quote/paren management
  - **repeat**: Repeat plugin commands
  - **unimpaired**: Pairs of mappings
  - **targets**: Additional text objects
  - **vim-sleuth**: Automatic indent detection
  - **vim-illuminate**: Highlight word under cursor
  - **todo-comments**: Highlight TODOs
  - **indent-blankline**: Indent guides
  - **nvim-autopairs**: Auto-close brackets
  - **nvim-ts-context-commentstring**: Smart commenting

**Conky Desktop Widget**
- System monitor with neon-styled borders
- Displays: CPU, RAM, Disk, IP, Tor status, Firewall status
- Real-time updates with cyberpunk color scheme
- Configurable position and transparency

**Waybar Custom Modules**
- **ai-status.js**: Shows Ollama AI engine status (running/stopped, model info)
- **security-status.js**: Displays firewall, Tor, VPN, AppArmor status
- Both modules integrate with system services for real-time data
- Neon-styled output matching desktop theme

**Lock Screen (Swaylock)**
- Custom lock screen with blur background
- Neon-colored indicator rings
- Time/date display with cyberpunk font
- PAM authentication with visual feedback

**Picom Compositor**
- Advanced effects: dual_kawase blur, wobbly windows
- Window animations (fade, slide, zoom)
- Shadow effects with neon-tinted edges
- Corner rounding and transparency rules
- Optimized for Hyprland and X11 environments

**Installation & Management**
- Single command installer: `cyberpunk-theme/install-theme.sh`
- Installs all components to system/user directories
- Sets environment variables automatically
- Integrates with Makefile: `make ui-themes`
- Post-install integration via `post-install.sh`

### 🖥️ Cyberpunk Desktop Environment
- **Hyprland** (Wayland) — Tiling + floating, GPU compositing, blur effects
- **KDE Plasma** — Full desktop with ShadowOS dark theme
- **XFCE** — Lightweight alternative with cyberpunk styling
- **GNOME** — Traditional desktop with neon accents
- **SDDM** login screen with cyberpunk theme
- **Plymouth** animated boot sequence with matrix rain

### 💻 Advanced Terminal System
- **Zsh** with Oh My Zsh + Powerlevel10k cyberpunk prompt
- **Tmux** with neon status bar and AI integration
- **Kitty** / **Alacritty** GPU-accelerated terminals
- **Neovim** with cyberpunk colorscheme and AI copilot
- 30+ CLI productivity tools (fzf, ripgrep, bat, exa, etc.)

### 🔒 Security & Privacy
- **nftables** firewall with default-deny policy
- **LUKS2** full-disk encryption with TPM support
- **AppArmor** / **SELinux** enforcement
- **Tor** routing with transparent proxy
- **WireGuard** VPN integration
- **DNS-over-HTTPS** (Cloudflare/Quad9)
- **MAC address** randomization
- **Firejail** application sandboxing
- **AIDE** / **rkhunter** intrusion detection
- SSH hardened (port 2222, key-only auth)
- Network kill-switch

### 🤖 AI-Powered Workflows
- **Ollama** local LLM runtime
- **Llama 3.1**, **CodeLlama**, **Mistral**, **Phi-3** models
- `ai` command for natural language interaction
- `ai-scan` for AI-powered security scanning
- `ai-review` for code analysis
- Voice commands via **Whisper** + **Piper TTS**
- Neovim AI copilot integration
- JupyterLab for data science

### 🎯 Penetration Testing Suite
- 200+ tools from Kali Linux repositories
- Categories: Recon, Vuln Analysis, Web Testing, Password Attacks
- Wireless attacks, Reverse Engineering, Exploitation
- Forensics, Sniffing/Spoofing, Post-Exploitation
- Reporting tools (Dradis, MagicTree)
- Custom scripts: `quick-start.sh`, `web-scan.sh`

### 📊 Real-Time Dashboards
- **System Monitor** — CPU, RAM, GPU, temperature, processes
- **Network Monitor** — Traffic, connections, Tor/VPN status
- **Security Dashboard** — IDS alerts, file integrity, firewall activity
- **Developer Dashboard** — Git, Docker, VMs, AI assistant

### 🛠️ Development Environment
- Docker / Podman containerization
- Language servers for Python, JS/TS, Go, Rust, C/C++
- CMake presets, Git workflows, VM management
- Full build toolchain (GCC, Cargo, npm, pip)

---

## System Architecture

```
┌─────────────────────────────────────────────────┐
│              USER INTERFACE LAYER                │
│  ┌───────────────────────────────────────────┐  │
│  │      Custom Cyberpunk Desktop (Hyprland)   │  │
│  │      + KDE Plasma / XFCE / GNOME          │  │
│  └───────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────┐  │
│  │     Terminal Command Deck (Zsh/Tmux)      │  │
│  │     + Kitty / Alacritty GPU rendering     │  │
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│              SYSTEM SERVICES LAYER               │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │ AI Engine│ │ Security │ │ Network Privacy   │ │
│  │ Ollama   │ │ Firewall │ │ Tor/VPN/WG       │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐ │
│  │Dashboards│ │ Packages │ │ Desktop Services  │ │
│  │Rust/C++  │ │ APT/Custom│ │ SDDM/Display Mgr │ │
│  └──────────┘ └──────────┘ └──────────────────┘ │
├─────────────────────────────────────────────────┤
│              LINUX DISTRIBUTION BASE              │
│  ┌───────────────────────────────────────────┐  │
│  │          Kali Linux / Arch Base            │  │
│  │  APT │ systemd │ Btrfs │ Linux Kernel 6.x │ │
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│                   LINUX KERNEL                   │
│  ┌───────────────────────────────────────────┐  │
│  │     Hardened Kernel with Security Patches  │  │
│  │  - SELinux/AppArmor                        │  │
│  │  - ASLR + KASLR                            │  │
│  │  - Secure Boot support                     │  │
│  └───────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

---

## Project Structure

```
shadowos/
├── ARCHITECTURE.md              # Complete system architecture
├── config.sh                    # Global configuration
├── Makefile                     # Build orchestration
├── PROJECT_SUMMARY.md           # Implementation status
├── README.md                    # This file
├── base-system/
│   └── setup.sh                 # Base system optimization
├── build-system/
│   ├── build.sh                 # Main build script
│   └── iso/
│       └── build-iso.sh         # ISO image builder
├── cyberpunk-theme/
│   ├── cursors/README.md        # Cursor theme
│   ├── fonts/README.md          # Font configuration
│   ├── grub/theme.txt           # GRUB bootloader theme
│   ├── icons/README.md          # Icon theme
│   ├── plymouth/
│   │   └── shadowos-plymouth.sh # Boot animation
│   └── terminal/
│       └── cyberpunk.conf       # Terminal color scheme
├── desktop-environments/
│   ├── gnome/setup.sh           # GNOME setup
│   ├── hyprland/setup.sh        # Hyprland setup
│   ├── kde/setup.sh             # KDE Plasma setup
│   └── xfce/setup.sh            # XFCE setup
├── dev-environment/
│   └── setup.sh                 # Development tools
├── documentation/
│   ├── build-docs.sh            # Documentation builder
│   ├── installation-guide.md    # Installation guide
│   ├── privacy-guide.md         # Privacy guide
│   └── user-guide.md            # User guide
├── ai-integration/
│   └── setup-ai.sh              # AI/ML setup
├── pentest-suite/
│   ├── install.sh               # Tool installer
│   ├── kali-tools.list          # 200+ tools list
│   ├── quick-start.sh           # Quick pentest workflow
│   └── web-scan.sh              # Web vulnerability scanner
├── scripts/
│   ├── auto-update.sh           # Auto-update system
│   ├── backup.sh                # Backup & restore
│   ├── post-install.sh          # Main post-install
│   ├── shadowos-setup.sh        # Interactive wizard
│   └── uninstall.sh             # Clean uninstall
├── security-hardening/
│   └── apply-hardening.sh       # Security hardening
├── system-services/
│   ├── network-monitor.sh       # Network monitor
│   ├── shadowos-monitor.sh      # System dashboard
│   ├── shadowos-package-manager.sh # Package manager
│   └── shadowos-services.sh     # Systemd services
├── terminal-setup/
│   ├── nvim/
│   │   ├── cyberpunk.vim        # Neovim colorscheme
│   │   └── lua/ai_copilot.lua   # AI copilot module
│   ├── tmux/.tmux.conf          # Tmux configuration
│   └── zsh/.zshrc               # Zsh configuration
└── tests/
    └── run-tests.sh             # Test suite
```

---

## Build Commands

### Staged Build Approach

ShadowOS uses a **staged build approach** to ensure stability and faster builds:

```bash
# STAGE 1: Build minimal base ISO
make iso

# After installation, run post-install for additional tools:
sudo /opt/ShadowOS/post-install-tools.sh
```

**STAGE 1 - Minimal Base ISO** includes:
- KDE Plasma desktop
- Terminal (zsh, tmux, alacritty)
- Networking (NetworkManager, SSH)
- Security base (nftables, apparmor, firejail, lynis)
- Development tools (python3, build-essential)

**STAGE 2 - Post-Install Tools** (run after installation):
- AI/ML (ollama, jupyter, torch, transformers)
- Pentest (metasploit, burpsuite, nmap, etc.)
- Graphics (gimp, blender, inkscape)
- Office (libreoffice)
- Docker
- Terminal tools
- Multimedia

```bash
# Build VM images
make vm

# Build Docker container
make container

# Build everything
make all

# Run tests
make test

# Clean build artifacts
make clean
```

---

## Post-Installation

After installing the base system, run the post-install script to add additional tools:

```bash
# Run interactive post-install
sudo /opt/ShadowOS/post-install-tools.sh

# Or run specific categories
sudo /opt/ShadowOS/post-install-tools.sh --all
```

This staged approach ensures:
- Faster ISO build times
- Smaller ISO size
- Better dependency resolution
- More stable base system
- Ability to customize tool selection per installation

---

## Hardware Requirements

| | Minimum | Recommended | AI Workstation |
|---|---------|-------------|----------------|
| **CPU** | 2 cores | 4+ cores | 8+ cores |
| **RAM** | 4 GB | 16 GB | 64-128 GB |
| **Storage** | 20 GB SSD | 500 GB NVMe | 2 TB NVMe |
| **GPU** | Any | NVIDIA/AMD | Dual RTX 4090 |
| **Display** | 1024×768 | 1920×1080 | Multi-monitor |

---

## License

Proprietary — ShadowOS Team

---

## UI Upgrade Migration Guide

ShadowOS includes a comprehensive Cyberpunk UI Theme Suite that can be installed on existing systems or fresh installations.

### Installation

**Option 1: During Fresh Install**
The UI theme suite is automatically installed during the post-install process:
```bash
sudo bash scripts/post-install.sh
```

**Option 2: Manual Installation on Existing System**
```bash
# Install all UI components
make ui-themes

# Or run installer directly
bash cyberpunk-theme/install-theme.sh
```

**Option 3: User-Only Installation** (no root required)
```bash
# Install to ~/.config/shadowos/
cp -r cyberpunk-theme ~/.config/shadowos/
~/.config/shadowos/cyberpunk-theme/install-theme.sh --user
```

### What Gets Installed

| Component | Location | Description |
|------------|----------|-------------|
| GTK Theme | `/usr/share/themes/ShadowOS-Dark/` | GTK3/4 dark theme with neon colors |
| Icons | `/usr/share/icons/ShadowOS/` | Full SVG icon set |
| Cursors | `/usr/share/icons/ShadowOS/cursors/` | Neon cursor theme (24px) |
| SDDM Theme | `/usr/share/sddm/themes/ShadowOS/` | Login screen theme |
| Rofi Theme | `~/.config/rofi/` | Application launcher theme |
| Kitty Config | `~/.config/kitty/` | Terminal configuration |
| Alacritty Config | `~/.config/alacritty/` | Terminal configuration |
| Neovim Config | `~/.config/nvim/` | Enhanced editor with plugins |
| Conky Config | `~/.config/conky/` | Desktop widget |
| Waybar Modules | `~/.config/waybar/modules/` | AI & Security status modules |
| Lock Screen | `~/.config/swaylock/` | Swaylock configuration |
| Picom Config | `~/.config/picom/` | Compositor effects |
| Fonts | `~/.local/share/fonts/` | JetBrains Mono & Nerd Fonts |

### Desktop Environment Integration

The UI suite automatically integrates with your chosen desktop environment:

- **Hyprland**: Waybar modules, Picom config, GTK settings
- **GNOME**: GSettings applied, extensions configured
- **KDE Plasma**: Color schemes, Kvantum theme, KWin effects
- **XFCE**: xfconf settings, panel configuration, compositing

### Customization

All theme files are editable in `~/.config/shadowos/cyberpunk-theme/`. Key customization points:

- **Colors**: Edit `gtk/gtk-3.0/gtk.css` — change `@define-color` values
- **Icons**: Replace SVG files in `icons/svg/` directories
- **Waybar Modules**: Modify `waybar/modules/*.js` for custom output
- **Neovim**: Edit `terminal-setup/nvim/init.vim` for plugins/colors

### Troubleshooting

**Theme not applying?**
```bash
# Reinstall system-wide
sudo make ui-themes-system

# Or set manually
gsettings set org.gnome.desktop.interface gtk-theme 'ShadowOS-Dark'
```

**Waybar modules not showing?**
```bash
# Ensure modules are executable
chmod +x ~/.config/waybar/modules/*.js

# Restart Waybar
killall waybar && waybar &
```

**Neovim plugins missing?**
```bash
# Install plugin manager (lazy.nvim) or use vim-plug
# See terminal-setup/nvim/init.vim for plugin list
```

**Performance issues with Picom?**
```bash
# Disable blur effects
sed -i 's/blur-method = "dual_kawase"/blur-method = "none"/' ~/.config/picom/picom.conf
picom --config ~/.config/picom/picom.conf --replace
```

### Uninstall

To remove the cyberpunk theme suite:
```bash
# Remove user configs
rm -rf ~/.config/shadowos/cyberpunk-theme
rm -rf ~/.config/waybar/modules/ai-status.js ~/.config/waybar/modules/security-status.js
rm -rf ~/.config/gtk-3.0 ~/.config/gtk-4.0 ~/.config/rofi ~/.config/kitty ~/.config/alacritty
rm -rf ~/.config/nvim ~/.config/conky ~/.config/swaylock ~/.config/picom

# Reset to defaults (Ubuntu/GNOME example)
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.interface icon-theme
gsettings reset org.gnome.desktop.interface cursor-theme
```

---

*"Enter the shadows. The future awaits."* 🌑
