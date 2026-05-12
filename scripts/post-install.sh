#!/usr/bin/env bash
# ============================================================================
# ShadowOS Post-Install Setup Script
# ============================================================================
set -e
set -u

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; MAGENTA='\033[0;35m'
BOLD='\033[1m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/shadowos-install.log"

if [ "$EUID" -ne 0 ]; then echo -e "${RED}Run as root${NC}"; exit 1; fi

step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
info() { echo -e "  ${BLUE}ℹ${NC} $1"; }

# Detect package manager
if command -v apt &>/dev/null; then PKG="apt"
elif command -v pacman &>/dev/null; then PKG="pacman"
else echo -e "${RED}No supported package manager${NC}"; exit 1; fi
success "Package manager: $PKG"

step "SHADOWOS POST-INSTALL SETUP"

# ─── System Update ──────────────────────────────────────────────────────
step "SYSTEM UPDATE"
case $PKG in
  apt) apt update -y 2>&1 | tail -5 && apt full-upgrade -y 2>&1 | tail -5 ;;
  pacman) pacman -Syu --noconfirm 2>&1 | tail -5 ;;
esac
success "System updated"

# ─── Install Core Packages ──────────────────────────────────────────────
step "INSTALLING CORE PACKAGES"
case $PKG in
  apt) apt install -y zsh tmux git curl wget htop btop neofetch figlet build-essential python3-pip python3-venv neovim vim nmap netcat dnsutils whois traceroute firejail apparmor-utils lynis clamav docker.io docker-compose podman tor torsocks wireguard-tools openvpn nftables screenfetch tldr broot ranger fzf ripgrep fd-find dust procs sd bat exa sudo 2>&1 | tail -5 ;;
  pacman) pacman -S --noconfirm --needed zsh tmux git curl wget htop btop neofetch figlet base-devel python-pip neovim vim nmap netcat dnsutils whois traceroute firejail apparmor lynis clamav docker docker-compose podman tor torsocks wireguard-tools openvpn nftables screenfetch tldr broot ranger fzf ripgrep fd dust procs sd bat exa sudo 2>&1 | tail -5 ;;
esac
success "Core packages installed"

# ─── Oh My Zsh ──────────────────────────────────────────────────────────
step "CONFIGURING ZSH"
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /usr/share/oh-my-zsh 2>/dev/null || true
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k 2>/dev/null || true
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/zsh-autosuggestions 2>/dev/null || true
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting 2>/dev/null || true
# fzf is installed via package manager (line 41/42) - no need to clone separately
echo "/usr/bin/zsh" >> /etc/shells 2>/dev/null || true
success "Zsh configured"

# ─── Tmux Config ────────────────────────────────────────────────────────
step "CONFIGURING TMUX"
mkdir -p /etc/skel/.config/tmux
cat > /etc/skel/.config/tmux/tmux.conf << 'TMUX'
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc"
set -g base-index 1
set -g mouse on
set -g history-limit 50000
set -g escape-time 0
set -g status-style "bg=#0a0a0f,fg=#00ffff"
set -g status-left "#[bg=#00ffff,fg=#0a0a0f,bold] SHADOWOS #[bg=#0a0a0f,fg=#00ffff]│ #[fg=#ff00ff]#S "
set -g status-right "#[fg=#00ffff]#{cpu_percentage} #[fg=#ffbf00]#{ram_percentage} #[fg=#00ffff] %H:%M:%S "
set -g window-status-current-format "#[bg=#00ffff,fg=#0a0a0f,bold] #I:#W "
set -g pane-active-border-style "fg=#00ffff"
unbind C-b; set -g prefix C-a; bind C-a send-prefix
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
set -g mode-keys vi
bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded"
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
run '~/.tmux/plugins/tpm/tpm'
TMUX
success "Tmux configured"

