# ============================================================================
# ShadowOS Zsh Configuration
# Cyberpunk-themed powerline prompt with AI integration
# ============================================================================

# ─── Oh My Zsh ───────────────────────────────────────────────────────────
export ZSH="/usr/share/oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRASHED="true"
HYPHEN_INSENSITIVE="true"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    docker
    docker-compose
    kubectl
    pip
    python
    vscode
    history-substring-search
    copybuffer
    copyfile
    copypath
    dircycle
    extract
    per-directory-history
    colored-man-pages
    colorize
    urltools
    encode64
    emoji
    emoji-clock
    git-auto-fetch
    git-escape-magic
    git-extras
    gitfast
    git-flow
    gitignore
    httpie
    jsontools
    macos
    rsync
    scd
    sudo
    systemadmin
    taskwarrior
    tmux
    transfer
    web-search
    zsh-interactive-cd
    zsh-navigation-tools
)

source $ZSH/oh-my-zsh.sh

# ─── Powerlevel10k Configuration ────────────────────────────────────────
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ─── Cyberpunk Color Scheme ─────────────────────────────────────────────
# Neon Cyberpunk palette
NEON_CYAN="#00FFFF"
NEON_MAGENTA="#FF00FF"
NEON_AMBER="#FFBF00"
NEON_GREEN="#00FF88"
NEON_RED="#FF0055"
BG_DARK="#0A0A0F"
BG_PANEL="#1A1A2E"
FG_LIGHT="#F0F0FF"

# ─── Custom Aliases ─────────────────────────────────────────────────────

# System shortcuts
alias update='sudo apt update && sudo apt upgrade -y'
alias upgrade='sudo apt full-upgrade -y'
alias clean='sudo apt autoremove -y && sudo apt autoclean'
alias reboot='sudo systemctl reboot'
alias shutdown='sudo systemctl poweroff'
alias suspend='sudo systemctl suspend'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias ws='cd /opt/workspace'

# File operations
alias ls='eza --color=always --icons --group-directories-first'
alias ll='eza --color=always --icons -la --group-directories-first'
alias lt='eza --color=always --icons --tree --level=2'
alias la='ls -la'
alias cat='bat --color=always --style=header,grid'
alias grep='rg --color=always'
alias find='fd --color=always'
alias du='dust --color=always'
alias df='duf'
alias ps='procs --color=always'
alias top='btm'
alias free='free -h'
alias mkdir='mkdir -p'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --all'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gr='git rebase'
alias gf='git fetch --all --prune'
alias gclean='git clean -fd && git checkout -- .'

# Network & Privacy
alias tor-on='sudo systemctl start tor && echo "🔒 Tor: ACTIVE"'
alias tor-off='sudo systemctl stop tor && echo "🔓 Tor: INACTIVE"'
alias tor-status='systemctl is-active tor'
alias vpn-up='sudo wg-quick up wg0 && echo "🔒 VPN: ACTIVE"'
alias vpn-down='sudo wg-quick down wg0 && echo "🔓 VPN: INACTIVE"'
alias vpn-status='sudo wg show'
alias myip='curl -s ifconfig.me'
alias dns-test='curl -s https://dnsleaktest.com/api/v1/dns | python3 -m json.tool'

# AI Commands (v2026.2 — Updated Models)
alias ai='ollama run llama3.2:8b'
alias ai-code='ollama run codellama:7b'
alias ai-chat='ollama run gemma2:9b'
alias ai-light='ollama run phi3:mini'
alias ai-vision='ollama run llava:7b'
alias ai-models='bash /opt/ShadowOS/scripts/ai-models.sh'
alias ai-scan='/etc/skel/.local/bin/ai-scan'
alias ai-review='/etc/skel/.local/bin/ai-review'
alias ai-start='/etc/skel/.local/bin/ai-start'
alias ai-stop='/etc/skel/.local/bin/ai-stop'
alias ai-diagnose='/etc/skel/.local/bin/ai-diagnose'

