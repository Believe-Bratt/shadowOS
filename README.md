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

```bash
# Build ISO image
make iso

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

*"Enter the shadows. The future awaits."* 🌑
