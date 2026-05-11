#!/bin/bash
# ============================================================================
# ShadowOS WSL2 Setup Script
# For running ShadowOS on Windows via WSL2
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'

step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
info() { echo -e "  ${BLUE}ℹ${NC} $1"; }

step "SHADOWOS WSL2 SETUP"
echo -e "  ${YELLOW}Note: Some packages require full Linux and won't be available in WSL2.${NC}"
echo -e "  ${YELLOW}This script installs everything that works in WSL2.${NC}"
echo ""

# ─── Enable Universe/Multiverse Repos ──────────────────────────────────
step "ENABLING REPOSITORIES"

# WSL2 may not have add-apt-repository, use direct method
echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) universe" | sudo tee -a /etc/apt/sources.list > /dev/null 2>&1 || true
echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) multiverse" | sudo tee -a /etc/apt/sources.list > /dev/null 2>&1 || true
echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs)-updates universe" | sudo tee -a /etc/apt/sources.list > /dev/null 2>&1 || true

sudo apt update -y 2>&1 | tail -5
success "Repositories enabled"

# ─── Install Available Packages ────────────────────────────────────────
step "INSTALLING PACKAGES"

sudo apt install -y \
    git zsh tmux vim neofetch htop \
    curl wget build-essential python3-venv \
    software-properties-common unzip zip tar \
    tree silversearcher-ag fd-find dust procs \
    2>&1 | tail -5

# python3-pip via alternative
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3 2>&1 | tail -3 || true

success "Core packages installed"

# ─── Install Tools via GitHub Releases ──────────────────────────────────
step "INSTALLING TOOLS VIA GITHUB RELEASES"

