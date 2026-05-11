#!/bin/bash
# ============================================================================
# ShadowOS System Monitor Service
# Real-time system dashboard with cyberpunk aesthetics
# ============================================================================

MONITOR_DIR="/opt/ShadowOS/monitor"
PID_FILE="/var/run/shadowos-monitor.pid"
LOG_FILE="/var/log/shadowos-monitor.log"
REFRESH_RATE=2  # seconds

mkdir -p "$MONITOR_DIR"

# ─── Color Codes ────────────────────────────────────────────────────────
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'
CLEAR='\033[2J\033[H'

# ─── Utility Functions ──────────────────────────────────────────────────
get_cpu_usage() {
    local cpu_line=$(top -bn1 | grep "Cpu(s)")
    local user=$(echo "$cpu_line" | awk '{print $2}')
    local system=$(echo "$cpu_line" | awk '{print $4}')
    local idle=$(echo "$cpu_line" | awk '{print $8}')
    local usage=$(echo "100 - $idle" | bc 2>/dev/null || echo "0")
    echo "$usage"
}

get_cpu_temp() {
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        local temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        echo "$(echo "scale=1; $temp / 1000" | bc 2>/dev/null || echo "?")°C"
    else
        echo "N/A"
    fi
}

get_ram_usage() {
    local mem_info=$(free -h | grep Mem)
    local used=$(echo "$mem_info" | awk '{print $3}')
    local total=$(echo "$mem_info" | awk '{print $2}')
    local percent=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}')
    echo "$used / $total ($percent%)"
}

get_swap_usage() {
    local swap_info=$(free -h | grep Swap)
    local used=$(echo "$swap_info" | awk '{print $3}')
    local total=$(echo "$swap_info" | awk '{print $2}')
    echo "$used / $total"
}

get_disk_usage() {
    df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}'
}

get_uptime() {
    uptime -p 2>/dev/null || cat /proc/uptime | awk '{printf "%d days, %d hours, %d minutes", $1/86400, ($1%86400)/3600, ($1%3600)/60}'
}

get_network_stats() {
    local iface=$(ip route | grep default | awk '{print $5}' | head -1)
    local ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    local rx=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo "0")
    local tx=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo "0")
    echo "$iface | IP: $ip | RX: $rx | TX: $tx"
}

get_process_count() {
    ps aux | wc -l
}

get_top_processes() {
    ps aux --sort=-%cpu | head -6 | tail -5
}

get_load_average() {
    cat /proc/loadavg
}

get_gpu_info() {
    if command -v nvidia-smi &>/dev/null; then
        nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null
    elif [ -f /sys/class/drm/card0/device/gpuinfo ]; then
        head -5 /sys/class/drm/card0/device/gpuinfo 2>/dev/null
    else
        echo "No GPU detected"
    fi
}

get_tor_status() {
    if pgrep -x tor > /dev/null; then
        echo -e "${GREEN}ACTIVE${NC} (Port 9050)"
    else
        echo -e "${RED}INACTIVE${NC}"
    fi
}

get_firewall_status() {
    if command -v nft &>/dev/null && nft list ruleset 2>/dev/null | grep -q "filter"; then
        echo -e "${GREEN}ACTIVE${NC} (nftables)"
    elif command -v ufw &>/dev/null && ufw status | grep -q "active"; then
        echo -e "${GREEN}ACTIVE${NC} (ufw)"
    else
        echo -e "${RED}INACTIVE${NC}"
    fi
}

get_encryption_status() {
    local encrypted=$(lsblk -o NAME,FSTYPE | grep -c crypto 2>/dev/null || echo "0")
    if [ "$encrypted" -gt 0 ]; then
        echo -e "${GREEN}ENCRYPTED${NC} ($encrypted volumes)"
    else
        echo -e "${YELLOW}NOT ENCRYPTED${NC}"
    fi
}

# ─── ASCII Bar Graph ────────────────────────────────────────────────────
draw_bar() {
    local value=$1
    local max=$2
    local width=30
    local filled=$((value * width / max))
    local empty=$((width - filled))
    
    local color=$GREEN
    if [ "$value" -gt 80 ]; then color=$RED
    elif [ "$value" -gt 50 ]; then color=$YELLOW
    fi
    
    printf "${color}["
    printf "%0.s█" $(seq 1 $filled)
    printf "%0.s░" $(seq 1 $empty)
    printf "${NC}]"
}