# ─── Neovim Config ──────────────────────────────────────────────────────
step "CONFIGURING NEOVIM"
mkdir -p /etc/skel/.config/nvim
cat > /etc/skel/.config/nvim/init.vim << 'NVIM'
set termguicolors
set number relativenumber tabstop=4 shiftwidth=4 expandtab
set smartindent autoindent wrap linebreak incsearch hlsearch ignorecase smartcase
set mouse=a clipboard=unnamedplus hidden wildmenu wildmode=list:longest,full
set scrolloff=8 signcolumn=yes laststatus=2 noshowmode
let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :Grep<CR>
nnoremap <leader>e :NvimTreeToggle<CR>
nnoremap <leader>t :ToggleTerm<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
filetype plugin indent on
syntax on
colorscheme desert
NVIM
success "Neovim configured"

# ─── Kitty Terminal Config ──────────────────────────────────────────────
step "CONFIGURING KITTY"
mkdir -p /etc/skel/.config/kitty
cat > /etc/skel/.config/kitty/kitty.conf << 'KITTY'
window_padding_width 8
initial_window_width 1200
initial_window_height 700
tab_bar_background #0a0a0f
active_tab_foreground #0a0a0f
active_tab_background #00ffff
inactive_tab_foreground #666666
inactive_tab_background #1a1a2e
background #0a0a0f
foreground #f0f0ff
selection_foreground #0a0a0f
selection_background #00ffff
cursor #00ffff
cursor_beam_thickness 2
scrollback_lines 10000
font_family JetBrains Mono
font_size 13
letter_spacing 0.5
line_height 1.2
shell /usr/bin/zsh
enable_audio_bell no
KITTY
success "Kitty configured"

# ─── Alacritty Terminal Config ───────────────────────────────────────────
step "CONFIGURING ALACRITTY"
mkdir -p /etc/skel/.config/alacritty
cat > /etc/skel/.config/alacritty/alacritty.toml << 'ALACRITTY'
[window]
title = "ShadowOS Terminal"
decorations = "Full"
padding = { x = 8, y = 8 }
opacity = 0.95
start_maximized = true

[font]
normal = { family = "JetBrains Mono", style = "Regular" }
size = 13.0

[colors]
primary = { background = "0x0a0a0f", foreground = "0xf0f0ff" }
cursor = { text = "0x0a0a0f", cursor = "0x00ffff" }
selection = { text = "0x0a0a0f", background = "0x00ffff40" }
normal = [
  { color = "0x666677" }, { color = "0xff0055" }, { color = "0x00ff88" },
  { color = "0xffbf00" }, { color = "0x00ffff" }, { color = "0xff00ff" },
  { color = "0x00d4ff" }, { color = "0xc0c0c0" }
]
bright = [
  { color = "0x555577" }, { color = "0xff3377" }, { color = "0x00ffaa" },
  { color = "0xffcc00" }, { color = "0x55ffff" }, { color = "0xff55ff" },
  { color = "0x88ffff" }, { color = "0xffffff" }
]

[scrolling]
history = 10000
multiplier = 3
ALACRITTY
success "Alacritty configured"

# ─── Powerlevel10k Prompt ───────────────────────────────────────────────
step "CONFIGURING PROMPT"
cat > /etc/skel/.p10k.zsh << 'P10K'
POWERLEVEL9K_MODE='nerdfont-complete'
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{cyan}╰─%f "
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(root_indicator command_execution_time history context virtualenv node_version ram load time)
POWERLEVEL9K_OS_ICON_FOREGROUND='cyan'
POWERLEVEL9K_DIR_FOREGROUND='cyan'
POWERLEVEL9K_DIR_HOME_FOREGROUND='magenta'
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='green'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='yellow'
POWERLEVEL9K_STATUS_OK_FOREGROUND='green'
POWERLEVEL9K_STATUS_ERROR_FOREGROUND='red'
POWERLEVEL9K_ROOT_INDICATOR_FOREGROUND='red'
POWERLEVEL9K_RAM_FOREGROUND='cyan'
POWERLEVEL9K_LOAD_FOREGROUND='amber'
POWERLEVEL9K_TIME_FOREGROUND='cyan'
P10K
success "Powerlevel10k prompt configured"

