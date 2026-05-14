#!/usr/bin/env bash
# ============================================================================
# ShadowOS AI Model Manager
# ============================================================================
# | Manage Ollama models with easy install/remove/list/status commands       |
# ============================================================================

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
RED='\033[0;31m'; NC='\033[0m'
BOLD='\033[1m'

API_URL="http://localhost:11434"
MODEL_DIR="${HOME}/.local/share/ollama/models"

# Recommended models with sizes and use cases
declare -A RECOMMENDED_MODELS
RECOMMENDED_MODELS=(
    ["llama3.2:8b"]="General AI - 8B parameters, balanced performance"
    ["llama3.2:70b"]="Advanced AI - 70B parameters, high quality (needs 48GB+ RAM)"
    ["gemma2:9b"]="Google AI - 9B parameters, excellent for coding"
    ["gemma2:27b"]="Google AI - 27B parameters, superior reasoning"
    ["mixtral:8x7b"]="MoE - 45B active, excellent code & reasoning"
    ["mixtral:8x22b"]="MoE - 141B active, top-tier quality"
    ["codellama:7b"]="Code Generation - 7B, great for programming"
    ["codellama:13b"]="Code Generation - 13B, better complex code"
    ["codellama:34b"]="Code Generation - 34B, best code quality"
    ["deepseek-coder:33b"]="Code AI - 33B, Chinese-trained, excellent"
    ["phi3:mini"]="Microsoft - 3.8B, fast and efficient"
    ["phi3:medium"]="Microsoft - 14B, good balance"
    ["neural-chat:7b"]="Intel - 7B, conversational AI"
    ["dolphin-llama3:8b"]="Uncensored - 8B, unrestricted responses"
    ["openhermes:7b"]="Open Source - 7B, good general purpose"
    ["solar:10.7b"]="Performance - 10.7B, fast reasoning"
    ["mistral:7b"]="Mistral - 7B, European AI, fast"
    ["mistral-nemo:12b"]="Mistral - 12B, enhanced version"
    ["llama3.1:8b"]="Meta LLaMA 3.1 - 8B, reliable"
    ["llama3.1:70b"]="Meta LLaMA 3.1 - 70B, premium quality"
    ["qwen2:7b"]="Alibaba - 7B, multilingual support"
    ["qwen2:72b"]="Alibaba - 72B, top multilingual model"
    ["starcoder2:15b"]="Code - 15B, BigCode project"
    ["stable-code:3b"]="Code - 3B, fast code completion"
    ["tinyllama:1.1b"]="Tiny - 1.1B, minimal resources"
    ["smollm:1.7b"]="Small - 1.7B, efficient"
    ["llava:7b"]="Vision AI - 7B, image understanding"
    ["llava:13b"]="Vision AI - 13B, better image analysis"
    ["bakllava:7b"]="Vision AI - 7B, improved vision"
    ["moondream:7b"]="Vision AI - 7B, lightweight"
    ["whisper:base"]="Voice - Base model, speech recognition"
    ["whisper:medium"]="Voice - Medium model, better accuracy"
    ["whisper:large"]="Voice - Large model, best accuracy"
    ["nous-hermes:7b"]="Open Source - 7B, reasoning focused"
    ["wizard-vicuna:7b"]="WizardLM - 7B, instruction following"
    ["vicuna:7b"]="Vicuna - 7B, chat optimized"
    ["zephyr:7b"]="Zephyr - 7B, fast chat model"
    ["stablelm2:12b"]="Stability AI - 12B, next gen"
    ["command-r:35b"]="Cohere - 35B, RAG optimized"
    ["llama3-groq:8b"]="Groq - 8B, optimized for speed"
)

show_help() {
    echo -e "${BOLD}ShadowOS AI Model Manager${NC}"
    echo ""
    echo "Usage: ai-models <command> [options]"
    echo ""
    echo -e "${CYAN}Commands:${NC}"
    echo "  list              List all installed and available models"
    echo "  install <model>   Install a specific model"
    echo "  remove <model>    Remove a specific model"
    echo "  pull <model>      Pull a model (alias for install)"
    echo "  status            Show AI engine status"
    echo "  info <model>      Show model details"
    echo "  size <model>      Estimate model size"
    echo "  update            Update all installed models"
    echo "  benchmark <model> Run simple benchmark"
    echo "  recommend         Show recommended models for your hardware"
    echo "  clean             Remove unused models"
    echo "  search <query>    Search for models"
    echo ""
    echo -e "${CYAN}Examples:${NC}"
    echo "  ai-models install llama3.2:8b"
    echo "  ai-models list"
    echo "  ai-models recommend"
    echo "  ai-models benchmark llama3.2:8b"
}