# ─── Dashboard Render ───────────────────────────────────────────────────
render_dashboard() {
    echo -e "$CLEAR"
    
    local cpu=$(get_cpu_usage | cut -d. -f1)
    local mem_percent=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║  🌑 SHADOWOS SYSTEM DASHBOARD                                        ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # ─── CPU Section ──────────────────────────────────────────────────
    echo -e "  ${BOLD}┌─ CPU ──────────────────────────────────────────────────────┐${NC}"
    echo -e "  │  Usage: ${GREEN}${cpu}%${NC}  Temp: $(get_cpu_temp)"
    echo -e "  │  Load:  $(get_load_average)"
    echo -ne "  │  "
    draw_bar "$cpu" 100
    echo -e "  │  Processes: $(get_process_count)"
    echo -e "  └──────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # ─── Memory Section ──────────────────────────────────────────────
    echo -e "  ${BOLD}┌─ MEMORY ──────────────────────────────────────────────────┐${NC}"
    echo -e "  │  $(get_ram_usage)"
    echo -e "  │  Swap: $(get_swap_usage)"
    echo -ne "  │  "
    draw_bar "$mem_percent" 100
    echo -e "  └──────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # ─── Disk Section ────────────────────────────────────────────────
    echo -e "  ${BOLD}┌─ STORAGE ────────────────────────────────────────────────┐${NC}"
    echo -e "  │  $(get_disk_usage)"
    echo -e "  └──────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # ─── Network Section ─────────────────────────────────────────────
    echo -e "  ${BOLD}┌─ NETWORK ────────────────────────────────────────────────┐${NC}"
    echo -e "  │  $(get_network_stats)"
    echo -e "  │  Tor:    $(get_tor_status)"
    echo -e "  │  VPN:    ${YELLOW}Check wg0${NC}"
    echo -e "  │  Firewall: $(get_firewall_status)"
    echo -e "  └──────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # ─── Security Section ────────────────────────────────────────────
    echo -e "  ${BOLD}┌─ SECURITY ───────────────────────────────────────────────┐${NC}"
    echo -e "  │  Encryption: $(get_encryption_status)"
    echo -e "  │  Uptime: $(get_uptime)"
    echo -e "  └──────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # ─── GPU Section ─────────────────────────────────────────────────
    echo -e "  ${BOLD}┌─ GPU ────────────────────────────────────────────────────┐${NC}"
    echo -e "  │  $(get_gpu_info)"
    echo -e "  └──────────────────────────────────────────────────────────┘${NC}"
    echo ""
    
    # ─── Top Processes ───────────────────────────────────────────────
    echo -e "  ${BOLD}┌─ TOP PROCESSES ─────────────────────────────────────────┐${NC}"
    echo -e "  │  $(get_top_processes | sed 's/^/  │  /')"
    echo -e "  └──────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "  ${CYAN}Press Ctrl+C to exit | Refresh: every ${REFRESH_RATE}s${NC}"
}

# ─── Main Loop ──────────────────────────────────────────────────────────
run_monitor() {
    echo $$ > "$PID_FILE"
    trap cleanup EXIT INT TERM
    
    while true; do
        render_dashboard >> "$LOG_FILE" 2>&1
        sleep "$REFRESH_RATE"
    done
}

cleanup() {
    rm -f "$PID_FILE"
    echo -e "\n${GREEN}ShadowOS Monitor stopped${NC}"
}

# ─── CLI Interface ──────────────────────────────────────────────────────
case "${1:-live}" in
    live)
        run_monitor
        ;;
    snapshot)
        render_dashboard
        ;;
    log)
        tail -f "$LOG_FILE"
        ;;
    status)
        echo "CPU: $(get_cpu_usage)%"
        echo "RAM: $(get_ram_usage)"
        echo "DISK: $(get_disk_usage)"
        echo "TOR: $(get_tor_status)"
        echo "FIREWALL: $(get_firewall_status)"
        ;;
    *)
        echo "Usage: $0 {live|snapshot|log|status}"
        exit 1
        ;;
esac