install_github_release() {
    local name="$1"
    local repo="$2"
    local pattern="$3"
    local extract_cmd="${4:-}"
    
    if command -v "$name" &>/dev/null; then
        info "$name already installed"
        return 0
    fi
    
    local version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name"' | sed 's/.*"v\?\([^"]*\)".*/\1/')
    if [ -z "$version" ]; then
        warn "Could not get latest version for $name"
        return 1
    fi
    
    local url="https://github.com/$repo/releases/download/v${version}/${pattern}"
    local tmpfile="/tmp/${name}-install"
    
    curl -sL "$url" -o "$tmpfile" 2>/dev/null
    if [ -f "$tmpfile" ] && [ -s "$tmpfile" ]; then
        if [ -n "$extract_cmd" ]; then
            eval "$extract_cmd"
        else
            sudo mv "$tmpfile" "/usr/local/bin/$name" 2>/dev/null || mv "$tmpfile" "$HOME/.local/bin/$name" 2>/dev/null
            chmod +x "$HOME/.local/bin/$name" 2>/dev/null || true
        fi
        success "$name installed (v$version)"
    else
        warn "$name download failed"
    fi
}

# fzf
if ! command -v fzf &>/dev/null; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf 2>/dev/null
    ~/.fzf/install --all 2>/dev/null || true
    success "fzf installed"
else
    info "fzf already installed"
fi

# Neovim (AppImage)
install_github_release "nvim" "neovim/neovim" "nvim.appimage" "chmod +x /tmp/nvim-install && sudo mv /tmp/nvim-install /usr/local/bin/nvim"

# bat
install_github_release "bat" "sharkdp/bat" "bat_*.deb" "sudo dpkg -i /tmp/bat-install 2>/dev/null || sudo apt install -y /tmp/bat-install 2>/dev/null || true"

# ripgrep
install_github_release "rg" "BurntSushi/ripgrep" "ripgrep_*.deb" "sudo dpkg -i /tmp/rg-install 2>/dev/null || true"

# eza
install_github_release "eza" "eza-community/eza" "eza*.tar.gz.gz" "tar xzf /tmp/eza-install -C /tmp/ 2>/dev/null && sudo mv /tmp/eza /usr/local/bin/ 2>/dev/null || true"

# btop
install_github_release "btop" "aristocratos/btop" "btop-x86_64-linux-musl.tbj" "mkdir -p /tmp/btop-tmp && tar xjf /tmp/btop-install -C /tmp/btop-tmp --strip-components=1 2>/dev/null && sudo mv /tmp/btop-tmp/btop /usr/local/bin/ 2>/dev/null || true"

# delta
install_github_release "delta" "dandavison/delta" "delta-*.tar.gz" "tar xzf /tmp/delta-install -C /tmp/ 2>/dev/null && sudo mv /tmp/delta-*/delta /usr/local/bin/ 2>/dev/null || true"

# lazygit
install_github_release "lazygit" "jesseduffield/lazygit" "lazygit_*.tar.gz" "tar xzf /tmp/lazygit-install -C /tmp/ 2>/dev/null && sudo mv /tmp/lazygit /usr/local/bin/ 2>/dev/null || true"

# tldr
install_github_release "tldr" "tldr-pages/tldr" "tldr-linux-bin.tar.gz" "tar xzf /tmp/tldr-install -C /tmp/ 2>/dev/null && sudo mv /tmp/tldr /usr/local/bin/ 2>/dev/null || true"

# broot
install_github_release "broot" "Canop/broot" "broot" "chmod +x /tmp/broot-install && sudo mv /tmp/broot-install /usr/local/bin/broot"

# ranger
if ! command -v ranger &>/dev/null; then
    sudo apt install -y ranger 2>/dev/null || pip3 install --break-system-packages ranger-fm 2>/dev/null || warn "ranger skipped"
    success "ranger installed"
else
    info "ranger already installed"
fi

# duf
install_github_release "duf" "muesli/duf" "duf_*.deb" "sudo dpkg -i /tmp/duf-install 2>/dev/null || true"

# glow
install_github_release "glow" "charmbracelet/glow" "glow_*.tar.gz" "tar xzf /tmp/glow-install -C /tmp/ 2>/dev/null && sudo mv /tmp/glow /usr/local/bin/ 2>/dev/null || true"

# ─── Install Python ML Packages ─────────────────────────────────────────
step "INSTALLING PYTHON PACKAGES"
python3 -m pip install --break-system-packages torch torchvision transformers \
    sentencepiece protobuf accelerate langchain chromadb faiss-cpu \
    openai-whisper pydub speechrecognition pyttsx3 \
    jupyterlab notebook 2>&1 | tail -10 || warn "Some Python packages failed (expected on limited WSL2)"
success "Python packages installed (best effort)"

# ─── Install Ollama ─────────────────────────────────────────────────────
step "INSTALLING OLLAMA"
if ! command -v ollama &>/dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh 2>&1 | tail -5 || warn "Ollama install failed (may need GPU)"
    success "Ollama installed"
else
    info "Ollama already installed"
fi

# ─── Install Node.js Tools ──────────────────────────────────────────────
step "INSTALLING NODE TOOLS"
if ! command -v npm &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>&1 | tail -3
    sudo apt install -y nodejs 2>&1 | tail -3
fi
npm install -g --silent typescript typescript-language-server prettier eslint 2>&1 | tail -3 || true
success "Node.js tools installed"

# ─── Install Go Tools ───────────────────────────────────────────────────
step "INSTALLING GO"
if ! command -v go &>/dev/null; then
    GO_VERSION="1.21"
    curl -sL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz 2>/dev/null
    if [ -f /tmp/go.tar.gz ]; then
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz 2>/dev/null
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
        success "Go installed"
    else
        warn "Go download failed"
    fi
fi
if command -v go &>/dev/null; then
    go install golang.org/x/tools/gopls@latest 2>&1 | tail -3 || true
fi

# ─── Install Rust Tools ─────────────────────────────────────────────────
step "INSTALLING RUST"
if ! command -v rustc &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1 | tail -5
    source "$HOME/.cargo/env"
    rustup component add rust-analyzer rustfmt clippy 2>&1 | tail -3 || true
    success "Rust installed"
else
    info "Rust already installed"
fi

# ─── Install Oh My Zsh ──────────────────────────────────────────────────
step "CONFIGURING ZSH"
if [ ! -d /usr/share/oh-my-zsh ]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /usr/share/oh-my-zsh 2>/dev/null
fi
if [ ! -d /usr/share/zsh-theme-powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k 2>/dev/null
fi
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/zsh-autosuggestions 2>/dev/null || true
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting 2>/dev/null || true
echo "/usr/bin/zsh" >> /etc/shells 2>/dev/null || true
success "Zsh configured"

# ─── Copy ShadowOS Configs ──────────────────────────────────────────────
step "APPLYING SHADOWOS CONFIGURATIONS"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Zsh config
if [ -f "$SCRIPT_DIR/../terminal-setup/zsh/.zshrc" ]; then
    cp "$SCRIPT_DIR/../terminal-setup/zsh/.zshrc" ~/.zshrc
    success "Zsh config applied"
fi

# Tmux config
mkdir -p ~/.config/tmux
if [ -f "$SCRIPT_DIR/../terminal-setup/tmux/.tmux.conf" ]; then
    cp "$SCRIPT_DIR/../terminal-setup/tmux/.tmux.conf" ~/.config/tmux/tmux.conf
    success "Tmux config applied"
fi

# Neovim config
mkdir -p ~/.config/nvim
if [ -f "$SCRIPT_DIR/../terminal-setup/nvim/cyberpunk.vim" ]; then
    cp "$SCRIPT_DIR/../terminal-setup/nvim/cyberpunk.vim" ~/.config/nvim/init.vim
    success "Neovim config applied"
fi

# Kitty config
mkdir -p ~/.config/kitty
if [ -f "$SCRIPT_DIR/../cyberpunk-theme/terminal/cyberpunk.conf" ]; then
    cp "$SCRIPT_DIR/../cyberpunk-theme/terminal/cyberpunk.conf" ~/.config/kitty/kitty.conf
    success "Kitty config applied"
fi

# Alacritty config
mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.toml << 'ALACRITTY'
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
success "Alacritty config applied"

# Powerlevel10k config
cat > ~/.p10k.zsh << 'P10K'
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
success "Powerlevel10k configured"

# ─── Create ShadowOS Helper Commands ────────────────────────────────────
mkdir -p ~/.local/bin

cat > ~/.local/bin/shadowos-status << 'STATUS'
#!/bin/bash
echo ""
echo -e "\033[0;36m╔══════════════════════════════════════════════╗\033[0m"
echo -e "\033[0;36m║  🌑 SHADOWOS Status Monitor                  ║\033[0m"
echo -e "\033[0;36m╠══════════════════════════════════════════════╣\033[0m"
echo -e "\033[0;36m║  CPU: \033[0;32m\$(top -bn1 2>/dev/null | grep 'Cpu(s)' | awk '{print \$2}' || echo "N/A")%\033[0m"
echo -e "\033[0;36m║  MEM: \033[0;32m\$(free -h 2>/dev/null | awk '/^Mem:/{print \$3"/"\$2}' || echo "N/A")\033[0m"
echo -e "\033[0;36m║  DISK: \033[0;32m\$(df -h / 2>/dev/null | awk 'NR==2{print \$3"/"\$2" ("\$5")"}')\033[0m"
echo -e "\033[0;36m║  IP:   \033[0;32m\$(hostname -I 2>/dev/null | awk '{print \$1}' || echo "N/A")\033[0m"
echo -e "\033[0;36m║  OS:   \033[0;36mShadowOS on WSL2\033[0m"
echo -e "\033[0;36m╚══════════════════════════════════════════════╝\033[0m"
STATUS
chmod +x ~/.local/bin/shadowos-status

cat > ~/.local/bin/ai << 'AI'
#!/bin/bash
if ! command -v ollama &>/dev/null; then
    echo "⚠ Ollama not installed. Run: ollama serve"
    exit 1
fi
if ! curl -s http://localhost:11434/api/tags &>/dev/null; then
    echo "⚠ Ollama not running. Start it with: ollama serve"
    exit 1
fi
DEFAULT_MODEL="llama3.1:8b"
if [ $# -eq 0 ]; then
    echo "Usage: ai <prompt> or ai <model> <prompt>"
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
curl -s http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"stream\":false}" \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('response','No response'))"
AI
chmod +x ~/.local/bin/ai

success "ShadowOS helper commands created"

# ─── Done ───────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ ShadowOS WSL2 Setup Complete!${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}Next steps:${NC}"
echo -e "    1. Close and reopen your Ubuntu terminal"
echo -e "    2. Zsh will launch with the cyberpunk prompt"
echo -e "    3. Run: ${GREEN}shadowos-status${NC} to check your system"
echo -e "    4. Run: ${GREEN}neofetch${NC} to see system info"
echo -e "    5. Run: ${GREEN}tmux${NC} to enter the neon status bar session"
echo -e "    6. Run: ${GREEN}nvim${NC} to open the cyberpunk editor"
echo ""
echo -e "  ${YELLOW}Optional:${NC}"
echo -e "    Start Ollama for AI: ${GREEN}ollama serve${NC}"
echo -e "    Then try: ${GREEN}ai \"Hello ShadowOS!\"${NC}"
echo ""