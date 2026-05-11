# ShadowOS User Guide

> **Welcome to ShadowOS — The Cyberpunk Operating System**

## Table of Contents

1. [Getting Started](#getting-started)
2. [Desktop Environment](#desktop-environment)
3. [Terminal & Shell](#terminal--shell)
4. [AI Assistant](#ai-assistant)
5. [Security & Privacy](#security--privacy)
6. [Development](#development)
7. [Pentesting](#pentesting)
8. [System Monitoring](#system-monitoring)
9. [Customization](#customization)
10. [Troubleshooting](#troubleshooting)

---

## 1. Getting Started

### First Boot
After installing ShadowOS, you'll see the SDDM login screen with the ShadowOS cyberpunk theme.

1. Select your user
2. Enter your password
3. You'll be greeted by the Hyprland/KDE Plasma desktop

### Initial Setup
Open a terminal (Ctrl+Alt+T) and run:
```bash
shadowos-status
```

This displays your system status including CPU, RAM, disk, network, and security status.

### Update Your System
```bash
sudo shadowos-update
# or
sudo apt update && sudo apt full-upgrade -y
```

---

## 2. Desktop Environment

### Hyprland (Default)
ShadowOS uses **Hyprland** as the default Wayland compositor with:

- **Tiling window management** with floating support
- **Blur effects** on all windows
- **Animated transitions** between workspaces
- **10 workspaces** arranged in a 2×5 grid
- **Status bar** via Waybar with system monitoring

#### Key Bindings
| Key | Action |
|-----|--------|
| `Super + 1-0` | Switch workspace |
| `Super + Shift + 1-0` | Move window to workspace |
| `Super + Q` | Kill window |
| `Super + F` | Fullscreen |
| `Super + Tab` | Cycle windows |
| `Super + Enter` | Open terminal |
| `Super + E` | Toggle file manager |
| `Super + C` | Center window |
| `Mouse Scroll` | Switch workspace |

### KDE Plasma (Alternative)
To switch to KDE Plasma:
```bash
sudo systemctl disable sddm
sudo systemctl enable sddm
# Select "Plasma" at login screen
```

---

## 3. Terminal & Shell

### Terminal Emulators
ShadowOS includes two GPU-accelerated terminals:

- **Kitty** — Default terminal with custom cyberpunk theme
- **Alacritty** — Alternative terminal with matching theme

### Zsh Shell
The default shell is **Zsh** with:

- **Powerlevel10k** prompt with cyberpunk colors
- **Oh My Zsh** with custom plugins
- **Auto-suggestions** (gray text as you type)
- **Syntax highlighting** (commands colored in real-time)
- **Fuzzy finder** integration

#### Custom Prompt
Your prompt displays:
- Current directory with git branch
- Execution time for slow commands
- Virtual environment indicator
- RAM and CPU usage
- Root indicator (🔴 when root)

#### Essential Aliases
```bash
ls          # Enhanced with icons and colors
ll          # Detailed listing
cat         # With syntax highlighting (bat)
grep        # ripgrep with colors
find        # fd with colors
top         # btm (bottom) interactive monitor
vim         # Opens Neovim
ai          # AI assistant
sys         # Opens btop system monitor
```

### Tmux
Pre-configured with:
- Cyberpunk status bar (cyan/magenta)
- Session management
- Pane splitting and navigation
- AI integration (Prefix + A)
- Vi-style keybindings

---

## 4. AI Assistant

### Starting the AI
```bash
ai-start    # Start Ollama service
```

### Using the AI
```bash
# General questions
ai "What is the best way to learn Python?"

# Code generation
ai codellama:7b "Write a Python function to sort a list"

# Security analysis
ai "How would you test for SQL injection?"

# Code review
ai-review /path/to/script.py

# Security scan
ai-scan target.com
```

### Available Models
| Model | Size | Use Case |
|-------|------|----------|
| llama3.1:8b | ~4.7GB | General purpose |
| codellama:7b | ~3.8GB | Code generation |
| mistral:7b | ~4.1GB | General purpose |
| phi3:mini | ~2.3GB | Lightweight tasks |
| neural-chat:7b | ~4.1GB | Conversations |

### Neovim AI Integration
In Neovim, the AI copilot module provides:
- Code completion with `:AIComplete`
- Code explanation with visual selection + `:AIExplain`

---

## 5. Security & Privacy

### Firewall
ShadowOS uses **nftables** with a default-deny policy.

```bash
# Check status
sudo nft list ruleset

# Temporarily disable (for testing)
sudo nft flush ruleset

# Re-enable
sudo systemctl restart nftables
```

### Tor Network
```bash
# Start Tor
tor-on

# Use Tor with any application
torsocks curl https://check.torproject.org

# Configure browser for Tor
export http_proxy="socks5://127.0.0.1:9050"
```

### VPN (WireGuard)
```bash
# Edit configuration
sudo nano /etc/wireguard/wg0.conf

# Connect
sudo wg-quick up wg0

# Disconnect
sudo wg-quick down wg0
```

### Privacy Dashboard
```bash
tor-privacy.sh status    # Check all privacy services
tor-privacy.sh all       # Enable full privacy stack
```

### Encryption
During installation, enable LUKS2 full-disk encryption. To verify:
```bash
lsblk -o NAME,FSTYPE | grep crypto
```

### SSH Security
SSH is hardened and runs on port 2222:
```bash
ssh -p 2222 user@your-shadowos
```

---

## 6. Development

### Workspace
Your development workspace is at `/opt/workspace/`.

### Language Support
- **Python** — Pyright LSP, black, isort, mypy, pytest
- **JavaScript/TypeScript** — TypeScript LSP, Prettier, ESLint
- **Go** — gopls LSP, gofumpt, staticcheck
- **Rust** — rust-analyzer, rustfmt, clippy
- **C/C++** — clangd LSP
- **Ruby, PHP, Lua** — Basic support

### Docker
```bash
# Docker is pre-configured
docker ps
docker-compose up -d

# Your user is in the docker group
```

### Git
Pre-configured with modern defaults:
```bash
git config --global core.editor nvim
git config --global pull.rebase true
```

### Virtual Machines
```bash
# Launch VM Manager
virt-manager

# Or use command line
virsh list --all
```

---

## 7. Pentesting

### Quick Start
```bash
# Run the quick-start script
~/pentest/quick-start.sh
```

### Essential Tools
| Category | Tools |
|----------|-------|
| Recon | nmap, masscan, theHarvester, amass |
| Web | sqlmap, nikto, Burp Suite, OWASP ZAP |
| Exploit | Metasploit, BeEF, SET |
| Password | John, Hashcat, Hydra |
| Wireless | Aircrack-ng, Wifite, Kismet |
| Forensics | Autopsy, Volatility, Binwalk |
| Reverse Eng | Ghidra, Radare2 |

### Aliases
```bash
scan target.com          # Quick nmap scan
scan-full target.com     # Full nmap scan
web-scan target.com      # Nikto web scan
vuln-check target.com    # Nuclei vulnerability scan
```

---

## 8. System Monitoring

### Live Dashboard
```bash
shadowos-monitor live    # Full-screen dashboard
shadowos-monitor status  # Quick status
shadowos-monitor snapshot # One-time output
```

### Network Monitor
```bash
sudo shadowos-network-monitor [interface]
```

### Resource Monitoring
```bash
btop         # Interactive system monitor
htop         # Process viewer
glances      # Overview dashboard
```

---

## 9. Customization

### Themes
ShadowOS supports multiple color themes:
- **Neon Cyan** (default) — Cyan + Black
- **Neon Magenta** — Purple/Magenta + Black
- **Neon Amber** — Red/Amber + Black
- **Neon Blue** — Blue + Silver

To change themes, modify `~/.config/gtk-3.0/settings.ini` and terminal configs.

### Wallpaper
Change wallpaper with Hyprpaper:
```bash
# Edit config
nano ~/.config/hypr/hyprpaper.conf
# Update wallpaper path and reload
hyprctl hyprpaper reload
```

### Dotfiles
All configurations are in `~/.config/`:
- `~/.config/hypr/` — Window manager
- `~/.config/kitty/` — Terminal
- `~/.config/nvim/` — Text editor
- `~/.config/tmux/` — Terminal multiplexer
- `~/.config/waybar/` — Status bar
- `~/.config/dunst/` — Notifications
- `~/.config/picom/` — Compositor

---

## 10. Troubleshooting

| Problem | Solution |
|---------|----------|
| Black screen on boot | Add `nomodeset` to GRUB |
| No network | `sudo systemctl restart NetworkManager` |
| Zsh not default | `chsh -s /usr/bin/zsh $USER` |
| Ollama not running | `ollama serve` or `sudo systemctl start ollama` |
| Tor not working | `sudo systemctl start tor` |
| GUI not loading | `sudo systemctl start sddm` |
| Low disk space | `sudo apt autoremove && sudo journalctl --vacuum-size=100M` |
| SSH connection refused | `sudo systemctl start ssh` |
| Docker permission denied | `sudo usermod -aG docker $USER` (log out/in) |

### Logs
```bash
# System logs
journalctl -xe

# ShadowOS specific
cat /var/log/shadowos-install.log
cat /var/log/shadowos-monitor.log
cat /var/log/shadowos-updates.log
```

### Reset Configuration
```bash
# Run post-install again
sudo bash /opt/ShadowOS/scripts/post-install.sh

# Or fully uninstall
sudo bash /opt/ShadowOS/scripts/uninstall.sh
```

---

## Keyboard Shortcuts Reference

### Global
| Shortcut | Action |
|----------|--------|
| `Super + 1-0` | Switch workspace |
| `Super + Tab` | Next window |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + E` | File manager |
| `Super + T` | Terminal |
| `Print` | Screenshot |

### Terminal
| Shortcut | Action |
|----------|--------|
| `Ctrl+A` | Prefix key |
| `Ctrl+A + \|` | Split vertical |
| `Ctrl+A + -` | Split horizontal |
| `Alt+Arrow` | Move between panes |
| `Ctrl+A + R` | Reload config |
| `Prefix + A` | AI query |

### Tmux
| Shortcut | Action |
|----------|--------|
| `Ctrl+A` | Prefix |
| `Ctrl+A + c` | New window |
| `Ctrl+A + n/p` | Next/Previous window |
| `Ctrl+A + %` | Split vertical |
| `Ctrl+A + "` | Split horizontal |