check_ollama() {
    if ! command -v ollama &>/dev/null; then
        echo -e "${RED}✗ Ollama is not installed${NC}"
        echo "  Install with: curl -fsSL https://ollama.com/install.sh | sh"
        exit 1
    fi

    if ! curl -s "$API_URL/api/tags" &>/dev/null; then
        echo -e "${YELLOW}⚠ Ollama is not running${NC}"
        echo "  Start with: ollama serve"
        echo "  Or: sudo systemctl start shadowos-ai"
        exit 1
    fi
}

get_installed_models() {
    curl -s "$API_URL/api/tags" 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for m in data.get('models', []):
    print(m['name'], m.get('size', 0))
" 2>/dev/null || echo ""
}

list_models() {
    check_ollama

    echo -e "${BOLD}Installed Models:${NC}"
    echo ""

    INSTALLED=$(get_installed_models)

    if [ -z "$INSTALLED" ]; then
        echo "  (none installed)"
    else
        echo "$INSTALLED" | while read -r name size; do
            SIZE_MB=$(echo "scale=1; $size / 1024 / 1024" | bc 2>/dev/null || echo "?")
            echo -e "  ${GREEN}✓${NC} $name (${SIZE_MB} MB)"
        done
    fi

    echo ""
    echo -e "${BOLD}Available Models:${NC}"
    echo ""

    for model in "${!RECOMMENDED_MODELS[@]}"; do
        if ! echo "$INSTALLED" | grep -q "^$model "; then
            echo "  $model — ${RECOMMENDED_MODELS[$model]}"
        fi
    done
}

install_model() {
    local model="$1"

    if [ -z "$model" ]; then
        echo -e "${RED}Error: Model name required${NC}"
        echo "  Usage: ai-models install <model:tag>"
        exit 1
    fi

    check_ollama

    echo -e "${CYAN}Pulling model: $model${NC}"
    echo "  This may take a while depending on model size..."
    echo ""

    ollama pull "$model" 2>&1

    if [ $? -eq 0 ]; then
        success "Model installed: $model"
    else
        echo -e "${RED}✗ Failed to install model: $model${NC}"
        exit 1
    fi
}

remove_model() {
    local model="$1"

    if [ -z "$model" ]; then
        echo -e "${RED}Error: Model name required${NC}"
        echo "  Usage: ai-models remove <model:tag>"
        exit 1
    fi

    check_ollama

    echo -e "${YELLOW}Removing model: $model${NC}"
    ollama rm "$model" 2>&1

    if [ $? -eq 0 ]; then
        success "Model removed: $model"
    else
        echo -e "${RED}✗ Failed to remove model: $model${NC}"
        exit 1
    fi
}