# ─── Zsh Custom Prompt Script ───────────────────────────────────────────
mkdir -p /etc/skel/.local/bin
cat > /etc/skel/.local/bin/shadowos-prompt.sh << 'PROMPT'
#!/bin/bash
echo "╔══════════════════════════════════════════════════╗"
echo "║  🌑 SHADOWOS - Cyberpunk Terminal Interface     ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║  SYSTEM: $(hostname)                          ║"
echo "║  USER:   $(whoami)                              ║"
echo "║  SHELL:  ${SHELL}                               ║"
echo "║  UPTIME: $(uptime -p 2>/dev/null || uptime)     ║"
echo "╚══════════════════════════════════════════════════╝"
PROMPT
chmod +x /etc/skel/.local/bin/shadowos-prompt.sh

# ─── Zsh RC ──────────────────────────────────────────────────────────────
cat > /etc/skel/.zshrc << 'ZSHRC'
export ZSH="/usr/share/oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions docker docker-compose kubectl)
source $ZSH/oh-my-zsh.sh

shadowos-prompt.sh 2>/dev/null || true

alias ls='exa --color=always --icons --group-directories-first 2>/dev/null || ls --color=auto'
alias ll='exa --color=always --icons -la --group-directories-first 2>/dev/null || ls -la --color=auto'
alias cat='bat --color=always --style=header,grid 2>/dev/null || cat'
alias grep='rg --color=always 2>/dev/null || grep --color=auto'
alias find='fd --color=always 2>/dev/null || find'
alias du='dust --color=always 2>/dev/null || du -h'
alias ps='procs --color=always 2>/dev/null || ps'
alias top='btm 2>/dev/null || top'
alias vim='nvim 2>/dev/null || vim'
alias ai='ollama run llama3.1:8b 2>/dev/null || echo "Ollama not available"'
alias ai-code='ollama run codellama:7b 2>/dev/null || echo "Ollama not available"'
alias sys='btop 2>/dev/null || htop'
alias neofetch='neofetch --ascii_distro arch --colors 4 5 6 7 8 2>/dev/null || neofetch'

alias tor-on='sudo systemctl start tor 2>/dev/null && echo "Tor: ACTIVE" || echo "Tor not available"'
alias tor-off='sudo systemctl stop tor 2>/dev/null && echo "Tor: INACTIVE" || echo "Tor not available"'
alias scan='sudo nmap -sS -sV -O -A 2>/dev/null'
case $PKG in
  apt) alias update='sudo apt update -y && sudo apt upgrade -y 2>/dev/null || echo "Update failed"'
       alias clean='sudo apt autoremove -y 2>/dev/null; sudo apt autoclean 2>/dev/null' ;;
  pacman) alias update='sudo pacman -Syu --noconfirm 2>/dev/null || echo "Update failed"'
          alias clean='sudo pacman -Sc --noconfirm 2>/dev/null' ;;
esac

function shadowos-status() {
    echo -e "\033[0;36m╔══════════════════════════════════════════════╗\033[0m"
    echo -e "\033[0;36m║  🌑 SHADOWOS Status Monitor                  ║\033[0m"
    echo -e "\033[0;36m╠══════════════════════════════════════════════╣\033[0m"
    echo -e "\033[0;36m║  CPU: \033[0;32m$(top -bn1 2>/dev/null | grep 'Cpu(s)' | awk '{print $2}' || echo N/A)%\033[0m"
    echo -e "\033[0;36m║  MEM: \033[0;32m$(free -h 2>/dev/null | awk '/^Mem:/{print $3"/"$2}' || echo N/A)\033[0m"
    echo -e "\033[0;36m║  DISK: \033[0;32m$(df -h / 2>/dev/null | awk 'NR==2{print $3"/"$2" ("$5")"}')\033[0m"
    echo -e "\033[0;36m║  IP: \033[0;32m$(hostname -I 2>/dev/null | awk '{print $1}' || echo N/A)\033[0m"
    echo -e "\033[0;36m║  TOR: \033[0;33m$(systemctl is-active tor 2>/dev/null || echo inactive)\033[0m"
    echo -e "\033[0;36m║  FIREWALL: \033[0;33m$(systemctl is-active nftables 2>/dev/null || echo inactive)\033[0m"
    echo -e "\033[0;36m╚══════════════════════════════════════════════╝\033[0m"
}

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null'
export FZF_DEFAULT_OPTS="--ansi --height 40% --layout=reverse --border --color=bg:#0a0a0f,fg:#f0f0ff,hl:#00ffff,fg+:#f0f0ff,bg+:#1a1a2e,hl+:#ff00ff"
# Source fzf completion and key bindings if available (installed via package manager)
if [ -f /usr/share/zsh/site-functions/_fzf ]; then
    source /usr/share/zsh/site-functions/_fzf 2>/dev/null
