#!/bin/bash
# ============================================================================
# ShadowOS Development Environment Setup
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
info() { echo -e "  ${BLUE}ℹ${NC} $1"; }

step "SHADOWOS DEVELOPMENT ENVIRONMENT SETUP"

# ─── Workspace Structure ────────────────────────────────────────────────
mkdir -p /opt/workspace/{projects,scripts,configs,docker,vm}
chmod 777 /opt/workspace
success "Workspace created at /opt/workspace"

# ─── Git Configuration ──────────────────────────────────────────────────
step "CONFIGURING GIT"
git config --global init.defaultBranch main
git config --global core.editor "nvim"
git config --global pull.rebase true
git config --global fetch.prune true
git config --global color.ui auto
git config --global push.default simple
git config --global diff.colorMoved default
git config --global merge.conflictstyle zdiff3
git config --global rebase.autoStash true
git config --global commit.gpgsign false
success "Git configured"

# ─── Docker Configuration ───────────────────────────────────────────────
step "CONFIGURING DOCKER"
if command -v docker &>/dev/null; then
    # Add user to docker group
    if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
        usermod -aG docker "$SUDO_USER" 2>/dev/null || true
        success "User '$SUDO_USER' added to docker group"
    fi

    # Create Docker config for registry mirrors
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json << 'DOCKERCONF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "live-restore": true
}
DOCKERCONF
    success "Docker configured"
else
    warn "Docker not installed — skipping"
fi

# ─── Podman Configuration ───────────────────────────────────────────────
if command -v podman &>/dev/null; then
    mkdir -p /etc/containers
    cat > /etc/containers/registries.conf << 'PODMANCONF'
[registries.search]
registries = ['docker.io', 'quay.io', 'ghcr.io']

[registries.block]
registries = []
PODMANCONF
    success "Podman configured"
fi

# ─── Language Servers & Dev Tools ───────────────────────────────────────
step "INSTALLING LANGUAGE SERVERS"

# Python
if command -v python3 &>/dev/null; then
    pip3 install --break-system-packages --quiet \
        pyright pylsp python-lsp-server 2>/dev/null || true
    pip3 install --break-system-packages --quiet \
        black isort mypy ruff 2>/dev/null || true
    success "Python language tools installed"
fi

# Node.js / TypeScript
if command -v npm &>/dev/null; then
    npm install -g --silent typescript typescript-language-server \
        @typescript-eslint/typescript-estree 2>/dev/null || true
    npm install -g --silent prettier eslint @eslint/js 2>/dev/null || true
    success "Node.js language tools installed"
fi

# Go
if command -v go &>/dev/null; then
    go install golang.org/x/tools/gopls@latest 2>/dev/null || true
    go install mvdan.cc/gofumpt@latest 2>/dev/null || true
    go install honnef.co/go/tools/cmd/staticcheck@latest 2>/dev/null || true
    success "Go language tools installed"
fi

# Rust
if command -v rustup &>/dev/null; then
    rustup component add rust-analyzer rustfmt clippy 2>/dev/null || true
    success "Rust language tools installed"
fi

# C/C++
if command -v clangd &>/dev/null; then
    success "clangd available for C/C++ LSP"
fi

# ─── Container Tooling ──────────────────────────────────────────────────
step "SETTING UP CONTAINER TOOLING"

# Docker Compose v2
if command -v docker &>/dev/null; then
    if ! docker compose version &>/dev/null; then
        warn "Docker Compose v2 not available — using v1"
    fi
fi

# Devcontainers CLI
npm install -g --silent @devcontainers/cli 2>/dev/null || true

# ─── Build Tools ────────────────────────────────────────────────────────
step "CONFIGURING BUILD TOOLS"

# CMake presets
mkdir -p /opt/workspace/configs
cat > /opt/workspace/configs/CMakePresets.json << 'CMAKE'
{
    "version": 3,
    "cmakeMinimumRequired": {
        "major": 3,
        "minor": 23,
        "patch": 0
    },
    "configurePresets": [
        {
            "name": "base",
            "hidden": true,
            "generator": "Unix Makefiles",
            "binaryDir": "${sourceDir}/build/${presetName}",
            "cacheVariables": {
                "CMAKE_CXX_STANDARD": "20",
                "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"
            }
        },
        {
            "name": "debug",
            "displayName": "Debug",
            "description": "Debug build with sanitizers",
            "inherits": "base",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Debug",
                "CMAKE_CXX_FLAGS_DEBUG": "-g -O0 -fsanitize=address,undefined"
            }
        },
        {
            "name": "release",
            "displayName": "Release",
            "description": "Optimized release build",
            "inherits": "base",
            "cacheVariables": {
                "CMAKE_BUILD_TYPE": "Release",
                "CMAKE_CXX_FLAGS_RELEASE": "-O3 -DNDEBUG"
            }
        }
    ],
    "buildPresets": [
        { "name": "debug", "configurePreset": "debug" },
        { "name": "release", "configurePreset": "release" }
    ]
}
CMAKE
success "CMake presets configured"

# ─── Virtual Machine Manager ────────────────────────────────────────────
step "CONFIGURING VM MANAGER"

if command -v virt-manager &>/dev/null; then
    mkdir -p /opt/workspace/vm
    cat > /opt/workspace/vm/default-network.xml << 'VIRSH'
<network>
  <name>default</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
VIRSH
    success "VM network configuration created"
fi

# ─── Development Aliases ────────────────────────────────────────────────
cat >> /etc/skel/.zshrc << 'DEVALIASES'

# ─── Development Shortcuts ──────────────────────────────────────────────
alias ws='cd /opt/workspace'
alias dock='docker'
alias dkc='docker-compose'
alias pman='podman'
alias cm='cmake --preset'
alias cbuild='cm --build'
alias ginit='git init && git add . && git commit -m "initial commit"'
alias gpush='git add . && git commit -m "update" && git push'
alias serve='python3 -m http.server 8080'
alias tunnel='ssh -R 8080:localhost:8080 serveo.net'
alias ports='ss -tlnp'
alias myip='curl -s ifconfig.me'
alias speed='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'
DEVALIASES

success "Development environment configured"

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Workspace at /opt/workspace${NC}"
echo -e "${GREEN}  ✓ Git configured with modern defaults${NC}"
echo -e "${GREEN}  ✓ Docker/Podman configured${NC}"
echo -e "${GREEN}  ✓ Language servers installed${NC}"
echo -e "${GREEN}  ✓ Build tools configured${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"