show_status() {
    echo -e "${BOLD}AI Engine Status:${NC}"
    echo ""

    if command -v ollama &>/dev/null; then
        echo -e "  Ollama: ${GREEN}installed${NC} ($(ollama --version 2>/dev/null || echo 'unknown'))"
    else
        echo -e "  Ollama: ${RED}not installed${NC}"
    fi

    if curl -s "$API_URL/api/tags" &>/dev/null; then
        echo -e "  API: ${GREEN}running${NC} ($API_URL)"

        # Show model count and total size
        MODEL_COUNT=$(curl -s "$API_URL/api/tags" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(len(data.get('models', [])))
" 2>/dev/null || echo "0")

        TOTAL_SIZE=$(curl -s "$API_URL/api/tags" | python3 -c "
import sys, json
data = json.load(sys.stdin)
total = sum(m.get('size', 0) for m in data.get('models', []))
print(f'{total / 1024 / 1024:.1f} MB')
" 2>/dev/null || echo "0 MB")

        echo -e "  Models: $MODEL_COUNT ($TOTAL_SIZE)"
    else
        echo -e "  API: ${RED}not running${NC}"
    fi

    # Check GPU
    if lspci 2>/dev/null | grep -qi nvidia; then
        echo -e "  GPU: ${GREEN}NVIDIA detected${NC}"
    elif lspci 2>/dev/null | grep -qi "amd\|radeon"; then
        echo -e "  GPU: ${GREEN}AMD detected${NC}"
    elif lspci 2>/dev/null | grep -qi "intel.*graphics"; then
        echo -e "  GPU: ${YELLOW}Intel integrated${NC}"
    else
        echo -e "  GPU: ${YELLOW}unknown / CPU only${NC}"
    fi

    echo ""
    echo -e "${BOLD}Environment:${NC}"
    echo "  SHADOWOS_AI_MODEL: ${DEFAULT_AI_MODEL:-llama3.2:8b}"
    echo "  OLLAMA_HOST: ${OLLAMA_HOST:-localhost:11434}"
    echo "  OLLAMA_MODELS: ${OLLAMA_MODELS:-/opt/ShadowOS/ai/models}"
}

show_info() {
    local model="$1"

    if [ -z "$model" ]; then
        echo -e "${RED}Error: Model name required${NC}"
        exit 1
    fi

    check_ollama

    echo -e "${BOLD}Model Info: $model${NC}"
    echo ""

    curl -s "$API_URL/api/show" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$model\"}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
info = data.get('model_info', {})
print(f'  Name: {data.get(\"name\", \"unknown\")}')
print(f'  Family: {info.get(\"family\", \"unknown\")}')
print(f'  Parameter Size: {info.get(\"parameter_size\", \"unknown\")}')
print(f'  Quantization: {info.get(\"quantization_level\", \"unknown\")}')
print(f'  Context Length: {info.get(\"context_length\", \"unknown\")}')
" 2>/dev/null || echo "  Model not found or Ollama not running"
}

estimate_size() {
    local model="$1"

    if [ -z "$model" ]; then
        echo -e "${RED}Error: Model name required${NC}"
        exit 1
    fi

    # Rough size estimates based on model name
    local size_mb
    case "$model" in
        *":8b"*) size_mb="~4.7 GB" ;;
        *":70b"*) size_mb="~40 GB" ;;
        *":9b"*) size_mb="~5.4 GB" ;;
        *":27b"*) size_mb="~15 GB" ;;
        *":7b"*) size_mb="~4.1 GB" ;;
        *":13b"*) size_mb="~7.8 GB" ;;
        *":34b"*) size_mb="~20 GB" ;;
        *":33b"*) size_mb="~19 GB" ;;
        *":35b"*) size_mb="~20 GB" ;;
        *":14b"*) size_mb="~8 GB" ;;
        *":12b"*) size_mb="~7 GB" ;;
        *":15b"*) size_mb="~8.5 GB" ;;
        *":1.1b"*) size_mb="~650 MB" ;;
        *":1.7b"*) size_mb="~1 GB" ;;
        *":3b"*) size_mb="~1.9 GB" ;;
        *":3.8b"*) size_mb="~2.2 GB" ;;
        *":3.5b"*) size_mb="~2 GB" ;;
        *"base"*) size_mb="~150 MB" ;;
        *"medium"*) size_mb="~500 MB" ;;
        *"large"*) size_mb="~1.5 GB" ;;
        *) size_mb="unknown" ;;
    esac

    echo -e "${BOLD}Estimated Size: $model${NC}"
    echo "  Approximate download size: $size_mb"
    echo "  Approximate disk usage: $size_mb"
    echo ""
    echo "  Note: Actual size depends on quantization level and format."
}

benchmark_model() {
    local model="$1"

    if [ -z "$model" ]; then
        echo -e "${RED}Error: Model name required${NC}"
        exit 1
    fi

    check_ollama

    echo -e "${CYAN}Benchmarking model: $model${NC}"
    echo "  Running 10 test prompts..."
    echo ""

    local total_time=0
    local num_tests=10

    for i in $(seq 1 $num_tests); do
        local start=$(date +%s%N)
        curl -s "$API_URL/api/generate" \
            -H "Content-Type: application/json" \
            -d "{\"model\":\"$model\",\"prompt\":\"Write a one-line Python hello world program\",\"stream\":false}" \
            > /dev/null 2>&1
        local end=$(date +%s%N)
        local elapsed=$(( (end - start) / 1000000 ))
        total_time=$(( total_time + elapsed ))
        echo -e "  Test $i: ${elapsed}ms"
    done

    local avg=$(( total_time / num_tests ))
    echo ""
    echo -e "${BOLD}Results:${NC}"
    echo "  Average response time: ${avg}ms"
    echo "  Total tests: $num_tests"

    if [ $avg -lt 1000 ]; then
        echo -e "  Rating: ${GREEN}Excellent${NC}"
    elif [ $avg -lt 3000 ]; then
        echo -e "  Rating: ${GREEN}Good${NC}"
    elif [ $avg -lt 5000 ]; then
        echo -e "  Rating: ${YELLOW}Average${NC}"
    else
        echo -e "  Rating: ${RED}Slow (consider smaller model)${NC}"
    fi
}