# Pentest shortcuts
alias scan='sudo nmap -sS -sV -O -A'
alias scan-full='sudo nmap -p- -sS -sV -O -A -T4'
alias scan-top='sudo nmap -sS -sV --top-ports 100'
alias enum='enum4linux -a'
alias web-scan='nikto -h'
alias vuln-check='nuclei -u'
alias dir-bust='gobuster dir -u'

# Development
alias vim='nvim'
alias vi='nvim'
alias nvim-config='nvim ~/.config/nvim/init.vim'
alias zsh-config='nvim ~/.zshrc'
alias tmux-config='nvim ~/.config/tmux/tmux.conf'
alias serve='python3 -m http.server 8080'
alias tunnel='ssh -R 8080:localhost:8080 serveo.net'
alias ports='ss -tlnp'
alias speed='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# Docker shortcuts
alias dps='docker ps'
alias dpa='docker ps -a'
alias dim='docker images'
alias dvol='docker volume ls'
alias dnet='docker network ls'
alias dlogs='docker logs'
alias dcompose='docker-compose'

# System monitoring
alias neofetch='neofetch --ascii_distro arch --colors 4 5 6 7 8'
alias sysinfo='inxi -Fxxxz'
alias cpu-info='lscpu'
alias mem-info='free -h'
alias disk-info='lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL'
alias gpu-info='lspci | grep -i vga'
alias temp='sensors 2>/dev/null || echo "lm-sensors not installed"'
alias processes='procs --sortd cpu'

# ShadowOS specific
alias shadowos-status='shadowos-status'
alias shadowos-update='sudo bash /opt/ShadowOS/scripts/auto-update.sh'
alias shadowos-backup='sudo tar czf /opt/ShadowOS-backup-$(date +%Y%m%d).tar.gz /etc/shadowos /opt/ShadowOS /root/.config 2>/dev/null'
alias shadowos-diagnose='bash /opt/ShadowOS/scripts/diagnostics.sh --quick'
alias shadowos-health='bash /opt/ShadowOS/scripts/diagnostics.sh --report'

# Power management (v2026.2.1)
alias power-profile='bash /opt/ShadowOS/scripts/power-profile.sh'
alias power-perf='sudo bash /opt/ShadowOS/scripts/power-profile.sh performance'
alias power-save='sudo bash /opt/ShadowOS/scripts/power-profile.sh powersave'
alias power-turbo='sudo bash /opt/ShadowOS/scripts/power-profile.sh turbo'
alias power-status='bash /opt/ShadowOS/scripts/power-profile.sh status'

# Backup (encrypted, v2026.2.1)
alias backup-create='sudo bash /opt/ShadowOS/scripts/backup-encrypted.sh create'
alias backup-restore='sudo bash /opt/ShadowOS/scripts/backup-encrypted.sh restore'
alias backup-list='bash /opt/ShadowOS/scripts/backup-encrypted.sh list'

# Security hardening (v2026.2.1)
alias bluetooth-harden='sudo bash /opt/ShadowOS/security-hardening/bluetooth-hardening.sh harden'
alias bluetooth-disable='sudo bash /opt/ShadowOS/security-hardening/bluetooth-hardening.sh disable'
alias bluetooth-status='sudo bash /opt/ShadowOS/security-hardening/bluetooth-hardening.sh status'

# ─── Functions ───────────────────────────────────────────────────────────

