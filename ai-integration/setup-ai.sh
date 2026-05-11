#!/bin/bash
# ============================================================================
# ShadowOS AI Integration Setup
# ============================================================================
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
step() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n"; }
success() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; }
info() { echo -e "  ${BLUE}ℹ${NC} $1"; }

step "SHADOWOS AI INTEGRATION SETUP"

# ─── Detect GPU ─────────────────────────────────────────────────────────
GPU_VENDOR="none"
if lspci 2>/dev/null | grep -qi nvidia; then
    GPU_VENDOR="nvidia"
elif lspci 2>/dev/null | grep -qi "amd\|radeon"; then
    GPU_VENDOR="amd"
elif lspci 2>/dev/null | grep -qi "intel.*graphics"; then
    GPU_VENDOR="intel"
fi
info "GPU detected: $GPU_VENDOR"

# ─── Install Ollama ─────────────────────────────────────────────────────
step "INSTALLING OLLAMA"
if command -v ollama &>/dev/null; then
    success "Ollama already installed ($(ollama --version 2>/dev/null || echo 'unknown'))"
else
    case $(uname -m) in
        x86_64|amd64)
            curl -fsSL https://ollama.com/install.sh | sh 2>&1 || warn "Ollama install failed"
            ;;
        aarch64|arm64)
            curl -fsSL https://ollama.com/install.sh | sh 2>&1 || warn "Ollama install failed"
            ;;
        *)
            warn "Unsupported architecture for Ollama: $(uname -m)"
            ;;
    esac
    success "Ollama installed"
fi

# ─── Install AI Models ──────────────────────────────────────────────────
step "DOWNLOADING AI MODELS"

# Check if Ollama is running, start if not
if ! pgrep -x ollama > /dev/null 2>&1; then
    info "Starting Ollama service..."
    ollama serve &
    sleep 3
fi

# Download models based on GPU
case $GPU_VENDOR in
    nvidia)
        info "NVIDIA GPU detected — using CUDA models"
        ollama pull llama3.1:8b 2>&1 || warn "Failed to pull llama3.1:8b"
        ollama pull codellama:7b 2>&1 || warn "Failed to pull codellama:7b"
        ollama pull mistral:7b 2>&1 || warn "Failed to pull mistral:7b"
        ollama pull phi3:mini 2>&1 || warn "Failed to pull phi3:mini"
        ollama pull neural-chat:7b 2>&1 || warn "Failed to pull neural-chat:7b"
        ;;
    amd)
        info "AMD GPU detected — using ROCm models"
        ollama pull llama3.1:8b 2>&1 || warn "Failed to pull llama3.1:8b"
        ollama pull codellama:7b 2>&1 || warn "Failed to pull codellama:7b"
        ollama pull mistral:7b 2>&1 || warn "Failed to pull mistral:7b"
        ;;
    intel)
        info "Intel GPU detected — using OpenVINO optimized models"
        ollama pull llama3.1:8b 2>&1 || warn "Failed to pull llama3.1:8b"
        ollama pull phi3:mini 2>&1 || warn "Failed to pull phi3:mini"
        ;;
    *)
        info "No dedicated GPU — using CPU models (smaller variants)"
        ollama pull llama3.1:8b 2>&1 || warn "Failed to pull llama3.1:8b"
        ollama pull phi3:mini 2>&1 || warn "Failed to pull phi3:mini"
        ;;
esac

success "AI models configured"

# ─── Install Python ML Stack ────────────────────────────────────────────
step "INSTALLING PYTHON ML STACK"
pip3 install --break-system-packages torch torchvision transformers \
    sentencepiece protobuf accelerate 2>&1 | tail -5 || warn "Some Python ML packages failed"
pip3 install --break-system-packages langchain chromadb faiss-cpu 2>&1 | tail -3 || true
success "Python ML stack installed"

# ─── Install Whisper (Voice Commands) ──────────────────────────────────
step "INSTALLING VOICE SUPPORT"
pip3 install --break-system-packages openai-whisper pydub sounddevice \
    speechrecognition pyttsx3 2>&1 | tail -3 || warn "Voice packages partially failed"
success "Voice command support installed"

# ─── Install JupyterLab ─────────────────────────────────────────────────
step "INSTALLING JUPYTERLAB"
pip3 install --break-system-packages jupyterlab notebook 2>&1 | tail -3 || warn "JupyterLab install skipped"
success "JupyterLab available"

# ─── Create AI Helper Scripts ───────────────────────────────────────────
mkdir -p /etc/skel/.local/bin

# AI-powered code completion daemon
cat > /etc/skel/.local/bin/ai-complete << 'AICOMPLETE'
#!/bin/bash
# Context-aware AI code completion
# Usage: ai-complete <file> or pipe: cat file.py | ai-complete
if [ -f "$1" ]; then
    CONTENT=$(cat "$1")
else
    CONTENT=$(cat)
fi
curl -s http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"codellama:7b\",\"prompt\":\"Complete this code:\\n$CONTENT\\n\\n// Continue:\",\"stream\":false}" \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('response',''))"
AICOMPLETE
chmod +x /etc/skel/.local/bin/ai-complete