update_models() {
    check_ollama

    echo -e "${CYAN}Updating all installed models...${NC}"
    echo ""

    INSTALLED=$(get_installed_models)

    if [ -z "$INSTALLED" ]; then
        echo "  No models installed."
        return
    fi

    echo "$INSTALLED" | while read -r name size; do
        echo "  Updating: $name"
        ollama pull "$name" 2>&1 | tail -1
    done

    success "All models updated"
}

clean_models() {
    check_ollama

    echo -e "${YELLOW}Cleaning unused model data...${NC}"

    # Get model digests
    DIGESTS=$(curl -s "$API_URL/api/tags" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for m in data.get('models', []):
    print(m.get('digest', ''))
" 2>/dev/null)

    # Clean ollama cache
    rm -rf "${HOME}/.ollama"/*.blob 2>/dev/null || true

    success "Model cache cleaned"
}

search_models() {
    local query="$1"

    if [ -z "$query" ]; then
        echo -e "${RED}Error: Search query required${NC}"
        exit 1
    fi

    echo -e "${BOLD}Search results for: $query${NC}"
    echo ""

    for model in "${!RECOMMENDED_MODELS[@]}"; do
        if echo "$model ${RECOMMENDED_MODELS[$model]}" | grep -qi "$query"; then
            echo "  $model — ${RECOMMENDED_MODELS[$model]}"
        fi
    done
}

# Main command handler
case "${1:-help}" in
    list|ls)
        list_models
        ;;
    install|pull|add)
        install_model "$2"
        ;;
    remove|rm|delete)
        remove_model "$2"
        ;;
    status|info)
        show_status
        ;;
    model-info|details)
        show_info "$2"
        ;;
    size|estimate)
        estimate_size "$2"
        ;;
    benchmark|bench)
        benchmark_model "$2"
        ;;
    update|upgrade)
        update_models
        ;;
    clean|gc)
        clean_models
        ;;
    search|find)
        search_models "$2"
        ;;
    recommend|rec)
        echo -e "${BOLD}Recommended Models for Your System:${NC}"
        echo ""

        RAM_KB=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')
        RAM_GB=$(echo "scale=1; $RAM_KB / 1024 / 1024" | bc 2>/dev/null || echo "4")

        echo "  System RAM: ${RAM_GB} GB"
        echo ""

        if [ "$(echo "$RAM_GB >= 64" | bc 2>/dev/null || echo 0)" -eq 1 ]; then
            echo -e "  ${GREEN}AI Workstation (64GB+ RAM):${NC}"
            echo "    • llama3.2:70b — Premium general AI"
            echo "    • mixtral:8x22b — Top-tier MoE"
            echo "    • qwen2:72b — Multilingual powerhouse"
            echo "    • codellama:34b — Best code generation"
            echo "    • llava:13b — Vision AI"
        elif [ "$(echo "$RAM_GB >= 16" | bc 2>/dev/null || echo 0)" -eq 1 ]; then
            echo -e "  ${GREEN}High Performance (16GB+ RAM):${NC}"
            echo "    • llama3.2:8b — Best balance"
            echo "    • gemma2:9b — Google quality"
            echo "    • mixtral:8x7b — MoE efficiency"
            echo "    • codellama:13b — Good code model"
            echo "    • neural-chat:7b — Conversational"
        elif [ "$(echo "$RAM_GB >= 8" | bc 2>/dev/null || echo 0)" -eq 1 ]; then
            echo -e "  ${YELLOW}Standard (8GB+ RAM):${NC}"
            echo "    • llama3.1:8b — Reliable general"
            echo "    • phi3:mini — Efficient"
            echo "    • codellama:7b — Code focused"
            echo "    • mistral:7b — Fast European"
        else
            echo -e "  ${YELLOW}Minimal (<8GB RAM):${NC}"
            echo "    • tinyllama:1.1b — Ultra light"
            echo "    • smollm:1.7b — Efficient"
            echo "    • stable-code:3b — Code only"
            echo "    • phi3:mini — Best small model"
        fi
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "  Run 'ai-models help' for usage information"
        exit 1
        ;;
esac