# ShadowOS system status
function shadowos-status() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  🌑 SHADOWOS Status Monitor                    ║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  CPU:  \033[0;32m$(top -bn1 | grep 'Cpu(s)' | awk '{print $2}')%\033[0m"
    echo -e "${CYAN}║${NC}  MEM:  \033[0;32m$(free -h | awk '/^Mem:/{print $3"/"$2}')\033[0m"
    echo -e "${CYAN}║${NC}  DISK: \033[0;32m$(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')\033[0m"
    echo -e "${CYAN}║${NC}  IP:   \033[0;32m$(hostname -I 2>/dev/null | awk '{print $1}')\033[0m"
    echo -e "${CYAN}║${NC}  TOR:  \033[0;33m$(systemctl is-active tor 2>/dev/null || echo inactive)\033[0m"
    echo -e "${CYAN}║${NC}  FW:   \033[0;33m$(systemctl is-active nftables 2>/dev/null || echo inactive)\033[0m"
    echo -e "${CYAN}║${NC}  GPU:  \033[0;36m$(lspci 2>/dev/null | grep -i vga | cut -d: -f3 | head -1)\033[0m"
    echo -e "${CYAN}║${NC}  OS:   \033[0;36mShadowOS $(cat /etc/os-release | grep VERSION_ID | cut -d= -f2 | tr -d '"')\"\033[0m"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
}

# Quick pentest scan
function quick-scan() {
    if [ -z "$1" ]; then
        echo "Usage: quick-scan <target>"
        return 1
    fi
    echo -e "\033[0;36m[*] Quick Scan: $1\033[0m"
    sudo nmap -sS -sV -O -A --top-ports 100 "$1"
}

# AI-assisted search
function ai-search() {
    if [ -z "$1" ]; then
        echo "Usage: ai-search <query>"
        return 1
    fi
    curl -s "https://api.duckduckgo.com/?q=$1&format=json" | \
        python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('AbstractText','No result'))"
}

# Weather
function weather() {
    curl -s "wttr.in/${1:-Your+City}?format=3"
}

# Matrix effect
function matrix() {
    local cols=$(tput cols)
    local lines=$(tput lines)
    local chars=(ヾ｡◕‿‿◕｡ヾ)
    for ((i=0; i<100; i++)); do
        for ((j=0; j<cols; j++)); do
            echo -ne "\033[${i}H\033[${j}C${chars[$RANDOM % ${#chars[@]}]}"
        done
    done
}

# ─── Fuzzy Finder Integration ───────────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="
    --ansi
    --height 40%
    --layout=reverse
    --border
    --color=bg:#0a0a0f,fg:#f0f0ff,hl:#00ffff,fg+:#f0f0ff,bg+:#1a1a2e,hl+:#ff00ff
    --preview='bat --color=always {}'
"

# Key bindings for fzf
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh

# ─── Zsh Syntax Highlighting ────────────────────────────────────────────
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor rootline)
ZSH_HIGHLIGHT_STYLES[default]="fg=#f0f0ff"
ZSH_HIGHLIGHT_STYLES[command]="fg=#00ffff"
ZSH_HIGHLIGHT_STYLES[arg0]="fg=#ffbf00"
ZSH_HIGHLIGHT_STYLES[path]="fg=#666677"
ZSH_HIGHLIGHT_STYLES[globbing]="fg=#ff00ff"
ZSH_HIGHLIGHT_STYLES[alias]="fg=#00ff88"
ZSH_HIGHLIGHT_STYLES[function]="fg=#00ff88"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=#00ffff"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=#ffbf00,bold"
ZSH_HIGHLIGHT_STYLES[commandseparator]="fg=#ff00ff"

# ─── Export Cyberpunk Colors ────────────────────────────────────────────
export NEON_CYAN="#00FFFF"
export NEON_MAGENTA="#FF00FF"
export NEON_AMBER="#FFBF00"
export NEON_GREEN="#00FF88"
export NEON_RED="#FF0055"
export BG_DARK="#0A0A0F"
export BG_PANEL="#1A1A2E"
export FG_LIGHT="#F0F0FF"

# ─── Prompt Indicator ───────────────────────────────────────────────────
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX="%F{cyan}╰─%f "

# ─── Source Plugins ─────────────────────────────────────────────────────
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme 2>/dev/null

# ─── Custom Prompt Info ─────────────────────────────────────────────────
if [ -x /etc/skel/.local/bin/shadowos-prompt.sh ]; then
    /etc/skel/.local/bin/shadowos-prompt.sh 2>/dev/null || true
fi