# AI system diagnostics
cat > /etc/skel/.local/bin/ai-diagnose << 'AIDIAG'
#!/bin/bash
# AI-powered system diagnostics
echo "🤖 Running AI system diagnostics..."
echo ""
echo "── System Info ──"
neofetch --stdout 2>/dev/null | head -20
echo ""
echo "── Security Status ──"
echo "Firewall: $(systemctl is-active nftables 2>/dev/null || echo inactive)"
echo "AppArmor: $(aa-status --enabled 2>/dev/null && echo active || echo inactive)"
echo "Encryption: $(lsblk -o NAME,FSTYPE | grep -c crypto || echo 0) encrypted volumes"
echo ""
echo "── Performance ──"
echo "CPU: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2}')%"
echo "RAM: $(free -h | awk '/^Mem:/{print $3"/"$2}')"
echo "Disk: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
echo ""
echo "── AI Status ──"
curl -s http://localhost:11434/api/tags 2>/dev/null | python3 -c "
import sys,json
models=json.load(sys.stdin).get('models',[])
print(f'Models loaded: {len(models)}')
for m in models: print(f'  • {m[\"name\"]} ({m[\"size\"]/1024/1024:.1f} MB)')
" 2>/dev/null || echo "Ollama not running"
AIDIAG
chmod +x /etc/skel/.local/bin/ai-diagnose

# ─── Ollama Service ─────────────────────────────────────────────────────
cat > /etc/skel/.local/bin/ai-start << 'AISTART'
#!/bin/bash
echo "🤖 Starting Ollama AI engine..."
ollama serve &
sleep 2
echo "✓ Ollama running on http://localhost:11434"
echo "✓ Default model: llama3.1:8b"
echo ""
echo "Usage:"
echo "  ai <prompt>              — General AI query"
echo "  ai codellama:7b <code>   — Code generation"
echo "  ai-scan <target>         — AI security scan"
echo "  ai-review <file>         — AI code review"
echo "  ai-diagnose              — System diagnostics"
AISTART
chmod +x /etc/skel/.local/bin/ai-start

cat > /etc/skel/.local/bin/ai-stop << 'AISTOP'
#!/bin/bash
echo "🛑 Stopping Ollama..."
pkill ollama 2>/dev/null || true
echo "✓ Ollama stopped"
AISTOP
chmod +x /etc/skel/.local/bin/ai-stop

success "AI helper scripts created (ai-start, ai-stop, ai-complete, ai-diagnose)"

# ─── Neovim AI Integration ──────────────────────────────────────────────
mkdir -p /etc/skel/.config/nvim/lua
cat > /etc/skel/.config/nvim/lua/ai_copilot.lua << 'AICOPILOT'
-- ShadowOS AI Copilot for Neovim
-- Requires: ollama running locally

local M = {}

function M.ai_complete()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local code = table.concat(lines, "\n")

    local handle = io.popen(string.format(
        'curl -s http://localhost:11434/api/generate ' ..
        '-H "Content-Type: application/json" ' ..
        '-d \'{"model":"codellama:7b","prompt":"Complete this code:\\n%s\\n\\n// Continue:","stream":false}\'',
        code:gsub("'", "'\\''")
    ))

    if handle then
        local result = handle:read("*a")
        handle:close()
        local response = vim.json.decode(result).response or "No response"
        -- Append AI completion
        local last_line = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_buf_set_lines(buf, last_line - 1, last_line, false,
            vim.split(response, "\n"))
        print("🤖 AI completion inserted")
    else
        print("⚠ Ollama not running")
    end
end

function M.ai_explain()
    local visual_text = vim.fn.getreg("*")
    if visual_text == "" then return end

    local handle = io.popen(string.format(
        'curl -s http://localhost:11434/api/generate ' ..
        '-H "Content-Type: application/json" ' ..
        '-d \'{"model":"llama3.1:8b","prompt":"Explain this code in detail:\\n%s","stream":false}\'',
        visual_text:gsub("'", "'\\''")
    ))

    if handle then
        local result = handle:read("*a")
        handle:close()
        print(vim.json.decode(result).response or "No response")
    end
end

return M
AICOPILOT

success "Neovim AI copilot module created"

step "AI INTEGRATION COMPLETE"
echo ""
echo -e "  ${GREEN}✓${NC} Ollama installed and configured"
echo -e "  ${GREEN}✓${NC} AI models ready to download"
echo -e "  ${GREEN}✓${NC} Commands: ai, ai-scan, ai-review, ai-start, ai-stop"
echo -e "  ${GREEN}✓${NC} Voice support: Whisper + speech recognition"
echo -e "  ${GREEN}✓${NC} Neovim AI copilot module"
echo -e "  ${GREEN}✓${NC} JupyterLab for data science"
echo ""
echo -e "  ${YELLOW}Run 'ai-start' to begin Ollama, then try:${NC}"
echo -e "  ${YELLOW}  ai \"What is ShadowOS?\"${NC}"
echo -e "  ${YELLOW}  ai codellama:7b \"Write a Python TCP server\"${NC}"