elif [ -f /usr/share/fzf/completion.zsh ]; then
    source /usr/share/fzf/completion.zsh 2>/dev/null
fi
if [ -f /usr/share/zsh/site-functions/_fzf-key-bindings ]; then
    source /usr/share/zsh/site-functions/_fzf-key-bindings 2>/dev/null
elif [ -f /usr/share/fzf/key-bindings.zsh ]; then
    source /usr/share/fzf/key-bindings.zsh 2>/dev/null
fi

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
ZSH_HIGHLIGHT_STYLES[default]="fg=#f0f0ff"
ZSH_HIGHLIGHT_STYLES[command]="fg=#00ffff"
ZSH_HIGHLIGHT_STYLES[arg0]="fg=#ffbf00"
ZSH_HIGHLIGHT_STYLES[path]="fg=#666677"

export NEON_CYAN="#00FFFF"
export NEON_MAGENTA="#FF00FF"
export NEON_AMBER="#FFBF00"
export BG_DARK="#0A0A0F"
ZSHRC
success "Zsh configured with cyberpunk prompt and aliases"

# ─── Network Privacy ────────────────────────────────────────────────────
step "CONFIGURING NETWORK PRIVACY"
mkdir -p /etc/skel/.config/tor
cat > /etc/skel/.config/tor/torrc << 'TORRC'
SocksPort 9050
ControlPort 9051
CookieAuthentication 1
DNSPort 5353
AutomapHostsOnResolve 1
TransPort 9040
TransListenAddress 127.0.0.1
DNSListenAddress 127.0.0.1
Log notice syslog
SafeLogging 1
TORRC
success "Network privacy configured"

# ─── Security Hardening ─────────────────────────────────────────────────
step "SECURITY HARDENING"
cat >> /etc/sysctl.d/99-shadowos-security.conf << 'SYSCTL'
kernel.randomize_va_space = 2
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
kernel.yama.ptrace_scope = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.log_martians = 1
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
SYSCTL
sysctl --system 2>/dev/null || true
success "Kernel parameters hardened"

mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/shadowos.conf << 'SSHCONF'
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
Port 2222
Protocol 2
SSHCONF
success "SSH hardened"

chmod 700 /root 2>/dev/null || true
chmod 600 /etc/crontab 2>/dev/null || true
chmod 600 /etc/ssh/sshd_config 2>/dev/null || true
chmod 600 /etc/shadow 2>/dev/null || true
echo "* hard core 0" >> /etc/security/limits.conf
success "File permissions hardened"

# ─── AI Integration ─────────────────────────────────────────────────────
step "CONFIGURING AI INTEGRATION"
mkdir -p /etc/skel/.local/bin

cat > /etc/skel/.local/bin/ai << 'AICMD'
#!/bin/bash
DEFAULT_MODEL="llama3.1:8b"
API_URL="http://localhost:11434"
if ! curl -s "$API_URL/api/tags" &>/dev/null; then
    echo "⚠ Ollama not running. Start it with: ollama serve"
    exit 1
fi
if [ $# -eq 0 ]; then
    echo "Usage: ai <model> <prompt>  or  ai <prompt> (uses default model)"
    exit 0
fi
if [ $# -eq 1 ]; then
    MODEL="$DEFAULT_MODEL"
    PROMPT="$1"
else
    MODEL="$1"
    PROMPT="$2"
fi
echo -e "\033[0;36m🤖 ShadowOS AI (\033[0;33m$MODEL\033[0;36m)\033[0m"
echo ""
curl -s "$API_URL/api/generate" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"stream\":false}" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('response','No response'))"
AICMD
chmod +x /etc/skel/.local/bin/ai

cat > /etc/skel/.local/bin/ai-scan << 'AISCAN'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: ai-scan <target>"; exit 1; fi
echo -e "\033[0;36m[*] AI-Powered Security Scan: $1\033[0m"
nmap -sS -sV -O -A "$1" 2>&1 | tee /tmp/scan-result.txt
echo -e "\033[0;36m[*] Analyzing results with AI...\033[0m"
ai "Analyze this nmap scan output for vulnerabilities: $(cat /tmp/scan-result.txt)"
AISCAN
chmod +x /etc/skel/.local/bin/ai-scan

cat > /etc/skel/.local/bin/ai-review << 'AIREVIEW'
#!/bin/bash
if [ -z "$1" ]; then echo "Usage: ai-review <file>"; exit 1; fi
if [ ! -f "$1" ]; then echo "File not found: $1"; exit 1; fi
echo -e "\033[0;36m[*] AI Code Review: $1\033[0m"
ai "Review this code for security vulnerabilities and bugs: $(cat "$1")"
AIREVIEW
chmod +x /etc/skel/.local/bin/ai-review

cat > /etc/skel/.local/bin/ai-start << 'AISTART'
#!/bin/bash
echo "🤖 Starting Ollama AI engine..."
ollama serve &
sleep 2
echo "✓ Ollama running on http://localhost:11434"
echo "Usage: ai <prompt>"
AISTART
chmod +x /etc/skel/.local/bin/ai-start

cat > /etc/skel/.local/bin/ai-stop << 'AISTOP'
#!/bin/bash
echo "🛑 Stopping Ollama..."
pkill ollama 2>/dev/null || true
echo "✓ Ollama stopped"
AISTOP
chmod +x /etc/skel/.local/bin/ai-stop

success "AI integration configured"

# ─── Desktop Theme ──────────────────────────────────────────────────────
step "CONFIGURING DESKTOP THEME"
mkdir -p /etc/skel/.local/share/themes/ShadowOS
mkdir -p /etc/skel/.config/gtk-3.0
mkdir -p /etc/skel/.config/gtk-4.0

cat > /etc/skel/.config/gtk-3.0/settings.ini << 'GTK3'
[Settings]
gtk-theme-name=ShadowOS
gtk-icon-theme-name=ShadowOS
gtk-font-name=JetBrains Mono 11
gtk-cursor-theme-name=ShadowOS
gtk-cursor-size=24
gtk-application-prefer-dark-theme=1
gtk-enable-animations=1
GTK3

cp /etc/skel/.config/gtk-3.0/settings.ini /etc/skel/.config/gtk-4.0/settings.ini
success "Desktop theme configured"

# ─── Cyberpunk UI Theme Suite ─────────────────────────────────────────────
step "INSTALLING CYBERPUNK UI THEME SUITE"
if [ -f "/usr/share/themes/ShadowOS-Dark/gtk-3.0/gtk.css" ]; then
    info "Cyberpunk theme already installed"
else
    bash /etc/skel/.config/shadowos/cyberpunk-theme/install-theme.sh 2>/dev/null || {
        warn "Could not install full theme suite - some components may be missing"
        warn "Run 'shadowos-install-themes' after boot for complete installation"
    }
    success "Cyberpunk UI theme suite installed"
fi

# ─── Finalization ───────────────────────────────────────────────────────
step "FINALIZING SETUP"

if command -v chsh &>/dev/null && [ -n "${SUDO_USER:-}" ]; then
    chsh -s /usr/bin/zsh "$SUDO_USER" 2>/dev/null || true
    success "Default shell set to zsh for $SUDO_USER"
fi

mkdir -p /opt/workspace
chmod 777 /opt/workspace
success "Workspace created at /opt/workspace"

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🌑 SHADOWOS SETUP COMPLETE                      ║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  Please log out and log back in for full effect  ║${NC}"
echo -e "${CYAN}║  Run 'shadowos-status' to check system state     ║${NC}"
echo -e "${CYAN}║  Run 'ai <prompt>' for AI assistance             ║${NC}"
echo -e "${CYAN}║  Run 'neofetch' to display system info           ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════╝${NC}"

